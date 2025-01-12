from flask import Flask, request, jsonify
import os
import base64
import requests
import uuid
import configparser
from Crypto.Cipher import AES

app = Flask(__name__)

config = configparser.ConfigParser()
config.read('config.ini')

SECRET_KEY = config['default']['SECRET_KEY'].encode('utf-8')
INIT_VECTOR = config['default']['INIT_VECTOR'].encode('utf-8')


# Use an environment variable for the temp folder
TEMP_FOLDER = os.getenv('TEMP_FOLDER', '/app/enc_files')
os.makedirs(TEMP_FOLDER, exist_ok=True)

# Use an environment variable for the Converter API URL
CONVERTER_API_URL = os.getenv('CONVERTER_API_URL', 'http://converter_api:5001/convert')

def encrypt_file_content(plaintext):
    try:
        cipher = AES.new(SECRET_KEY, AES.MODE_GCM, nonce=INIT_VECTOR)
        ciphertext, auth_tag = cipher.encrypt_and_digest(plaintext)
        encrypted_data = ciphertext + auth_tag
        return base64.b64encode(encrypted_data).decode('utf-8')
    except Exception as e:
        raise ValueError(f"Encryption failed: {str(e)}")

@app.route('/generate', methods=['POST'])
def generate_encrypted_and_convert():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    try:
        xml_content = file.read()
        encrypted_data = encrypt_file_content(xml_content)

        unique_id = uuid.uuid4()
        encrypted_filename = f"encrypted_{unique_id}.b64"
        encrypted_filepath = os.path.join(TEMP_FOLDER, encrypted_filename)

        with open(encrypted_filepath, 'w') as f:
            f.write(encrypted_data)

        with open(encrypted_filepath, 'rb') as enc_file:
            response = requests.post(CONVERTER_API_URL, files={'file': enc_file})

        if response.status_code == 200:
            return jsonify({
                "message": "File encrypted, sent to converter API, and processed successfully.",
                "converter_response": response.json()
            }), 200
        else:
            return jsonify({
                "error": "Failed to process the encrypted file with the converter API.",
                "converter_response": response.json()
            }), response.status_code

    except ValueError as e:
        return jsonify({"error": str(e)}), 500
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(port=5001, debug=True)
