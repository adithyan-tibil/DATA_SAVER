import pytest
import base64
import requests
from Crypto.Cipher import AES
# from testcases.src.main.decrypter import app

# Test Configurations
SECRET_KEY = b'k92ldahavl97s428vxri7x89seoy79sm'
INIT_VECTOR = b'7dzhcnrb0016hmj3'

# Helper function to generate encrypted data
def get_valid_encrypted_data(original_data="Sample text"):
    cipher = AES.new(SECRET_KEY, AES.MODE_GCM, nonce=INIT_VECTOR)
    ciphertext, auth_tag = cipher.encrypt_and_digest(original_data.encode())
    encrypted_data = ciphertext + auth_tag
    return base64.b64encode(encrypted_data).decode('utf-8')

BASE_URL = 'http://127.0.0.1:5000/decrypt'


# **Configuration Test Cases**
#
# # Test Case 1: Missing SECRET_KEY in Config
# def test_missing_secret_key(monkeypatch):
#     monkeypatch.setattr('config["secrets"].get', lambda key: None if key == "SECRET_KEY" else INIT_VECTOR)
#     response = requests.post(BASE_URL, json={'data': get_valid_encrypted_data()})
#     assert response.status_code == 500
#
# # Test Case 2: Missing INIT_VECTOR in Config
# def test_missing_init_vector(monkeypatch):
#     monkeypatch.setattr('config["secrets"].get', lambda key: None if key == "INIT_VECTOR" else SECRET_KEY)
#     response = requests.post(BASE_URL, json={'data': get_valid_encrypted_data()})
#     assert response.status_code == 500
#
# # Test Case 3: Incorrect Key Length
# def test_incorrect_key_length(monkeypatch):
#     monkeypatch.setattr('config["secrets"].get', lambda key: b'short' if key == "SECRET_KEY" else INIT_VECTOR)
#     response = requests.post(BASE_URL, json={'data': get_valid_encrypted_data()})
#     assert response.status_code == 500


# **Input Validation Test Cases**

# Test Case 4: Missing 'data' field
def test_missing_data_field():
    response = requests.post(BASE_URL, json={})
    assert response.status_code == 400
    assert response.json() == {"error": "Data not provided. Please include 'data' in the request."}

# Test Case 5: Empty 'data' field
def test_empty_data_field():
    response = requests.post(BASE_URL, json={'data': ''})
    assert response.status_code == 400

# Test Case 6: Non-string 'data' field
def test_non_string_data_field():
    response = requests.post(BASE_URL, json={'data': 12345})
    assert response.status_code == 400

# Test Case 7: Malformed JSON
def test_malformed_json():
    response = requests.post(BASE_URL, data='{"data": invalid}')
    assert response.status_code == 500

# Test Case 8: Invalid Base64 Encoding
def test_invalid_base64_encoding():
    response = requests.post(BASE_URL, json={'data': 'InvalidBase64!'})
    assert response.status_code == 400

# Test Case 9: Valid Base64 but Short Encrypted Data
def test_short_encrypted_data():
    response = requests.post(BASE_URL, json={'data': base64.b64encode(b'short').decode('utf-8')})
    assert response.status_code == 400


# **Decryption Logic Test Cases**

# Test Case 10: Valid Encrypted Data
def test_valid_encrypted_data():
    valid_data = get_valid_encrypted_data("Decrypt me")
    response = requests.post(BASE_URL, json={'data': valid_data})
    assert response.status_code == 200
    assert 'data' in response.json()
    assert response.json()['data'] == "Decrypt me"

# Test Case 11: Incorrect Authentication Tag
def test_incorrect_auth_tag():
    valid_data = get_valid_encrypted_data("Incorrect auth tag")
    tampered_data = base64.b64encode(base64.b64decode(valid_data)[:-1] + b'0').decode('utf-8')
    response = requests.post(BASE_URL, json={'data': tampered_data})
    assert response.status_code == 400

# Test Case 12: Very Large Data Input
def test_large_data_input():
    original_data = "A" * 5000  # Large string
    valid_data = get_valid_encrypted_data(original_data)
    response = requests.post(BASE_URL, json={'data': valid_data})
    assert response.status_code == 200
    assert response.json()['data'] == original_data

# Test Case 13: Encrypted Data with Special Characters
def test_special_characters():
    original_data = "Data with special characters !@#"
    valid_data = get_valid_encrypted_data(original_data)
    response = requests.post(BASE_URL, json={'data': valid_data})
    assert response.status_code == 200
    assert response.json()['data'] == original_data

# Test Case 14: Non-UTF8 Data
def test_non_utf8_data():
    non_utf8_data = bytes([0xff, 0xfe, 0xfd])
    response = requests.post(BASE_URL, json={'data': base64.b64encode(non_utf8_data).decode('utf-8')})
    assert response.status_code == 400


# **Edge Case Tests**

# Test Case 15: Base64 with Newline Characters
def test_base64_with_newlines():
    valid_data = get_valid_encrypted_data()
    valid_data_with_newlines = valid_data.replace('=', '=\n')
    response = requests.post(BASE_URL, json={'data': valid_data_with_newlines})
    assert response.status_code == 200

# Test Case 16: GET Request instead of POST
def test_get_request():
    response = requests.get(BASE_URL)
    assert response.status_code == 405

# Test Case 17: Invalid Content-Type Header
def test_invalid_content_type():
    valid_data = get_valid_encrypted_data()
    response = requests.post(BASE_URL, data=f'data={valid_data}')
    assert response.status_code == 500

# Test Case 18: JSON with Additional Fields
def test_extra_json_fields():
    valid_data = get_valid_encrypted_data("Extra field data")
    response = requests.post(BASE_URL, json={'data': valid_data, 'extra_field': 'extra'})
    assert response.status_code == 200
    assert response.json()['data'] == "Extra field data"

# Test Case 19: Special Characters in JSON Key
def test_special_json_key():
    valid_data = get_valid_encrypted_data()
    response = requests.post(BASE_URL, json={'data@#$%^&*': valid_data})
    assert response.status_code == 400

# Test Case 20: Very Long JSON Key
def test_long_json_key():
    valid_data = get_valid_encrypted_data()
    long_key = 'data_' + 'x' * 1000  # Very long key name
    response = requests.post(BASE_URL, json={long_key: valid_data})
    assert response.status_code == 400
