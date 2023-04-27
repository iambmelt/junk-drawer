The script will prompt you to enter a directory path. Once you enter the path, the script will recursively traverse the directory and construct a JSON document describing its contents. Each item in the document includes the file or directory name, path, size, creation time, and modification time. Directories also include a nested list of their contents.

Note that this script does not include file contents in the JSON document. If you want to include file contents, you will need to modify the script to read the contents of each file and add them to the JSON document. Be aware that this can make the JSON document very large if the directory contains many files.

```
python directory_to_json.py
```

Sample output:

```json
Enter a directory path: /home/user/Documents

[
  {
    "type": "directory",
    "name": "project1",
    "path": "/home/user/Documents/project1",
    "size": 4096,
    "created": 1618584155.0,
    "modified": 1621438177.0891745,
    "contents": [
      {
        "type": "file",
        "name": "file1.txt",
        "path": "/home/user/Documents/project1/file1.txt",
        "size": 284,
        "created": 1621438177.0891745,
        "modified": 1621438177.0891745
      },
      {
        "type": "file",
        "name": "file2.py",
        "path": "/home/user/Documents/project1/file2.py",
        "size": 1234,
        "created": 1621438177.0891745,
        "modified": 1621438177.0891745
      }
    ]
  },
  {
    "type": "file",
    "name": "document.pdf",
    "path": "/home/user/Documents/document.pdf",
    "size": 1048576,
    "created": 1618584155.0,
    "modified": 1621438177.0891745
  }
]
```
