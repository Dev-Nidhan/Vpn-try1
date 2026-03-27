# TinyVPN - Encrypted Configuration Generator

This utility helps generate encrypted configuration strings for the TinyVPN client.

## Configuration Format

The encrypted string should decrypt to the following JSON format:

```json
{
  "address": "your-server.com",
  "port": 443,
  "uuid": "12345678-1234-1234-1234-123456789abc",
  "publicKey": "your-reality-public-key-here",
  "shortId": "0123456789abcdef",
  "sni": "google.com"
}
```

## Field Descriptions

- **address**: Server IP address or domain name
- **port**: Server port (typically 443 for HTTPS)
- **uuid**: Your unique user ID (UUID v4 format)
- **publicKey**: Reality protocol public key (base64 encoded)
- **shortId**: Reality protocol short ID (hex string)
- **sni**: Server Name Indication for TLS (domain to mimic)

## Encryption Details

The app uses AES encryption with the following parameters:

- **Algorithm**: AES-256
- **Mode**: CBC (Cipher Block Chaining)
- **Key**: 32 characters (hardcoded in app, split for obfuscation)
- **IV**: 16 zero bytes
- **Padding**: PKCS7
- **Output**: Base64 encoded string

## Generating Encrypted Config (Python Example)

```python
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
import base64
import json

# Configuration to encrypt
config = {
    "address": "example.com",
    "port": 443,
    "uuid": "12345678-1234-1234-1234-123456789abc",
    "publicKey": "your-public-key-here",
    "shortId": "0123456789abcdef",
    "sni": "google.com"
}

# Encryption key (must match the app's key)
key = b'0123456789abcdef0123456789abcdef'  # 32 bytes
iv = b'\x00' * 16  # 16 zero bytes

# Convert config to JSON
json_str = json.dumps(config)

# Create cipher and encrypt
cipher = AES.new(key, AES.MODE_CBC, iv)
encrypted = cipher.encrypt(pad(json_str.encode(), AES.block_size))

# Encode to base64
encrypted_b64 = base64.b64encode(encrypted).decode()

print("Encrypted Config:")
print(encrypted_b64)
```

## Generating Encrypted Config (Node.js Example)

```javascript
const crypto = require('crypto');

// Configuration to encrypt
const config = {
  address: "example.com",
  port: 443,
  uuid: "12345678-1234-1234-1234-123456789abc",
  publicKey: "your-public-key-here",
  shortId: "0123456789abcdef",
  sni: "google.com"
};

// Encryption key (must match the app's key)
const key = Buffer.from('0123456789abcdef0123456789abcdef', 'utf8');
const iv = Buffer.alloc(16, 0); // 16 zero bytes

// Convert config to JSON
const jsonStr = JSON.stringify(config);

// Create cipher and encrypt
const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
let encrypted = cipher.update(jsonStr, 'utf8', 'base64');
encrypted += cipher.final('base64');

console.log("Encrypted Config:");
console.log(encrypted);
```

## Security Notes

⚠️ **Important Security Considerations**:

1. The encryption key in this example (`0123456789abcdef0123456789abcdef`) is for demonstration only
2. In production, use a strong, randomly generated key
3. Keep the encryption key secret and secure
4. The key is obfuscated in the app but can be extracted by reverse engineering
5. This encryption provides basic protection but is not cryptographically secure against determined attackers

## Testing Your Config

1. Generate your encrypted config using one of the examples above
2. Copy the base64 output
3. Launch TinyVPN
4. Paste the encrypted string into the input field
5. Select your desired mode
6. Click Connect

If decryption fails, verify:
- JSON format is correct
- Encryption key matches exactly
- IV is 16 zero bytes
- Using CBC mode with PKCS7 padding
- Output is properly base64 encoded

## Example Encrypted Output

For the sample config above, the encrypted output would look like:
```
U2FsdGVkX1+vupppZksvRf5pq5g5XjFRlipRkwB0K1Y96Qsv2Lm+31cmzaAILwytX...
```
(Actual output will be longer)

## Distribution

When distributing configs to users:
1. Generate the encrypted string
2. Share only the encrypted string (never the raw JSON)
3. Provide clear instructions on which mode to use
4. Inform users if admin rights are required (for tunnel mode)

## Automation

You can create a simple web service or CLI tool to generate encrypted configs automatically:

```bash
./generate_config.py --server example.com --port 443 --uuid YOUR_UUID --key YOUR_KEY --sid YOUR_SID --sni google.com
```

This would output the encrypted string ready for distribution.
