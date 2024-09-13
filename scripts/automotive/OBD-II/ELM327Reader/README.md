# OBD2BluetoothReader
## Overview
This Java utility interfaces with an OBD-II adapter over a Bluetooth connection. This utility allows you to retrieve Diagnostic Trouble Codes (DTCs) from your vehicle's OBD-II system. It supports basic initialization commands for the ELM327 OBD-II adapter and provides functionality to read trouble codes.

### Prerequisites

- Java Development Kit (JDK) 8 or later.
- A Bluetooth-enabled OBD-II adapter that uses the ELM327 protocol.
- Bluetooth drivers and libraries configured for your development environment.

### Installation
- Clone the repository or download the source code
- Compile the Java source code:
- Run the utility with the Bluetooth address of your OBD-II adapter:

```sh
java OBD2BluetoothReader <Bluetooth Address>
```

### Usage
To use this utility, provide the Bluetooth address of your OBD-II adapter as a command-line argument. For example:

```sh
java OBD2BluetoothReader 00:1A:7D:DA:71:13
```

### Expected Output

If the connection is successful and the OBD-II adapter is functioning correctly, you will see the Diagnostic Trouble Codes (DTCs) printed in the console. If there are no trouble codes, the output may be empty.
Code Structure

```
    OBD2BluetoothReader.java: Main class file containing the utility's logic and methods.
        Constructor: Establishes a Bluetooth connection with the provided address and initializes the OBD-II adapter.
        initializeELM327(): Sends standard initialization commands to the ELM327 adapter.
        sendCommand(String command): Sends a specific command to the adapter.
        readResponse(): Reads the response from the adapter.
        readDTC(): Requests and retrieves Diagnostic Trouble Codes.
        close(): Closes the Bluetooth connection and streams.
```

## Example

```sh
java OBD2BluetoothReader 00:1A:7D:DA:71:13

Diagnostic Trouble Codes (DTC):
P0128
P0455
```
