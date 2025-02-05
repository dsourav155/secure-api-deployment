# Debugging Dockerfile for Flask Application

FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn

# Copy application code
COPY app/ .

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    FLASK_ENV=production \
    FLASK_APP=main.py

# Expose port for the application
EXPOSE 5000

# Debugging: Print Python and Gunicorn versions
RUN python --version
RUN pip list | grep gunicorn

# Use gunicorn as production WSGI server
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "main:app"]