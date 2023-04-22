import base64
import json
import sys

def decode_token(token):
    # Split the token into header, payload, and signature
    token_parts = token.split('.')
    if len(token_parts) != 3:
        print('Invalid token')
        return

    # Decode the header and payload
    header = base64.urlsafe_b64decode(token_parts[0] + '=' * (-len(token_parts[0]) % 4))
    payload = base64.urlsafe_b64decode(token_parts[1] + '=' * (-len(token_parts[1]) % 4))

    # Print the decoded header and payload as JSON objects
    print('Header:')
    print(json.dumps(json.loads(header.decode('utf-8')), indent=4))
    print('Payload:')
    print(json.dumps(json.loads(payload.decode('utf-8')), indent=4))

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: python decode_token.py <ID Token>')
    else:
        decode_token(sys.argv[1])
