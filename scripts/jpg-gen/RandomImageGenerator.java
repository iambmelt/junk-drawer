import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Random;

import javax.imageio.ImageIO;

public class RandomImageGenerator {

    public static void main(String[] args) {

        // Create a new BufferedImage object with dimensions 600x800 and type RGB
        BufferedImage image = new BufferedImage(600, 800, BufferedImage.TYPE_INT_RGB);

        // Get the Graphics2D object to draw on the image
        Graphics2D g2d = image.createGraphics();

        // Set the background color to white
        g2d.setColor(Color.WHITE);
        g2d.fillRect(0, 0, 600, 800);

        // Generate random pixels
        Random random = new Random();
        for (int x = 0; x < 600; x++) {
            for (int y = 0; y < 800; y++) {
                // Generate a random color
                Color color = new Color(random.nextInt(256), random.nextInt(256), random.nextInt(256));
                // Set the pixel color
                image.setRGB(x, y, color.getRGB());
            }
        }

        // Save the image as a jpg file
        try {
            File outputfile = new File("random-image.jpg");
            ImageIO.write(image, "jpg", outputfile);
        } catch (IOException e) {
            System.out.println("Error: " + e.getMessage());
        }

        // Dispose of the Graphics2D object
        g2d.dispose();

    }

}
