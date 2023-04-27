import os
import json

def walkdir(dir_path):
    # Create a list to hold the directory contents
    contents = []
    
    # Loop over the files and directories in the current directory
    for name in os.listdir(dir_path):
        # Construct the full path to the file or directory
        path = os.path.join(dir_path, name)
        
        # Get the file or directory metadata
        stats = os.stat(path)
        
        # If the path is a directory, recurse into it
        if os.path.isdir(path):
            contents.append({
                'type': 'directory',
                'name': name,
                'path': path,
                'size': stats.st_size,
                'created': stats.st_ctime,
                'modified': stats.st_mtime,
                'contents': walkdir(path),
            })
        # Otherwise, add the file metadata to the contents list
        else:
            contents.append({
                'type': 'file',
                'name': name,
                'path': path,
                'size': stats.st_size,
                'created': stats.st_ctime,
                'modified': stats.st_mtime,
            })
    
    # Return the list of contents for this directory
    return contents

# Prompt the user for a directory path
dir_path = input('Enter a directory path: ')

# Recursively traverse the directory and get the contents
contents = walkdir(dir_path)

# Convert the contents to JSON and output it
print(json.dumps(contents, indent=2))
