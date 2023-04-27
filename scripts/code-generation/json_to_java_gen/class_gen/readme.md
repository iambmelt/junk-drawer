A simple Java generator in Perl.

To run this program, you can provide two command-line arguments: the filepath to the JSON configuration file, and the output directory where the Java source code files should be written. For example:

```sh
perl generate_java.pl config.json src
```

This will read the config.json file, generate Java source code for each class, and write the resulting files to the src directory.

The JSON configuration file must be formatted according to the following schema:

```json
[
  {
    "name": "MyClass",
    "imports": [
      "java.util.List",
      "java.util.ArrayList"
    ],
    "extends": "ParentClass",
    "implements": [
      "Interface1",
      "Interface2"
    ],
    "constants": [
      {
        "name": "MAX_VALUE",
        "type": "int",
        "value": "100"
      },
      {
        "name": "MY_STRING",
        "type": "String",
        "value": "\"Hello, World!\""
      }
    ],
    "methods": [
      {
        "name": "myMethod",
        "returnType": "void",
        "parameters": [
          {
            "name": "arg1",
            "type": "String"
          },
          {
            "name": "arg2",
            "type": "int"
          }
        ],
        "body": [
          "System.out.println(arg1);",
          "System.out.println(arg2);"
        ]
      }
    ]
  },
  {
    "name": "MyOtherClass",
    "imports": [
      "java.util.Map",
      "java.util.HashMap"
    ],
    "extends": "",
    "implements": [],
    "constants": [],
    "methods": []
  }
]
```

Each object in the array represents a class to be generated. The properties of each object are as follows:

- `name`: The name of the class.
- `imports`: An array of import statements for the class.
- `extends`: The name of the class that this class extends (if any).
- `implements`: An array of the names of the interfaces that this class implements (if any).
- `constants`: An array of objects representing the constants defined in the class. Each object has the properties `name` (the name of the constant), `type` (the type of the constant), and `value` (the value of the constant).
- `methods`: An array of objects representing the methods defined in the class. Each object has the properties `name` (the name of the method), `returnType` (the return type of the method), `parameters` (an array of objects representing the parameters of the method, with properties `name` and `type`), and `body` (an array of strings representing the statements in the body of the method).

The generated Java classes will be written to the specified output directory as separate files, with each file named after the corresponding class name.

## Example usage

Suppose we have a file `config.json` containing the following:

```json
[
  {
    "name": "Person",
    "imports": [
      "java.time.LocalDate"
    ],
    "constants": [
      {
        "name": "MAX_AGE",
        "type": "int",
        "value": "100"
      }
    ],
    "methods": [
      {
        "name": "calculateAge",
        "returnType": "int",
        "parameters": [
          {
            "name": "birthDate",
            "type": "LocalDate"
          }
        ],
        "body": [
          "return LocalDate.now().getYear() - birthDate.getYear();"
        ]
      }
    ]
  }
]
```

We can generate the corresponding Java source code by running the following command:

```
perl json_to_java.pl config.json output_directory/
```

This will generate a Java class file `Person.java` in the `output_directory` containing the following code:

```java
import java.time.LocalDate;

public class Person {

  public static final int MAX_AGE = 100;

  public int calculateAge(LocalDate birthDate) {
    return LocalDate.now().getYear() - birthDate.getYear();
  }

}
``` 

If we update `config.json` to include another class:

```json
[
  {
    "name": "Person",
    "imports": [
      "java.time.LocalDate"
    ],
    "constants": [
      {
        "name": "MAX_AGE",
        "type": "int",
        "value": "100"
      }
    ],
    "methods": [
      {
        "name": "calculateAge",
        "returnType": "int",
        "parameters": [
          {
            "name": "birthDate",
            "type": "LocalDate"
          }
        ],
        "body": [
          "return LocalDate.now().getYear() - birthDate.getYear();"
        ]
      }
    ]
  },
  {
    "name": "Rectangle",
    "imports": [],
    "constants": [
      {
        "name": "DEFAULT_WIDTH",
        "type": "double",
        "value": "1.0"
      },
      {
        "name": "DEFAULT_HEIGHT",
        "type": "double",
        "value": "1.0"
      }
    ],
    "methods": [
      {
        "name": "calculateArea",
        "returnType": "double",
        "parameters": [],
        "body": [
          "return width * height;"
        ]
      }
    ]
  }
]
```

We can generate both Java class files by running the same command:

```
perl json_to_java.pl config.json output_directory/
```

This will generate two Java class files `Person.java` and `Rectangle.java` in the `output_directory`, containing the following code:

```java
// Person.java
import java.time.LocalDate;

public class Person {

  public static final int MAX_AGE = 100;

  public int calculateAge(LocalDate birthDate) {
    return LocalDate.now().getYear() - birthDate.getYear();
  }

}
```

```java
// Rectangle.java
public class Rectangle {

  public static final double DEFAULT_WIDTH = 1.0;
  public static final double DEFAULT_HEIGHT = 1.0;

  public double calculateArea() {
    return width * height;
  }

}
``` 

Note that the generated code may require additional modifications to compile, depending on the specific classes and imports used in the configuration file.
