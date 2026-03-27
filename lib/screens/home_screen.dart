import 'package:flutter/material.dart';
import '../services/crypto_service.dart';
import '../services/config_builder.dart';
import '../services/vpn_service.dart';

/// Home screen with VPN connection controls
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _configController = TextEditingController();
  final VpnService _vpnService = VpnService();

  String _selectedMode = 'proxy';
  String _status = 'Disconnected';
  bool _isConnecting = false;
  Color _statusColor = Colors.red;

  final List<String> _modes = ['proxy', 'tunnel', 'both'];

  @override
  void dispose() {
    _configController.dispose();
    _vpnService.dispose();
    super.dispose();
  }

  /// Connect to VPN
  Future<void> _connect() async {
    if (_configController.text.trim().isEmpty) {
      _showError('Please enter encrypted config');
      return;
    }

    setState(() {
      _isConnecting = true;
      _status = 'Connecting...';
      _statusColor = Colors.orange;
    });

    try {
      // Decrypt config
      final decryptedConfig = CryptoService.decryptConfig(
        _configController.text.trim(),
      );

      // Build Xray config
      final xrayConfig = ConfigBuilder.buildConfig(
        decryptedConfig,
        _selectedMode,
      );

      // Start VPN
      final success = await _vpnService.startVPN(xrayConfig);

      if (success) {
        setState(() {
          _status = 'Connected';
          _statusColor = Colors.green;
        });
      } else {
        throw Exception('Failed to start VPN');
      }
    } catch (e) {
      setState(() {
        _status = 'Disconnected';
        _statusColor = Colors.red;
      });
      _showError('Connection failed: ${e.toString()}');
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  /// Disconnect from VPN
  Future<void> _disconnect() async {
    setState(() {
      _status = 'Disconnecting...';
      _statusColor = Colors.orange;
    });

    await _vpnService.stopVPN();

    setState(() {
      _status = 'Disconnected';
      _statusColor = Colors.red;
    });
  }

  /// Show error dialog
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('TinyVPN'),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f3460),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _vpnService.isRunning
                            ? Icons.vpn_lock
                            : Icons.vpn_lock_outlined,
                        size: 64,
                        color: _statusColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _status,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Encrypted config input
                TextField(
                  controller: _configController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Encrypted Config',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Enter encrypted configuration string',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF0f3460),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF16213e),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF00adb5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Mode selector
                DropdownButtonFormField<String>(
                  value: _selectedMode,
                  dropdownColor: const Color(0xFF0f3460),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'VPN Mode',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF0f3460),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF16213e),
                        width: 2,
                      ),
                    ),
                  ),
                  items: _modes.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_getModeLabel(mode)),
                    );
                  }).toList(),
                  onChanged: _vpnService.isRunning
                      ? null
                      : (value) {
                          setState(() {
                            _selectedMode = value!;
                          });
                        },
                ),
                const SizedBox(height: 32),

                // Connect/Disconnect button
                ElevatedButton(
                  onPressed: _isConnecting
                      ? null
                      : (_vpnService.isRunning ? _disconnect : _connect),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _vpnService.isRunning
                        ? Colors.red
                        : const Color(0xFF00adb5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _vpnService.isRunning ? 'DISCONNECT' : 'CONNECT',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Mode information
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0f3460),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Mode: ${_getModeLabel(_selectedMode)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getModeDescription(_selectedMode),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get display label for mode
  String _getModeLabel(String mode) {
    switch (mode) {
      case 'proxy':
        return 'Proxy (SOCKS)';
      case 'tunnel':
        return 'Tunnel (TUN)';
      case 'both':
        return 'Proxy + Tunnel';
      default:
        return mode;
    }
  }

  /// Get description for mode
  String _getModeDescription(String mode) {
    switch (mode) {
      case 'proxy':
        return 'SOCKS proxy on 127.0.0.1:10808 - Configure apps to use this proxy';
      case 'tunnel':
        return 'System-wide VPN tunnel - All traffic routed through VPN (Requires admin)';
      case 'both':
        return 'Both SOCKS proxy and system tunnel enabled';
      default:
        return '';
    }
  }
}
