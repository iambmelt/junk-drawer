import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Metadata;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.drew.metadata.exif.ExifThumbnailDirectory;
import com.drew.metadata.file.FileSystemDirectory;
import com.drew.metadata.icc.IccDirectory;
import com.drew.metadata.jpeg.JpegDirectory;
import com.drew.metadata.xmp.XmpDirectory;

public class RemoveExifMetadata {

    public static void main(String[] args) {
        String inputDirectoryPath = "/path/to/input/directory";
        String outputDirectoryPath = "/path/to/output/directory/exif_sanitized";

        File inputDirectory = new File(inputDirectoryPath);
        File outputDirectory = new File(outputDirectoryPath);

        if (!outputDirectory.exists()) {
            outputDirectory.mkdirs();
        }

        if (inputDirectory.isDirectory()) {
            File[] files = inputDirectory.listFiles();
            if (files != null && files.length > 0) {
                List<File> imageFiles = new ArrayList<>();
                for (File file : files) {
                    if (isImageFile(file)) {
                        imageFiles.add(file);
                    }
                }
                if (!imageFiles.isEmpty()) {
                    for (File file : imageFiles) {
                        try {
                            Metadata metadata = ImageMetadataReader.readMetadata(file);
                            removeExifMetadata(metadata);
                            File outputFile = new File(outputDirectory, file.getName());
                            ImageMetadataReader.writeMetadata(metadata, outputFile);
                            System.out.println("Removed EXIF metadata from " + file.getName());
                        } catch (ImageProcessingException | IOException e) {
                            System.err.println("Error processing " + file.getName() + ": " + e.getMessage());
                        }
                    }
                } else {
                    System.out.println("No image files found in directory " + inputDirectoryPath);
                }
            } else {
                System.out.println("Directory " + inputDirectoryPath + " is empty");
            }
        } else {
            System.out.println("Invalid input directory path: " + inputDirectoryPath);
        }
    }

    private static boolean isImageFile(File file) {
        String fileName = file.getName().toLowerCase();
        return fileName.endsWith(".jpg") || fileName.endsWith(".jpeg") || fileName.endsWith(".png");
    }

    private static void removeExifMetadata(Metadata metadata) {
        metadata.removeDirectory(ExifIFD0Directory.class);
        metadata.removeDirectory(ExifSubIFDDirectory.class);
        metadata.removeDirectory(ExifThumbnailDirectory.class);
        metadata.removeDirectory(FileSystemDirectory.class);
        metadata.removeDirectory(IccDirectory.class);
        metadata.removeDirectory(JpegDirectory.class);
        metadata.removeDirectory(XmpDirectory.class);
    }
}
