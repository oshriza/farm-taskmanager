from fastapi import FastAPI
from fastapi.testclient import TestClient
from main import app

# app = FastAPI()

client = TestClient(app)

data = {
    "title": "test",
    "description": "test description"
}

# @app.get("/")
# async def read_main():
#     return {"msg": "Hello World"}



def test_read_main():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"Hello": "World"}

# def test_get_todo():
#     response = client.get("http://localhost/api/todo", json=data)
#     assert response.status_code == 200
#     assert response.json() == data

# def test_create_todo():
#     response = client.post("/api/todo/", json=data)
#     assert response.status_code == 200
#     assert response.json() == data
