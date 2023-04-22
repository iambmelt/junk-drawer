A simple Java program to redeem an authorization code from the Azure v2 endpoint for a public client.

Use the code grant_type. Allow the authorization code, scope, redirect_uri, and client id to be passed in from String[] args to the main method.

Use it

```sh
# Compile
javac AuthCodeRedeemer.java

# Run it
java AuthCodeRedeemer --client-id <client-id> --redirect-uri <redirect-uri> --scope <scope> --auth-code <auth-code>
```