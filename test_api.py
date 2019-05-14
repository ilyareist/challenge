import json
import pytest
from app import app
import re


@pytest.fixture
def client(request):
    test_client = app.test_client()

    def teardown():
        pass  

    request.addfinalizer(teardown)
    return test_client


def test_add(client):
    response = client.put('/hello/Tanya', data=json.dumps({'dateOfBirth': '1994-04-18'}),
                          content_type='application/json')
    assert response.status_code == 204


def test_get():
    response = app.test_client().get(
        '/hello/Tanya',
    )
    assert response.status_code == 200
    assert re.match('^Hello, Tanya!', response.json['message'])
