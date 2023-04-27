# Removing Sensitive EXIF Metadata from Pictures

This Java program allows you to remove sensitive EXIF metadata from all pictures in a directory using the metadata-extractor library. The modified files are then saved to a new directory called `exif_sanitized`.

## Prerequisites

- Java 8 or later installed on your system.
- The metadata-extractor library added to your project. You can add it using Maven or by downloading the JAR file from the library's website.

## Usage

1. Download the `RemoveExifMetadata.java` file from this repository and add it to your project directory.

2. Modify the `inputDirectoryPath` and `outputDirectoryPath` variables in the `main` method to specify the paths to the directory containing the pictures you want to sanitize and the directory where you want to save the modified files.

   ```java
   String inputDirectoryPath = "/path/to/input/directory";
   String outputDirectoryPath = "/path/to/output/directory/exif_sanitized";
   ```

3. Compile and run the program using your preferred method. For example, you can use the `javac` and `java` commands in a terminal:

   ```
   javac RemoveExifMetadata.java
   java RemoveExifMetadata
   ```

4. The program will iterate over all pictures in the specified directory and remove sensitive EXIF metadata. The modified files will be saved to the `exif_sanitized` directory.

   ```
   Removed EXIF metadata from image1.jpg
   Removed EXIF metadata from image2.png
   ...
   ```

## Notes

- The program only removes certain types of metadata that may be sensitive, such as GPS coordinates, camera model, and date/time of creation. Other metadata, such as image resolution and color profile, may still be present in the modified files.
- The program currently supports JPG, JPEG, and PNG image formats. Other formats may not be processed correctly.
- If the output directory does not exist, the program will create it.
- If there are any errors processing an image file, the program will output an error message and continue processing the remaining files.