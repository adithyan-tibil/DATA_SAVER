from Crypto.Cipher import AES
import base64
import os

def decrypt_file(file_path):
    # Define the algorithm and prepare the secret key and initialization vector
    algorithm = 'aes-256-gcm'
    secret_key = b'k92ldahavl97s428vxri7x89seoy79sm'  # 32 bytes for AES-256
    init_vector = b'7dzhcnrb0016hmj3'                  # 16 bytes for AES

    # Read the encrypted data from the file
    with open(file_path, 'r') as f:
        encrypted_data_b64 = f.read()

    # Decode the base64-encoded data
    encrypted_data = base64.b64decode(encrypted_data_b64)

    # Split the encrypted data into ciphertext and auth_tag
    auth_tag = encrypted_data[-16:]  # Last 16 bytes are the auth tag
    ciphertext = encrypted_data[:-16]  # The rest is the ciphertext

    # Create AES cipher object
    cipher = AES.new(secret_key, AES.MODE_GCM, nonce=init_vector)

    # Decrypt the data and verify
    decrypted = cipher.decrypt_and_verify(ciphertext, auth_tag)

    return decrypted

def decrypt_all_files_in_folder(input_folder_path, output_folder_path):
    # Create the output folder if it doesn't exist
    if not os.path.exists(output_folder_path):
        os.makedirs(output_folder_path)

    # Loop through all files in the specified input folder
    for filename in os.listdir(input_folder_path):
        file_path = os.path.join(input_folder_path, filename)

        # Check if it is a file (not a directory) and has the expected encrypted filename
        if os.path.isfile(file_path) and filename.startswith('encrypted_') and filename.endswith('.b64'):
            try:
                # Decrypt the file
                decrypted_data = decrypt_file(file_path)
                
                # Save the decrypted data to a new file in the output folder
                output_file_path = os.path.join(output_folder_path, filename.replace('encrypted_', ''))
                with open(output_file_path, 'wb') as output_file:
                    output_file.write(decrypted_data)

                print(f'Successfully decrypted {filename} and saved to {output_file_path}')
            except Exception as e:
                print(f'Decryption failed for {filename}: {str(e)}')

def main():
    # Path to the folder containing encrypted files
    input_folder_path = "/home/aditya/adithyan/pyspark_POC/sample3_xml/input"  # Change this to your encrypted folder path
    output_folder_path = "/home/aditya/adithyan/pyspark_POC/sample3_xml/output"  # Change this to your decrypted folder path

    # Check if the input folder exists
    if not os.path.isdir(input_folder_path):
        print(f"The folder {input_folder_path} does not exist.")
        return

    # Decrypt all files in the specified input folder and save to output folder
    decrypt_all_files_in_folder(input_folder_path, output_folder_path)

if __name__ == "__main__":
    main()
