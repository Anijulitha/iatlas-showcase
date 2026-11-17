# 1. Usamos una imagen de Python ligera y estable
FROM python:3.12-slim

# 2. Evitamos que Python genere archivos .pyc y forzamos logs en tiempo real
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# 3. 👁️ INSTALAMOS LOS "OJOS" Y HERRAMIENTAS DEL SISTEMA
# Instalamos Poppler (para PDFs escaneados) y Tesseract (para el OCR)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-spa \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 4. Creamos y configuramos el directorio de trabajo
WORKDIR /app

# 5. Instalamos las librerías de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5b. Pre-descargamos el modelo de embeddings en la imagen Docker.
#     Así cada contenedor de Railway arranca con el modelo ya disponible
#     en lugar de descargarlo en el primer request (cold start lento).
#     El modelo ocupa ~80 MB y se guarda en /root/.cache/huggingface/
#RUN python -c "from sentence_transformers import SentenceTransformer; #SentenceTransformer('intfloat/multilingual-e5-small')"

# 6. Copiamos el resto del código del proyecto
COPY . .

# 7. 🛡️ SEGURIDAD: Creamos un usuario no-root y le damos permisos
RUN useradd -m atlasuser && \
    chown -R atlasuser:atlasuser /app && \
    cp -r /root/.cache /home/atlasuser/.cache && \
    chown -R atlasuser:atlasuser /home/atlasuser/.cache
USER atlasuser

# 8. 🚀 COMANDO FINAL (Siempre al final)
CMD ["streamlit", "run", "app.py"]
