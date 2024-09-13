import javax.microedition.io.Connector;
import javax.microedition.io.StreamConnection;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;

public class OBD2BluetoothReader {

    // Buffer size = 8KB
    private static final int BUFFER_SIZE = 8192;

    private final StreamConnection streamConnection;
    private final BufferedWriter writer;
    private final BufferedReader reader;

    // Establish Bluetooth connection to the OBD-II adapter using Bluetooth address
    public OBD2BluetoothReader(final String btAddress) throws IOException {
        // Open a Bluetooth connection using BlueCove's Connector
        final String url = "btspp://" 
            + btAddress 
            + ":1;authenticate=false;encrypt=false;master=false";

        streamConnection = (StreamConnection) Connector.open(url);
        
        // Set up input/output streams with a defined buffer size
        writer = new BufferedWriter(
            new OutputStreamWriter(
                streamConnection.openOutputStream()
            ), BUFFER_SIZE
        );
        
        reader = new BufferedReader(
            new InputStreamReader(
                streamConnection.openInputStream()
            ), 
            BUFFER_SIZE
        );
        
        initializeELM327();
    }

    // Initialize the ELM327 OBD-II adapter with standard commands
    private void initializeELM327() throws IOException {
        // Send common initialization commands in one batch
        StringBuilder initCommands = new StringBuilder();
        initCommands.append("ATZ\r");   // Reset ELM327
        initCommands.append("ATE0\r");  // Echo Off
        initCommands.append("ATL0\r");  // Linefeeds Off
        initCommands.append("ATS0\r");  // Spaces Off
        initCommands.append("ATH1\r");  // Headers On
        initCommands.append("ATSP0\r"); // Auto protocol select
        
        // Write all initialization commands at once and flush
        writer.write(initCommands.toString());
        writer.flush();
    }

    // Send a command to the ELM327 device
    private void sendCommand(final String command) throws IOException {
        // Append a newline character and send the command
        writer.write(command + "\r");
        writer.flush(); // Only flush after all commands are written to reduce unnecessary flushes
    }

    // Read the response from the ELM327 device efficiently
    private String readResponse() throws IOException {
        final StringBuilder response = new StringBuilder(1024); // Pre-size for better memory usage
        String line;
        while ((line = reader.readLine()) != null) {
            if (line.equals(">")) { // End of response marker
                break;
            }
            response.append(line).append("\n");
        }
        return response.toString().trim(); // Return trimmed output to avoid extra whitespace
    }

    // Request trouble codes (DTC)
    public String readDTC() throws IOException {
        sendCommand("03"); // Request DTC codes
        return readResponse();
    }

    // Close Bluetooth connection and streams properly
    public void close() {
        try {
            if (streamConnection != null) {
                streamConnection.close();
            }
            if (writer != null) {
                writer.close();
            }
            if (reader != null) {
                reader.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void main(final String[] args) {
        // Check if Bluetooth address is passed as an argument
        if (args.length < 1) {
            System.out.println("Please provide the Bluetooth address of the OBD-II adapter.");
            System.out.println("Usage: java OBD2BluetoothReader <Bluetooth Address>");
            return;
        }

        final String btAddress = args[0]; // Get the Bluetooth address from command-line argument

        OBD2BluetoothReader obd2Reader = null;
        try {
            obd2Reader = new OBD2BluetoothReader(btAddress);
            final String dtc = obd2Reader.readDTC();

            System.out.println("Diagnostic Trouble Codes (DTC):");
            System.out.println(dtc);
        } catch (final IOException e) {
            e.printStackTrace();
        } finally {
            if (obd2Reader != null) {
                obd2Reader.close(); // Ensure resources are closed in the finally block
            }
        }
    }
}
