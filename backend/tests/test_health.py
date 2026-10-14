import pytest


@pytest.mark.asyncio
async def test_health_returns_200(async_client):
    response = await async_client.get("/health")
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_health_status_ok(async_client):
    response = await async_client.get("/health")
    data = response.json()
    assert data["status"] == "ok"


@pytest.mark.asyncio
async def test_health_has_version(async_client):
    response = await async_client.get("/health")
    data = response.json()
    assert "version" in data


@pytest.mark.asyncio
async def test_health_has_environment(async_client):
    response = await async_client.get("/health")
    data = response.json()
    assert "environment" in data
