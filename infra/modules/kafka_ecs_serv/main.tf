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

resource "aws_cloudwatch_log_group" "kafka" {
  name              = "/ecs/kafka"
  retention_in_days = 7
}

resource "aws_service_discovery_private_dns_namespace" "kafka_ns" {
  name        = "kafka.local"
  description = "Private namespace for Kafka ECS brokers"
  vpc         = var.ecs_cluster_vpc_id
}

resource "aws_service_discovery_service" "broker1" {
  name = "broker1"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.kafka_ns.id
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
        { name = "KAFKA_NODE_ID", value = "1" },
        { name = "KAFKA_PROCESS_ROLES", value = "broker,controller" },
        { name = "KAFKA_CONTROLLER_QUORUM_VOTERS", value = "1@broker1.kafka.local:9093" },
        { name = "KAFKA_LISTENERS", value = "INTERNAL://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,EXTERNAL://0.0.0.0:29092"},
        { name = "KAFKA_ADVERTISED_LISTENERS", value = "INTERNAL://broker1.kafka.local:9092,EXTERNAL://broker1.kafka.local:29092" },
        { name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP", value = "INTERNAL:PLAINTEXT,CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT" },
        { name = "KAFKA_INTER_BROKER_LISTENER_NAME", value = "INTERNAL" },
        { name = "KAFKA_CONTROLLER_LISTENER_NAMES", value = "CONTROLLER" },
        { name = "KAFKA_AUTO_CREATE_TOPICS_ENABLE", value = "true" },
        { name = "KAFKA_LOG_DIRS", value = "/var/lib/kafka/data" },
        { name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR", value = "1" } # set to 1 for single node
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
  launch_type     = "EC2"

  network_configuration {
    subnets = var.ecs_cluster_subnet_ids
    security_groups = [var.ecs_cluster_sg]
    assign_public_ip = false # or true if you want external access
  }

  service_registries {
    registry_arn = aws_service_discovery_service.broker1.arn
  }
}