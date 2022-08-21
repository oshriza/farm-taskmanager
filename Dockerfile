FROM python
WORKDIR /app
COPY backend/ .
RUN pip install -r requirements.txt
ENTRYPOINT [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload" ]
# ENTRYPOINT [ "sleep", "infinity" ]
# uvicorn main:app --reload
# uvicorn main:app --port 8080 --reload