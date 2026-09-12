FROM python:3.11-slim

# Tesseract backs image OCR; without it image submissions return HTTP 422.
RUN apt-get update \
    && apt-get install -y --no-install-recommends tesseract-ocr \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ ./

# The seed step rewrites seed/fixtures/*.json, so the app dir must be writable.
RUN useradd --create-home --uid 1000 finalsay && chown -R finalsay:finalsay /app
USER finalsay

EXPOSE 8000

CMD ["python", "-m", "uvicorn", "finalsay.main:app", "--host", "0.0.0.0", "--port", "8000"]
