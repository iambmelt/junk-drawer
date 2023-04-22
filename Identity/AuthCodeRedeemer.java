import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * A simple Java program to redeem an authorization code from the Azure v2 endpoint for a public client.
 */
public class AuthCodeRedeemer {

    /**
     * Main method to redeem an authorization code from the Azure v2 endpoint for a public client.
     *
     * @param args the command-line arguments
     * @throws Exception if an error occurs while redeeming the authorization code
     */
    public static void main(String[] args) throws Exception {
        if (args.length == 0 || args[0].equals("--help")) {
            printUsage();
            return;
        }

        String clientId = null;
        String redirectUri = null;
        String scope = null;
        String authCode = null;

        for (int i = 0; i < args.length; i += 2) {
            String name = args[i];
            String value = args[i + 1];

            switch (name) {
                case "--client-id":
                    clientId = value;
                    break;
                case "--redirect-uri":
                    redirectUri = value;
                    break;
                case "--scope":
                    scope = value;
                    break;
                case "--auth-code":
                    authCode = value;
                    break;
                default:
                    throw new IllegalArgumentException("Unknown option: " + name);
            }
        }

        if (clientId == null || redirectUri == null || scope == null || authCode == null) {
            throw new IllegalArgumentException("Missing one or more required options.");
        }

        String tokenEndpoint = "https://login.microsoftonline.com/common/oauth2/v2.0/token";
        String grantType = "authorization_code";
        String postData = String.format("grant_type=%s&client_id=%s&redirect_uri=%s&scope=%s&code=%s",
                URLEncoder.encode(grantType, StandardCharsets.UTF_8),
                URLEncoder.encode(clientId, StandardCharsets.UTF_8),
                URLEncoder.encode(redirectUri, StandardCharsets.UTF_8),
                URLEncoder.encode(scope, StandardCharsets.UTF_8),
                URLEncoder.encode(authCode, StandardCharsets.UTF_8));

        HttpURLConnection connection = null;

        try {
            URL url = new URL(tokenEndpoint);
            connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            connection.setDoOutput(true);
            connection.getOutputStream().write(postData.getBytes(StandardCharsets.UTF_8));

            if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                throw new IOException("HTTP error " + connection.getResponseCode() + ": " + connection.getResponseMessage());
            }

            try (BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                StringBuilder responseBuilder = new StringBuilder();
                String line;
                while ((line = in.readLine()) != null) {
                    responseBuilder.append(line);
                }
                System.out.println(responseBuilder.toString());
            }

        } catch (IOException ex) {
            System.err.println("Failed to redeem authorization code: " + ex.getMessage());
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    /**
     * Prints the usage instructions for the program.
     */
    private static void printUsage() {
        System.out.println("Usage: java AzureAuthCodeRedeemer --client-id <client-id> --redirect-uri <redirect-uri> --scope <scope> --auth-code <auth-code>");
    }
}
