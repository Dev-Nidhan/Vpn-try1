## TinyVPN Placeholder Files

⚠️ **IMPORTANT**: This directory requires two files that are NOT included in the repository:

### Required Files:

1. **xray.exe**
   - Description: Xray core executable
   - Download: https://github.com/XTLS/Xray-core/releases
   - Version: Latest stable release
   - Architecture: Windows x64
   - File size: ~15-20 MB

2. **wintun.dll**
   - Description: Wintun driver library for TUN mode
   - Download: https://www.wintun.net/
   - Version: Latest stable release
   - Architecture: amd64 (x64)
   - File size: ~200-300 KB

### Installation Instructions:

1. Download `xray.exe` from the Xray-core releases page
2. Download `wintun.dll` from the Wintun website (extract from the zip, use the amd64 version)
3. Place both files in this directory (`windows/runner/`)
4. Ensure files are not renamed

### Directory Structure After Setup:

```
windows/runner/
├── CMakeLists.txt
├── xray.exe           ← Place here
├── wintun.dll         ← Place here
└── README.md          (this file)
```

### Why These Files Are Not Included:

- **Size**: These binaries are large and not suitable for git repositories
- **Licensing**: Xray and Wintun have their own licenses
- **Updates**: Users should download the latest versions for security
- **Distribution**: Binary redistribution may have legal implications

### Verification:

After placing the files, verify with:

```bash
# Windows Command Prompt
dir windows\runner\

# PowerShell
ls windows/runner/

# You should see both xray.exe and wintun.dll listed
```

### Troubleshooting:

**xray.exe not found error**:
- Check the file is named exactly `xray.exe` (not `xray-windows-64.exe` or similar)
- Verify it's in the correct directory
- Check file permissions

**wintun.dll not found error**:
- Ensure you downloaded the correct architecture (amd64/x64)
- Extract from the zip file (it comes compressed)
- Place in the same directory as xray.exe

### Security Note:

Always download these files from official sources:
- Xray: https://github.com/XTLS/Xray-core/releases
- Wintun: https://www.wintun.net/

Verify file integrity using checksums if provided.
