# TinyVPN Setup Guide

Complete step-by-step guide to set up and run TinyVPN on Windows.

## 📋 Prerequisites

### 1. Install Flutter SDK

1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to a location like `C:\src\flutter`
3. Add Flutter to PATH:
   - Open "Environment Variables"
   - Add `C:\src\flutter\bin` to PATH
   - Restart terminal

4. Verify installation:
```bash
flutter doctor
```

### 2. Install Visual Studio

For Windows desktop builds, you need Visual Studio with C++ tools:

1. Download Visual Studio 2022 Community from https://visualstudio.microsoft.com/
2. During installation, select:
   - "Desktop development with C++"
   - Windows 10 SDK

### 3. Enable Windows Desktop Support

```bash
flutter config --enable-windows-desktop
```

## 🚀 Project Setup

### 1. Clone Repository

```bash
git clone https://github.com/Dev-Nidhan/Vpn-try1.git
cd Vpn-try1
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Download Required Binaries

#### Xray Core (xray.exe)

1. Visit https://github.com/XTLS/Xray-core/releases
2. Download the latest Windows x64 version (e.g., `Xray-windows-64.zip`)
3. Extract the archive
4. Rename `xray.exe` or `xray-windows-64.exe` to `xray.exe`
5. Copy to `windows/runner/xray.exe`

**Direct download example** (PowerShell):
```powershell
Invoke-WebRequest -Uri "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-windows-64.zip" -OutFile "xray.zip"
Expand-Archive -Path "xray.zip" -DestinationPath "xray_temp"
Copy-Item "xray_temp\xray.exe" -Destination "windows\runner\xray.exe"
Remove-Item "xray.zip", "xray_temp" -Recurse
```

#### Wintun Driver (wintun.dll)

1. Visit https://www.wintun.net/
2. Download the latest release (e.g., `wintun-0.14.1.zip`)
3. Extract the archive
4. Navigate to `wintun\bin\amd64\`
5. Copy `wintun.dll` to `windows/runner/wintun.dll`

**Direct download example** (PowerShell):
```powershell
Invoke-WebRequest -Uri "https://www.wintun.net/builds/wintun-0.14.1.zip" -OutFile "wintun.zip"
Expand-Archive -Path "wintun.zip" -DestinationPath "wintun_temp"
Copy-Item "wintun_temp\wintun\bin\amd64\wintun.dll" -Destination "windows\runner\wintun.dll"
Remove-Item "wintun.zip", "wintun_temp" -Recurse
```

### 4. Verify Files

Check that both files are in place:

```bash
dir windows\runner\
```

You should see:
- `xray.exe` (~15-20 MB)
- `wintun.dll` (~200-300 KB)

## 🏗️ Building the Application

### Development Build

For testing and development:

```bash
flutter run -d windows
```

### Release Build

For production deployment:

```bash
flutter build windows --release
```

The built application will be in:
```
build\windows\runner\Release\
```

The folder contains:
- `tinyvpn.exe` - Main executable
- Required DLL files
- `data\` folder with Flutter assets

## 📦 Distribution

### Create Distributable Package

1. Navigate to release folder:
```bash
cd build\windows\runner\Release
```

2. Copy required files to release:
```bash
copy ..\..\..\..\windows\runner\xray.exe .
copy ..\..\..\..\windows\runner\wintun.dll .
```

3. Package structure:
```
Release/
├── tinyvpn.exe
├── xray.exe
├── wintun.dll
├── data/
└── [other DLLs]
```

4. Create ZIP archive:
```bash
tar -a -cf TinyVPN-v1.0-Windows.zip *
```

## 🎮 Running the Application

### Method 1: From Development

```bash
flutter run -d windows
```

### Method 2: From Executable

1. Navigate to build directory
2. Double-click `tinyvpn.exe`

### Method 3: Run as Administrator (Required for Tunnel Mode)

Right-click `tinyvpn.exe` → "Run as administrator"

## 🔧 Configuration

### Generating Encrypted Config

See [CONFIG_GENERATOR.md](CONFIG_GENERATOR.md) for detailed instructions.

Quick Python example:

```python
from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
import base64
import json

config = {
    "address": "your-server.com",
    "port": 443,
    "uuid": "your-uuid-here",
    "publicKey": "your-public-key",
    "shortId": "your-short-id",
    "sni": "google.com"
}

key = b'0123456789abcdef0123456789abcdef'
iv = b'\x00' * 16

cipher = AES.new(key, AES.MODE_CBC, iv)
encrypted = cipher.encrypt(pad(json.dumps(config).encode(), AES.block_size))
print(base64.b64encode(encrypted).decode())
```

### Using the Application

1. **Launch** the application
2. **Paste** encrypted config string
3. **Select** mode:
   - Proxy: SOCKS5 on 127.0.0.1:10808
   - Tunnel: System-wide VPN (needs admin)
   - Both: Proxy + Tunnel
4. **Click** Connect
5. **Test** connection:
   - Proxy: Configure browser SOCKS5 settings
   - Tunnel: Check IP at whatismyip.com

## 🐛 Troubleshooting

### Flutter Doctor Issues

```bash
flutter doctor -v
```

Fix common issues:
- Install Visual Studio with C++ tools
- Enable Windows desktop support
- Update Flutter SDK

### Build Errors

**Error: xray.exe not found**
- Verify file is in `windows/runner/`
- Check file permissions
- Ensure not blocked by Windows

**Error: wintun.dll not found**
- Download correct x64 version
- Place in `windows/runner/`
- Unblock if needed: Right-click → Properties → Unblock

**Error: Flutter dependencies**
```bash
flutter clean
flutter pub get
flutter build windows
```

### Runtime Errors

**Connection Failed**
- Verify encrypted config is correct
- Check server is accessible
- Test with curl or ping

**Permission Denied (Tunnel Mode)**
- Run as Administrator
- Check Windows Firewall settings
- Ensure Wintun is not blocked

**Port Already in Use (Proxy Mode)**
- Close apps using port 10808
- Change port in `config_builder.dart` if needed

### Windows Firewall

When first running, Windows may prompt:
1. Allow access for Private networks ✓
2. Allow access for Public networks ✓

To manually configure:
1. Windows Security → Firewall
2. Allow an app through firewall
3. Find `tinyvpn.exe`
4. Enable Private and Public

## 🔍 Verification

### Check Xray Process

```bash
tasklist | findstr xray
```

### Check Proxy Port

```bash
netstat -an | findstr 10808
```

### Test Proxy Connection

Configure browser:
- SOCKS Host: 127.0.0.1
- SOCKS Port: 10808
- SOCKS v5

Visit: https://whatismyip.com

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Xray Core Documentation](https://xtls.github.io/)
- [Wintun Documentation](https://www.wintun.net/)

## ⚠️ Important Notes

- **Admin Rights**: Required for Tunnel mode
- **Antivirus**: May flag xray.exe (add exception if needed)
- **Firewall**: Allow connections when prompted
- **Updates**: Regularly update Xray core for security
- **Legal**: Ensure VPN usage complies with local laws

## 🆘 Support

For issues:
1. Check this guide thoroughly
2. Review [README.md](README.md)
3. Check [CONFIG_GENERATOR.md](CONFIG_GENERATOR.md)
4. Open an issue on GitHub with:
   - Error message
   - Steps to reproduce
   - Flutter doctor output
   - Windows version

## 📝 Quick Reference

```bash
# Setup
flutter pub get

# Run development
flutter run -d windows

# Build release
flutter build windows --release

# Run tests
flutter test

# Clean build
flutter clean
```

---

**Success!** If you followed all steps, TinyVPN should now be running on your Windows system.
