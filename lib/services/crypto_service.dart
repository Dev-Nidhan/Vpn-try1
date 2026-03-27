import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Service for handling encrypted config decryption
class CryptoService {
  // Obfuscated encryption key - split into parts for security
  static const String _keyPart1 = '0123456789abcdef';
  static const String _keyPart2 = '0123456789abcdef';
  static final String _encryptionKey = _keyPart1 + _keyPart2;

  /// Decrypts the encrypted config string and returns a JSON map
  ///
  /// Expected output format:
  /// {
  ///   "address": "IP_OR_DOMAIN",
  ///   "port": 443,
  ///   "uuid": "UUID",
  ///   "publicKey": "REALITY_KEY",
  ///   "shortId": "SHORT_ID",
  ///   "sni": "google.com"
  /// }
  static Map<String, dynamic> decryptConfig(String encryptedString) {
    try {
      // Create encryption key and IV
      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final iv = encrypt.IV.fromLength(16);

      // Create encrypter with AES CBC mode
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7')
      );

      // Decode base64 encrypted string
      final encrypted = encrypt.Encrypted.fromBase64(encryptedString);

      // Decrypt the data
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      // Parse JSON and return as map
      return json.decode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to decrypt config: $e');
    }
  }

  /// Alternative decryption method using ECB mode (if CBC doesn't work)
  static Map<String, dynamic> decryptConfigECB(String encryptedString) {
    try {
      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.ecb, padding: 'PKCS7')
      );

      final encrypted = encrypt.Encrypted.fromBase64(encryptedString);
      final decrypted = encrypter.decrypt(encrypted);

      return json.decode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to decrypt config (ECB): $e');
    }
  }
}
