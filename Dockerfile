FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY backend/requirements.txt /app/backend/requirements.txt
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

# Copy repository device profiles and protocols
COPY device-profiles/ /app/device-profiles/
COPY protocols/ /app/protocols/
COPY backend/ /app/backend/

ENV PYTHONPATH=/app

EXPOSE 8000 8080 8081 8082 8083 8084

CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
