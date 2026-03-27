import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';

/// Service for managing Xray VPN process
class VpnService {
  Process? _xrayProcess;
  bool _isRunning = false;

  /// Gets the running status
  bool get isRunning => _isRunning;

  /// Starts the VPN with the given configuration
  ///
  /// [config] - JSON configuration string for Xray
  /// Returns true if started successfully
  Future<bool> startVPN(String config) async {
    try {
      // Stop existing process if any
      if (_isRunning) {
        await stopVPN();
      }

      // Save config to temporary file
      final configFile = await _saveConfig(config);

      // Get Xray executable path
      final xrayPath = await _getXrayPath();

      // Verify xray.exe exists
      if (!await File(xrayPath).exists()) {
        throw Exception('Xray executable not found at: $xrayPath');
      }

      // Start Xray process
      _xrayProcess = await Process.start(
        xrayPath,
        ['-c', configFile.path],
        mode: ProcessStartMode.detached,
      );

      _isRunning = true;

      // Listen to process exit
      _xrayProcess!.exitCode.then((exitCode) {
        _isRunning = false;
        print('Xray process exited with code: $exitCode');
      });

      return true;
    } catch (e) {
      print('Error starting VPN: $e');
      _isRunning = false;
      return false;
    }
  }

  /// Stops the VPN
  Future<void> stopVPN() async {
    try {
      if (_xrayProcess != null) {
        _xrayProcess!.kill();
        _xrayProcess = null;
      }

      // On Windows, also kill any remaining xray.exe processes
      if (Platform.isWindows) {
        try {
          await run('taskkill', ['/F', '/IM', 'xray.exe']);
        } catch (e) {
          // Ignore errors if process is not running
        }
      }

      _isRunning = false;
    } catch (e) {
      print('Error stopping VPN: $e');
    }
  }

  /// Saves configuration to a temporary file
  Future<File> _saveConfig(String config) async {
    final tempDir = await getTemporaryDirectory();
    final configFile = File('${tempDir.path}/xray_config.json');
    await configFile.writeAsString(config);
    return configFile;
  }

  /// Gets the path to xray.exe
  Future<String> _getXrayPath() async {
    if (Platform.isWindows) {
      // For Windows desktop app
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      return '$exeDir\\xray.exe';
    } else {
      // For other platforms (future support)
      throw UnsupportedError('Platform not supported yet');
    }
  }

  /// Cleanup when service is disposed
  void dispose() {
    stopVPN();
  }
}
