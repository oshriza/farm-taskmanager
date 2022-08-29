# Official base image of FastApi framework (100MB)
FROM tiangolo/uvicorn-gunicorn:python3.8-alpine3.10

LABEL maintainer="Oshri Zafrani <oshriza@gmail.com>"
WORKDIR /app
COPY backend/ .
RUN pip install -r requirements.txt
ENTRYPOINT [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000" ]
