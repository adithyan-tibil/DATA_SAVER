import os

# Define the directory for input files
input_directory = '/home/aditya/adithyan/pyspark_POC/example_files'

# Create the input directory if it doesn't exist
os.makedirs(input_directory, exist_ok=True)

# Generate 10 example text files
for i in range(10):
    file_path = os.path.join(input_directory, f'example_file_{i + 1}.txt')
    with open(file_path, 'w') as f:
        f.write(f'This is example file number {i + 1}.\n')
        f.write('This file is used for testing the PySpark streaming application.\n')

print(f"Created 10 example text files in '{input_directory}'")
