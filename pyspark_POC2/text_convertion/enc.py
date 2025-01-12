from Crypto.Cipher import AES
import base64
import os

def encrypt_file(file_path):
    # Define the algorithm and prepare the secret key and initialization vector
    algorithm = 'aes-256-gcm'
    secret_key = b'k92ldahavl97s428vxri7x89seoy79sm'  # 32 bytes for AES-256
    init_vector = b'7dzhcnrb0016hmj3'                  # 16 bytes for AES

    # Create AES cipher object
    cipher = AES.new(secret_key, AES.MODE_GCM, nonce=init_vector)

    # Read the plaintext from the file
    with open(file_path, 'rb') as f:
        plaintext = f.read()

    # Encrypt the plaintext
    ciphertext, auth_tag = cipher.encrypt_and_digest(plaintext)

    # Combine the ciphertext and authentication tag
    encrypted_data = ciphertext + auth_tag

    # Encode the encrypted data in base64
    return base64.b64encode(encrypted_data).decode('utf-8')

def encrypt_all_files_in_folder(input_folder_path, output_folder_path):
    # Create the output folder if it doesn't exist
    if not os.path.exists(output_folder_path):
        os.makedirs(output_folder_path)

    # Loop through all files in the specified input folder
    for filename in os.listdir(input_folder_path):
        file_path = os.path.join(input_folder_path, filename)

        # Check if it is a file (not a directory)
        if os.path.isfile(file_path):
            try:
                # Encrypt the file
                encrypted_data = encrypt_file(file_path)
                
                # Save the encrypted data to a new file in the output folder
                output_file_path = os.path.join(output_folder_path, f'encrypted_{filename}.b64')
                with open(output_file_path, 'w') as output_file:
                    output_file.write(encrypted_data)

                print(f'Successfully encrypted {filename} and saved to {output_file_path}')
            except Exception as e:
                print(f'Encryption failed for {filename}: {str(e)}')

def main():
    # Path to the folder containing files to encrypt
    input_folder_path = "/home/aditya/adithyan/pyspark_POC/text_convertion/plain_text"  # Change this to your input folder path
    output_folder_path = "/home/aditya/adithyan/pyspark_POC/text_convertion/enc_files"  # Change this to your output folder path

    # Check if the input folder exists
    if not os.path.isdir(input_folder_path):
        print(f"The folder {input_folder_path} does not exist.")
        return

    # Encrypt all files in the specified input folder and save to output folder
    encrypt_all_files_in_folder(input_folder_path, output_folder_path)

if __name__ == "__main__":
    main()
