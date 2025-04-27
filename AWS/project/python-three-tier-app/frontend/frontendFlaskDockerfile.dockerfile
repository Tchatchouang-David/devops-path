# Use a lightweight Python image as the base image
FROM python:3.12 as base
# Install build dependencies
RUN apk add --no-cache gcc musl-dev libffi-dev
# Set the working directory
WORKDIR /app
# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Copy the application code
COPY . .
# Expose the port the app runs on
EXPOSE 5000
# Use a production WSGI server
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]