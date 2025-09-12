# Use a lightweight Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Install the package
RUN pip install .

# Run hello-world once, then keep container alive
CMD ["sh", "-c", "hello-world && tail -f /dev/null"]