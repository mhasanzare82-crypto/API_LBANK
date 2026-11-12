import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// User-editable initial preferences for LBank Futures.
/// These are local UI preferences, not an exchange order request.
class LbankTradingSettings {
  const LbankTradingSettings({
    this.leverage = 50,
    this.marginMode = 'isolated',
    this.positionMode = 'oneway',
    this.orderType = 'market',
    this.manualConfirmation = true,
    this.stopLossEnabled = true,
    this.takeProfitEnabled = true,
  });

  final int leverage;
  final String marginMode;
  final String positionMode;
  final String orderType;
  final bool manualConfirmation;
  final bool stopLossEnabled;
  final bool takeProfitEnabled;

  LbankTradingSettings copyWith({
    int? leverage,
    String? marginMode,
    String? positionMode,
    String? orderType,
    bool? manualConfirmation,
    bool? stopLossEnabled,
    bool? takeProfitEnabled,
  }) => LbankTradingSettings(
    leverage: leverage ?? this.leverage,
    marginMode: marginMode ?? this.marginMode,
    positionMode: positionMode ?? this.positionMode,
    orderType: orderType ?? this.orderType,
    manualConfirmation: manualConfirmation ?? this.manualConfirmation,
    stopLossEnabled: stopLossEnabled ?? this.stopLossEnabled,
    takeProfitEnabled: takeProfitEnabled ?? this.takeProfitEnabled,
  );

  Map<String, dynamic> toJson() => {
    'leverage': leverage,
    'marginMode': marginMode,
    'positionMode': positionMode,
    'orderType': orderType,
    'manualConfirmation': manualConfirmation,
    'stopLossEnabled': stopLossEnabled,
    'takeProfitEnabled': takeProfitEnabled,
  };

  factory LbankTradingSettings.fromJson(Map<String, dynamic> json) =>
      LbankTradingSettings(
        leverage: (json['leverage'] as num?)?.toInt() ?? 50,
        marginMode: json['marginMode'] as String? ?? 'isolated',
        positionMode: json['positionMode'] as String? ?? 'oneway',
        orderType: json['orderType'] as String? ?? 'market',
        manualConfirmation: json['manualConfirmation'] as bool? ?? true,
        stopLossEnabled: json['stopLossEnabled'] as bool? ?? true,
        takeProfitEnabled: json['takeProfitEnabled'] as bool? ?? true,
      );
}

class LbankTradingSettingsStore {
  LbankTradingSettingsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'lbank_futures_trading_settings';
  final FlutterSecureStorage _storage;

  Future<LbankTradingSettings> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return const LbankTradingSettings();
    try {
      return LbankTradingSettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const LbankTradingSettings();
    }
  }

  Future<void> save(LbankTradingSettings settings) =>
      _storage.write(key: _key, value: jsonEncode(settings.toJson()));
}
