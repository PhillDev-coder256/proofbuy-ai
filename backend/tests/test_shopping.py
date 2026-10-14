import pytest


BRIEF_PAYLOAD = {"brief": "I need a laptop under $1000 with at least 16GB RAM"}


@pytest.mark.asyncio
async def test_post_brief_returns_200(async_client):
    response = await async_client.post("/api/v1/shopping/brief", json=BRIEF_PAYLOAD)
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_post_brief_response_fields(async_client):
    response = await async_client.post("/api/v1/shopping/brief", json=BRIEF_PAYLOAD)
    data = response.json()
    assert "session_id" in data
    assert "status" in data
    assert "message" in data


@pytest.mark.asyncio
async def test_get_session_returns_200(async_client):
    post_response = await async_client.post("/api/v1/shopping/brief", json=BRIEF_PAYLOAD)
    session_id = post_response.json()["session_id"]

    get_response = await async_client.get(f"/api/v1/shopping/{session_id}")
    assert get_response.status_code == 200


@pytest.mark.asyncio
async def test_get_session_fields(async_client):
    post_response = await async_client.post("/api/v1/shopping/brief", json=BRIEF_PAYLOAD)
    session_id = post_response.json()["session_id"]

    get_response = await async_client.get(f"/api/v1/shopping/{session_id}")
    data = get_response.json()
    assert "id" in data
    assert "brief_text" in data
    assert "status" in data
    assert "requirements_json" in data


@pytest.mark.asyncio
async def test_get_session_requirements_not_null(async_client):
    post_response = await async_client.post("/api/v1/shopping/brief", json=BRIEF_PAYLOAD)
    session_id = post_response.json()["session_id"]

    get_response = await async_client.get(f"/api/v1/shopping/{session_id}")
    data = get_response.json()
    assert data["requirements_json"] is not None
