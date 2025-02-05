# syntax=docker/dockerfile:1

##############################
# Stage 1: Build Stage
##############################
FROM python:3.9-slim as builder

# Set working directory
WORKDIR /app

# Install build dependencies (if needed)
RUN apt-get update && apt-get install -y build-essential

# Copy requirements file and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

##############################
# Stage 2: Final Stage
##############################
FROM python:3.9-slim

WORKDIR /app

# Copy installed Python packages from builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages

# Copy the application code from builder stage
COPY --from=builder /app/app ./app

# Expose the port the app runs on
EXPOSE 5000

# Define environment variable for Flask
ENV FLASK_APP=app/main.py

# Run the application
CMD ["python", "app/main.py"]
