# Use Python 3.11 as the base image
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy all files from the current directory into the container
COPY . .

# Install dependencies from requirements.txt
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port your Flask app will run on
EXPOSE 5002

# Define environment variables for paths
ENV FLASK_APP=converter_dec.py
ENV CONVERTED_JSON_FOLDER=/app/json_files

# Run the Flask app
CMD ["flask", "run", "--host=0.0.0.0", "--port=5002"]
