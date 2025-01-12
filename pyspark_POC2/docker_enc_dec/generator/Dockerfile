# Use Python 3.9 as the base image
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy the requirements and install dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Flask API code
COPY . .

# Expose the port your Flask app will run on
EXPOSE 5001

# Define environment variables for paths and Converter API URL
ENV FLASK_APP=generator_enc.py
ENV TEMP_FOLDER=/app/enc_files
ENV CONVERTER_API_URL=http://converter_api:5001/convert

# Run the Flask app
CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]
