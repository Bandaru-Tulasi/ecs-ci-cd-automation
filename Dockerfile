# Use official Python runtime
FROM python:3.9-slim

# Set working directory in container
WORKDIR /app

# Copy requirements.txt first (better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY . .

# Expose port 8080
EXPOSE 8080

# Run the application
CMD ["python", "app.py"]
