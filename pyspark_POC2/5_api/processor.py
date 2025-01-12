# from flask import Flask, request, jsonify
# import requests
#
# app = Flask(__name__)
#
# DECRYPTOR_API_URL = 'http://localhost:5001/decrypt'  # Decryptor API URL
# TRANSFORMER_API_URL = 'http://localhost:5002/transform'  # Transformer API URL
# ENCRYPT_API_URL = 'http://localhost:5003/encrypt'  # Encryptor API URL
#
# @app.route('/process', methods=['POST'])
# def process_data():
#     try:
#         # Get input data from the request
#         input_data = request.json.get('data')
#         input_type = request.json.get('input_type')
#         output_type = request.json.get('output_type')
#
#         if not input_data or not input_type or not output_type:
#             return jsonify({"error": "Missing input data, input_type, or output_type"}), 400
#
#         #Decryptor API
#         decrypt_payload = {
#             "data": input_data
#         }
#         decrypt_response = requests.post(DECRYPTOR_API_URL, json=decrypt_payload)
#
#         if decrypt_response.status_code != 200:
#             return jsonify({"error": "Failed to decrypt data", "details": decrypt_response.text}), 500
#
#         decrypted_data = decrypt_response.json()['data']
#         print("Decrypted Data:", decrypted_data)
#
#         #Transformer API
#         transform_payload = {
#             "input_type": input_type,
#             "output_type": output_type,
#             "data": decrypted_data
#         }
#         transform_response = requests.post(TRANSFORMER_API_URL, json=transform_payload)
#
#         if transform_response.status_code != 200:
#             return jsonify({"error": "Failed to transform data", "details": transform_response.text}), 500
#
#         transformed_data = transform_response.json()['data']
#         print("Transformed Data:", transformed_data)
#
#        # Encryptor API
#         encrypt_payload = {
#             "data": transformed_data
#         }
#         encrypt_response = requests.post(ENCRYPT_API_URL, json=encrypt_payload)
#
#         if encrypt_response.status_code != 200:
#             return jsonify({"error": "Failed to encrypt transformed data", "details": encrypt_response.text}), 500
#
#         encrypted_data = encrypt_response.json()['encrypted_data']
#         print("Encrypted Data:", encrypted_data)
#
#         # Return the response
#         return jsonify({
#             "decrypted_data": decrypted_data,
#             "transformed_data": transformed_data,
#             "encrypted_data": encrypted_data,
#             # "input_type": input_type,
#             # "output_type": output_type
#         }), 200
#
#     except Exception as e:
#         return jsonify({"error": f"An error occurred: {str(e)}"}), 500
#
# if __name__ == '__main__':
#     app.run(port=5004, debug=True)




from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

DECRYPTOR_API_URL = 'http://localhost:5001/decrypt'
TRANSFORMER_API_URL = 'http://localhost:5002/transform'
ENCRYPT_API_URL = 'http://localhost:5003/encrypt'


transformers = ['xml_to_json', 'json_to_xml', 'text_to_json', 'xml_to_text', 'json_to_text']

@app.route('/process', methods=['POST'])
def process_data():
    try:
        # Get input data and transformer from the request
        input_data = request.json.get('data')
        transformer_key = request.json.get('transformer')

        if not input_data or not transformer_key:
            return jsonify({"error": "Missing data or transformer key"}), 400

        # Check if the transformer key is valid
        if transformer_key not in transformers:
            return jsonify({"error": f"Invalid transformer key. Must be one of {transformers}"}), 400

        # Call Decryptor API
        decrypt_payload = {
            "data": input_data
        }
        decrypt_response = requests.post(DECRYPTOR_API_URL, json=decrypt_payload)

        if decrypt_response.status_code != 200:
            return jsonify({"error": "Failed to decrypt data", "details": decrypt_response.text}), 500

        decrypted_data = decrypt_response.json()['data']
        print("Decrypted Data:", decrypted_data)

        # Call Transformer API with the transformer key
        transform_payload = {
            "transformer": transformer_key,
            "data": decrypted_data
        }
        transform_response = requests.post(TRANSFORMER_API_URL, json=transform_payload)

        if transform_response.status_code != 200:
            return jsonify({"error": "Failed to transform data", "details": transform_response.text}), 500

        transformed_data = transform_response.json()['data']
        print("Transformed Data:", transformed_data)

        # Call Encryptor API
        encrypt_payload = {
            "data": transformed_data
        }
        encrypt_response = requests.post(ENCRYPT_API_URL, json=encrypt_payload)

        if encrypt_response.status_code != 200:
            return jsonify({"error": "Failed to encrypt transformed data", "details": encrypt_response.text}), 500

        encrypted_data = encrypt_response.json()['encrypted_data']
        print("Encrypted Data:", encrypted_data)

        # Return the response
        return jsonify({
            "encrypted_data": encrypted_data,
            "decrypted_data": decrypted_data,
            "transformed_data": transformed_data,
        }), 200

    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500

if __name__ == '__main__':
    app.run(port=5004, debug=True)