# Verwende ein Basis-Python-Image
FROM python:3.11.4

# Deklariere den Port, auf dem die Anwendung lauscht
EXPOSE 8000

# Setze das Arbeitsverzeichnis
WORKDIR /app

# Installiere awscli und unzip
RUN apt-get update && \
    apt-get install -y awscli unzip

# Kopiere die requirements-Datei in das Container-Image
COPY requirements.txt .

# Installiere die Abhängigkeiten
RUN pip install --no-cache-dir -r requirements.txt

# Umgebungsvariablen für S3 Bucket und Modell-Datei
ARG S3_BUCKET
ARG MODEL_ZIP=model.zip

# Download und Entpacken des Modells von S3
RUN aws s3 cp s3://${S3_BUCKET}/${MODEL_ZIP} /tmp/model.zip && \
    unzip /tmp/model.zip -d /path/to/model && \
    rm /tmp/model.zip

# Kopiere den Rest des Anwendungscodes
COPY . .

# Befehl zum Ausführen der Anwendung
CMD ["uvicorn", "mixtral_exec:app", "--host", "0.0.0.0", "--port", "8000"]
