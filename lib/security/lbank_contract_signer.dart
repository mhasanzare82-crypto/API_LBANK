import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Implements the documented LBank Contract API HmacSHA256 signing flow.
///
/// This class only creates signatures. It deliberately does not send requests
/// or place orders; private futures endpoint paths and schemas must be verified
/// against LBank's current contract API documentation first.
class LbankContractSigner {
  const LbankContractSigner();

  String createEchostr({int length = 32}) {
    if (length < 30 || length > 40) {
      throw ArgumentError.value(length, 'length', 'Must be between 30 and 40.');
    }
    const chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String signHmacSha256({
    required Map<String, String> parameters,
    required String secretKey,
    required String timestamp,
    required String echostr,
  }) {
    if (secretKey.isEmpty) throw ArgumentError('Secret Key is required.');
    if (echostr.length < 30 || echostr.length > 40) {
      throw ArgumentError('echostr must contain 30 to 40 alphanumeric characters.');
    }
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(echostr)) {
      throw ArgumentError('echostr must be alphanumeric.');
    }

    final signedParameters = <String, String>{
      ...parameters,
      'signature_method': 'HmacSHA256',
      'timestamp': timestamp,
      'echostr': echostr,
    }..remove('sign');

    final canonical = signedParameters.keys.toList()..sort();
    final parameterString = canonical
        .map((key) => '$key=${signedParameters[key]}')
        .join('&');

    final prepared = md5.convert(utf8.encode(parameterString)).toString().toUpperCase();
    final hmac = Hmac(sha256, utf8.encode(secretKey));
    return hmac.convert(utf8.encode(prepared)).toString();
  }
}
