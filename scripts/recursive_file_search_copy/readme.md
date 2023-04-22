A bash script that accepts a file extension, input directory, and output directory a parameters. The script recursively searches the input directory and copies files of the specified file type to the output directory. The script logs when it skips or copies a file.

To use this script, save it as a file (e.g. `copy_files.sh`) and make it executable (`chmod +x copy_files.sh`). Then, run it with the following command:

```zsh
./copy_files.sh <file extension> <input directory> <output directory>
```