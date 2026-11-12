import 'dart:convert';

import 'package:http/http.dart' as http;

class LbankFutureInstrument {
  const LbankFutureInstrument({
    required this.symbol,
    required this.name,
    required this.minOrderVolume,
    required this.maxOrderVolume,
    required this.priceTick,
    required this.volumeTick,
    required this.defaultLeverage,
  });

  final String symbol;
  final String name;
  final String minOrderVolume;
  final String maxOrderVolume;
  final num priceTick;
  final num volumeTick;
  final num defaultLeverage;

  factory LbankFutureInstrument.fromJson(Map<String, dynamic> json) {
    return LbankFutureInstrument(
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      name: (json['symbolName'] ?? json['symbol'] ?? '').toString(),
      minOrderVolume: (json['minOrderVolume'] ?? '').toString(),
      maxOrderVolume: (json['maxOrderVolume'] ?? '').toString(),
      priceTick: _asNum(json['priceTick']),
      volumeTick: _asNum(json['volumeTick']),
      defaultLeverage: _asNum(json['defaultLeverage']),
    );
  }

  static num _asNum(dynamic value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
}

class LbankFuturesMarketService {
  LbankFuturesMarketService({http.Client? client})
      : _client = client ?? http.Client();

  static const _baseUrl = 'https://lbkperp.lbank.com';
  static const productGroup = 'SwapU';
  final http.Client _client;

  Future<List<LbankFutureInstrument>> fetchActiveUsdtContracts() async {
    final instrumentUri = Uri.parse(
      '$_baseUrl/cfd/openApi/v1/pub/instrument',
    ).replace(queryParameters: {'productGroup': productGroup});
    final marketUri = Uri.parse(
      '$_baseUrl/cfd/openApi/v1/pub/marketData',
    ).replace(queryParameters: {'productGroup': productGroup});

    final responses = await Future.wait([
      _client.get(instrumentUri).timeout(const Duration(seconds: 15)),
      _client.get(marketUri).timeout(const Duration(seconds: 15)),
    ]);

    final instrumentsJson = _decodeList(responses[0]);
    final marketsJson = _decodeList(responses[1]);
    final quotedSymbols = marketsJson
        .map((item) => (item['symbol'] ?? '').toString().toUpperCase())
        .where((symbol) => symbol.isNotEmpty)
        .toSet();

    // The public instrument schema has no explicit status field. Intersecting
    // with current market-data symbols avoids presenting unquoted contracts.
    final instruments = instrumentsJson
        .map(LbankFutureInstrument.fromJson)
        .where((item) =>
            item.symbol.isNotEmpty && quotedSymbols.contains(item.symbol))
        .toList()
      ..sort((a, b) => a.symbol.compareTo(b.symbol));

    if (instruments.isEmpty) {
      throw const FormatException(
        'LBank returned no currently quoted SwapU contracts.',
      );
    }
    return instruments;
  }

  List<Map<String, dynamic>> _decodeList(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'LBank HTTP ${response.statusCode}',
        response.request?.url,
      );
    }
    final dynamic decoded = jsonDecode(response.body);
    dynamic payload = decoded;
    if (decoded is Map<String, dynamic>) {
      if (decoded['success'] == false || decoded['result'] == false) {
        throw FormatException(
          'LBank API error: ${decoded['msg'] ?? decoded['error_code'] ?? 'unknown'}',
        );
      }
      payload = decoded['data'] ?? decoded['result'] ?? decoded['dataList'];
    }
    if (payload is Map<String, dynamic>) {
      payload = payload['list'] ?? payload['rows'] ?? payload['data'];
    }
    if (payload is! List) {
      throw const FormatException('Unexpected LBank instrument response.');
    }
    return payload
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  void close() => _client.close();
}
