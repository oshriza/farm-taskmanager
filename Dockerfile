# FROM python:3.8 AS builder
# # WORKDIR /app
# # COPY backend/ .
# # RUN pip install -r requirements.txt
# COPY backend/requirements.txt .
# RUN pip install --user -r requirements.txt
# # ENTRYPOINT [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000" ]


FROM tiangolo/uvicorn-gunicorn:python3.8-alpine3.10

LABEL maintainer="Oshri Zafrani <oshriza@gmail.com>"
WORKDIR /app
COPY backend/ .
RUN pip install -r requirements.txt
ENTRYPOINT [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000" ]
