A simple Java generator in Perl.

To run this program, you can provide two command-line arguments: the filepath to the JSON configuration file, and the output directory where the Java source code files should be written. For example:

```sh
perl generate_java.pl config.json src
```

This will read the config.json file, generate Java source code for each class, and write the resulting files to the src directory.
