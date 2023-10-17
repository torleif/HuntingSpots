import os
import subprocess

# Specify the main folder containing PNG files and subfolders
main_folder = '14'

# Define the path to rdopng.exe
rdopng_exe = 'rdopng.exe'

# Function to process a batch of files
def process_files(file_paths):
    for file_path in file_paths:
        options = '-level 3 -lambda 1000'
        # Build the command
        command = [rdopng_exe, options,file_path, '-output', file_path]

        # Join the command list into a single string
        command_str = ' '.join(command)

        # Print a message for the file being processed
        print(f'Processing file: {file_path}')

        # Run the command using subprocess and capture output
        result = subprocess.run(command_str, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Print the output and error messages, if any
        print('Output:', result.stdout)
        print('Errors:', result.stderr)

# Recursively traverse the directory tree and process files in batches
batch_size = 10  # Adjust this to a suitable batch size
file_paths = []
for root, dirs, files in os.walk(main_folder):
    for file in files:
        if file.endswith('.png'):
            # Get the full path to the PNG file
            png_file_path = os.path.join(root, file)
            file_paths.append(png_file_path)
            if len(file_paths) >= batch_size:
                process_files(file_paths)
                file_paths = []

# Process any remaining files
if file_paths:
    process_files(file_paths)

print('Conversion completed.')