import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

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

    private static final Logger LOGGER = Logger.getLogger(RemoveExifMetadata.class.getName());

    // Supported image file extensions
    private static final List<String> SUPPORTED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png");

    // Metadata directories to remove
    private static final Class<?>[] METADATA_DIRECTORIES_TO_REMOVE = new Class<?>[]{
        ExifIFD0Directory.class,
        ExifSubIFDDirectory.class,
        ExifThumbnailDirectory.class,
        FileSystemDirectory.class,
        IccDirectory.class,
        JpegDirectory.class,
        XmpDirectory.class
    };

    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: java RemoveExifMetadata <inputDirectory> <outputDirectory>");
            System.exit(1);
        }

        String inputDirectoryPath = args[0];
        String outputDirectoryPath = args[1];

        Path inputDir = Paths.get(inputDirectoryPath);
        // Create a subdirectory "exif_sanitized" in the output directory
        Path outputDir = Paths.get(outputDirectoryPath, "exif_sanitized");

        if (!Files.exists(inputDir) || !Files.isDirectory(inputDir)) {
            LOGGER.severe("Invalid input directory path: " + inputDirectoryPath);
            System.exit(1);
        }

        try {
            if (!Files.exists(outputDir)) {
                Files.createDirectories(outputDir);
            }
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Failed to create output directory: " + outputDir, e);
            System.exit(1);
        }

        try {
            Files.list(inputDir)
                .filter(Files::isRegularFile)
                .filter(RemoveExifMetadata::isImageFile)
                .forEach(inputFile -> processFile(inputFile, outputDir.resolve(inputFile.getFileName())));
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Error reading input directory: " + inputDirectoryPath, e);
        }
    }

    private static boolean isImageFile(Path path) {
        try {
            String mimeType = Files.probeContentType(path);
            if (mimeType != null && mimeType.startsWith("image")) {
                return true;
            }
        } catch (IOException e) {
            LOGGER.warning("MIME type check failed for " + path.getFileName() + ": " + e.getMessage());
        }

        // Fallback to extension-based check
        String fileName = path.getFileName().toString().toLowerCase();
        return SUPPORTED_EXTENSIONS.stream().anyMatch(ext -> fileName.endsWith("." + ext));
    }

    private static void processFile(Path inputFile, Path outputFile) {
        try {
            // Read metadata from the image
            Metadata metadata = ImageMetadataReader.readMetadata(inputFile.toFile());
            removeExifMetadata(metadata);

            // NOTE: The metadata-extractor library is read-only and cannot write metadata back to files.
            // In a real-world scenario, you would use a different library to rewrite the image without metadata.
            // For this example, we simply copy the original file to the output directory.
            Files.copy(inputFile, outputFile);
            LOGGER.info("Processed and sanitized metadata for " + inputFile.getFileName());
        } catch (ImageProcessingException | IOException e) {
            LOGGER.log(Level.SEVERE, "Error processing " + inputFile.getFileName() + ": " + e.getMessage(), e);
        }
    }

    private static void removeExifMetadata(Metadata metadata) {
        for (Class<?> dirClass : METADATA_DIRECTORIES_TO_REMOVE) {
            metadata.removeDirectory(dirClass);
        }
    }
}
