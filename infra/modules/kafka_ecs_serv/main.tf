terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }
  backend "s3" {
  }
}

# configure cloudwatch logs
resource "aws_cloudwatch_log_group" "kafka" {
  name              = "/ecs/${var.container_name}"
  retention_in_days = 3
}

# service discovery name. Needs a private dns namespace (created in ecs module)
resource "aws_service_discovery_service" "broker" {
  name = var.container_name
  dns_config {
    namespace_id = var.ecs_private_dns_ns
    dns_records { 
      type = "A"
      ttl = 10 
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    }
}


resource "aws_ecs_task_definition" "task" {

  family                   = "kafka-container"
  network_mode             = "awsvpc"          # bridge mode typical for EC2
  requires_compatibilities = ["EC2"]
  cpu                      = "512"        
  memory                   = "1024"   

  # Define a volume
  volume {
    name = "kafka-data"
    host_path = "/mnt/kafka-data" # path on the EC2 instance
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "apache/kafka:latest"
      essential = true

      portMappings = [
        { containerPort = 9093, protocol = "tcp" }, # CONTROLLER
        { containerPort = 9092, protocol = "tcp" },  # INTERNAL
        { containerPort = 29092, protocol = "tcp" } # EXTERNAL
      ]

      environment = [
        { name = "KAFKA_AUTO_CREATE_TOPICS_ENABLE", value = "true" },
        { name = "KAFKA_LOG_DIRS", value = "/var/lib/kafka/data" },

        { name = "KAFKA_NODE_ID", value = var.kafka_node_id },
        { name = "KAFKA_PROCESS_ROLES", value = var.kafka_process_roles },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = var.kafka_controller_quorum_voters },
        { name = "KAFKA_LISTENERS", value = var.kafka_listeners },
        { name = "KAFKA_ADVERTISED_LISTENERS", value = var.kafka_advertised_listeners },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = var.kafka_listener_security_protocol_map },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = var.kafka_inter_broker_listener_name },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = var.kafka_controller_listener_names },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = var.kafka_offsets_topic_replication_factor } 
      ]

      mountPoints = [
        {
          sourceVolume  = "kafka-data"
          containerPath = "/var/lib/kafka/data" # Kafka log.dirs
          readOnly      = false
        }
      ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.kafka.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  #launch_type     = "EC2"

  network_configuration {
    subnets = var.ecs_cluster_subnet_ids
    security_groups = [var.ecs_cluster_sg]
    assign_public_ip = false # or true if you want external access
  }

  capacity_provider_strategy {
    capacity_provider = var.ecs_capacity_provider_name
    weight            = 1
  }

  service_registries {
    registry_arn = aws_service_discovery_service.broker.arn
  }
}