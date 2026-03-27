import 'dart:convert';

/// Service for building Xray configuration JSON
class ConfigBuilder {
  /// DNS server to use
  static const String dnsServer = '8.8.4.4';

  /// SOCKS proxy port
  static const int socksPort = 10808;

  /// Builds Xray configuration JSON based on decrypted config and mode
  ///
  /// [data] - Decrypted config map containing server details
  /// [mode] - VPN mode: 'proxy', 'tunnel', or 'both'
  ///
  /// Returns JSON string for Xray configuration
  static String buildConfig(Map<String, dynamic> data, String mode) {
    final config = {
      'log': {
        'loglevel': 'none', // Disable logs for security
      },
      'dns': {
        'servers': [dnsServer]
      },
      'inbounds': _buildInbounds(mode),
      'outbounds': [_buildOutbound(data)],
      'routing': {
        'domainStrategy': 'IPIfNonMatch',
        'rules': []
      }
    };

    return json.encode(config);
  }

  /// Builds inbounds configuration based on mode
  static List<Map<String, dynamic>> _buildInbounds(String mode) {
    final inbounds = <Map<String, dynamic>>[];

    if (mode == 'proxy' || mode == 'both') {
      // Add SOCKS proxy inbound
      inbounds.add({
        'tag': 'socks-in',
        'port': socksPort,
        'protocol': 'socks',
        'settings': {
          'auth': 'noauth',
          'udp': true,
          'ip': '127.0.0.1'
        },
        'sniffing': {
          'enabled': true,
          'destOverride': ['http', 'tls']
        }
      });
    }

    if (mode == 'tunnel' || mode == 'both') {
      // Add TUN inbound for system-wide VPN
      inbounds.add({
        'tag': 'tun-in',
        'port': 0,
        'protocol': 'tun',
        'settings': {
          'address': '10.0.85.1',
          'netmask': '255.255.255.0',
          'mtu': 9000,
          'autoRoute': true,
          'gateway': '10.0.85.0',
          'udp': true,
          'stack': 'system',
          'dnsSettings': {
            'servers': [dnsServer]
          }
        },
        'sniffing': {
          'enabled': true,
          'destOverride': ['http', 'tls']
        }
      });
    }

    return inbounds;
  }

  /// Builds VLESS outbound with Reality security
  static Map<String, dynamic> _buildOutbound(Map<String, dynamic> data) {
    return {
      'tag': 'proxy',
      'protocol': 'vless',
      'settings': {
        'vnext': [
          {
            'address': data['address'],
            'port': data['port'] ?? 443,
            'users': [
              {
                'id': data['uuid'],
                'encryption': 'none',
                'flow': ''
              }
            ]
          }
        ]
      },
      'streamSettings': {
        'network': 'tcp',
        'security': 'reality',
        'realitySettings': {
          'show': false,
          'fingerprint': 'chrome',
          'serverName': data['sni'],
          'publicKey': data['publicKey'],
          'shortId': data['shortId'],
          'spiderX': ''
        }
      },
      'mux': {
        'enabled': false,
        'concurrency': 8
      }
    };
  }
}
