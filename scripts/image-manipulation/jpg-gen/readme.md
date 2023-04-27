This program creates a new BufferedImage object with dimensions `600x800` and type `RGB`. It then gets the Graphics2D object to draw on the image and sets the background color to white. The program generates random pixels by looping through each pixel and generating a random color. It sets the color of each pixel using the setRGB method. Finally, the program saves the image as a `jpg` file named `random-image.jpg`.

Compile it:

```sh
javac RandomImageGenerator.java
```

Run it:

```sh
java RandomImageGenerator
```
