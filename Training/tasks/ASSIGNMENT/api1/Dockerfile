# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt /app/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application code into the container at /app
COPY . /app

# Make port 5000 available to the world outside this container
EXPOSE 8000

#ENV POSTGRES_URL=postgresql://postgres:root@0.0.0.0:5432/api
# Define environment variable

# Run app.py when the container launches
CMD ["python", "app.py"]
