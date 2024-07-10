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

# Kopiere das Modell, das im pre_build Schritt heruntergeladen wurde
COPY /tmp/model.gguf /app/model/mixtral-8x7b-instruct-v0.1.Q3_K_M.gguf

# Kopiere den Rest des Anwendungscodes
COPY . .

# Befehl zum Ausführen der Anwendung
CMD ["uvicorn", "mixtral_exec:app", "--host", "0.0.0.0", "--port", "8000"]
