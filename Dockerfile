# Use the official Python image from the Docker Hub
FROM python:3.10

# Make a directory for our application
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make port 5153 available to the world outside this container
EXPOSE 5153

# Set environment variables
ENV DB_USERNAME=my-app
ENV DB_PASSWORD=cuJh8nFNbS
ENV DB_HOST=your_db_host
ENV DB_PORT=your_db_port
ENV DB_NAME=your_db_name
ENV APP_PORT=5153

# Run the application
CMD ["python", "app.py"]
