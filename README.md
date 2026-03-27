# TinyVPN - Windows Flutter VPN Client

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A cross-platform VPN client built with Flutter and Xray core, featuring encrypted configuration support and multiple connection modes.

## 🎯 Features

- **Encrypted Configuration**: Accepts encrypted config strings for security
- **Multiple Modes**:
  - **Proxy Mode**: SOCKS proxy on port 10808
  - **Tunnel Mode**: System-wide VPN using TUN/Wintun
  - **Both**: Simultaneous proxy and tunnel mode
- **Modern UI**: Clean, dark-themed interface
- **Secure**:
  - No raw config storage
  - Configs only kept in memory
  - Disabled logging
  - Obfuscated encryption keys

## 📋 Prerequisites

### Required Software
- Flutter SDK 3.0 or higher
- Dart SDK (included with Flutter)
- Visual Studio 2019+ with C++ tools (for Windows builds)

### Required Files
You must obtain and place these files in the `windows/runner/` directory:

1. **xray.exe** - Xray core executable
   - Download from: https://github.com/XTLS/Xray-core/releases
   - Place at: `windows/runner/xray.exe`

2. **wintun.dll** - Wintun driver for TUN mode
   - Download from: https://www.wintun.net/
   - Place at: `windows/runner/wintun.dll`

⚠️ **Important**: These files are NOT included in this repository due to licensing and size constraints.

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Dev-Nidhan/Vpn-try1.git
cd Vpn-try1
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Add Required Files
Download and place `xray.exe` and `wintun.dll` in `windows/runner/` as described above.

### 4. Build the Application
```bash
# For development
flutter run -d windows

# For production release
flutter build windows --release
```

The built application will be in `build/windows/runner/Release/`

## 📦 Project Structure

```
lib/
 ├── main.dart                    # Application entry point
 ├── screens/
 │   └── home_screen.dart         # Main UI screen
 └── services/
     ├── crypto_service.dart      # AES decryption logic
     ├── config_builder.dart      # Xray config generator
     └── vpn_service.dart         # Xray process manager

windows/
 └── runner/
     ├── xray.exe                 # ⚠️ Required - not included
     └── wintun.dll               # ⚠️ Required - not included
```

## 🔐 Configuration Format

### Encrypted Input
Users enter an encrypted base64 string that decrypts to JSON:

### Decrypted Format (JSON)
```json
{
  "address": "example.com",
  "port": 443,
  "uuid": "your-uuid-here",
  "publicKey": "your-reality-public-key",
  "shortId": "your-short-id",
  "sni": "google.com"
}
```

### Generating Encrypted Configs
The encryption key is hardcoded in `crypto_service.dart`. To create encrypted configs:

```dart
// Use AES-CBC with the same key from crypto_service.dart
// Key: "0123456789abcdef0123456789abcdef" (32 chars)
// IV: 16 zero bytes
// Mode: CBC
// Padding: PKCS7
// Output: Base64 encode the encrypted bytes
```

## 🎮 Usage

### 1. Launch the Application
Run the built executable or use `flutter run -d windows`

### 2. Enter Configuration
Paste your encrypted configuration string into the input field

### 3. Select Mode
Choose from:
- **Proxy (SOCKS)**: For browser/app-specific proxy (127.0.0.1:10808)
- **Tunnel (TUN)**: For system-wide VPN ⚠️ Requires Administrator
- **Proxy + Tunnel**: Both modes simultaneously

### 4. Connect
Click the **CONNECT** button to establish VPN connection

### 5. Verify Connection
- **Proxy Mode**: Configure browser to use SOCKS5 proxy at 127.0.0.1:10808
- **Tunnel Mode**: Check your IP at https://whatismyip.com

### 6. Disconnect
Click **DISCONNECT** to stop the VPN

## ⚠️ Important Notes

### Administrator Rights
- **Tunnel mode** requires running as Administrator on Windows
- Right-click the executable → "Run as Administrator"

### Firewall
- Windows Firewall may prompt for access
- Allow both Private and Public networks for full functionality

### Limitations
- gVisor is NOT supported on Windows
- TUN mode requires Wintun driver
- Reverse engineering of the app is technically possible

## 🛠️ Development

### Running Tests
```bash
flutter test
```

### Hot Reload (Development)
```bash
flutter run -d windows
# Press 'r' for hot reload, 'R' for hot restart
```

### Build Configurations
```bash
# Debug build
flutter build windows --debug

# Profile build
flutter build windows --profile

# Release build
flutter build windows --release
```

## 🔧 Troubleshooting

### "xray.exe not found"
- Ensure `xray.exe` is in `windows/runner/` directory
- Check file permissions
- Verify xray.exe version compatibility

### "wintun.dll not found"
- Download correct version from wintun.net
- Place in `windows/runner/` directory
- Ensure it's the correct architecture (x64)

### Connection Fails
- Verify encrypted config is correct
- Check if ports are available (10808 for SOCKS)
- Ensure firewall isn't blocking
- Check if admin rights are needed

### Decryption Fails
- Verify encryption key matches
- Check base64 encoding is correct
- Ensure JSON format is valid after decryption

## 🔒 Security Considerations

- Encryption key is obfuscated but not 100% secure
- Configs are stored in memory only, not on disk
- Logs are disabled by default
- Use HTTPS for all server communications
- Regularly update Xray core for security patches

## 📝 License

This project is for educational purposes. Ensure compliance with local laws regarding VPN usage.

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📧 Support

For issues and questions:
- Open an issue on GitHub
- Check existing issues for solutions

## ⚖️ Disclaimer

This software is provided as-is. Users are responsible for:
- Complying with local laws
- Obtaining proper Xray and Wintun licenses
- Securing their encryption keys
- Testing in their specific environment

---

**Note**: This is a VPN client implementation using Xray core. Make sure you have proper authorization and licenses for all components used.
