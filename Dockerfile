# Use official Python image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

#Copy app files
COPY app/ /app/

#Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

#Expose port
EXPOSE 8000

#Run app 
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
