import 'package:flutter/foundation.dart';

import 'lbank_futures_market_service.dart';
import 'lbank_trading_settings.dart';

enum LbankOrderSide { openLong, openShort, closeLong, closeShort }

/// A validated local order preview. It is deliberately NOT an exchange order
/// and contains no network submission method.
@immutable
class LbankOrderPreview {
  const LbankOrderPreview({
    required this.symbol,
    required this.side,
    required this.orderType,
    required this.quantity,
    required this.leverage,
    required this.marginMode,
    required this.positionMode,
    required this.manualConfirmation,
    required this.stopLossEnabled,
    required this.takeProfitEnabled,
  });

  final String symbol;
  final LbankOrderSide side;
  final String orderType;
  final String quantity;
  final int leverage;
  final String marginMode;
  final String positionMode;
  final bool manualConfirmation;
  final bool stopLossEnabled;
  final bool takeProfitEnabled;
}

class LbankOrderPreflight {
  const LbankOrderPreflight();

  /// Validates the local draft against known instrument quantity metadata.
  /// Contract-specific leverage ceilings, account mode compatibility, price
  /// bands, margin sufficiency and private API constraints still require
  /// exchange-side verification before any live order can be sent.
  LbankOrderPreview buildPreview({
    required LbankFutureInstrument instrument,
    required LbankOrderSide side,
    required String quantityText,
    required LbankTradingSettings settings,
  }) {
    final quantity = num.tryParse(quantityText);
    if (quantity == null || !quantity.isFinite || quantity <= 0) {
      throw const FormatException('Quantity must be a positive number.');
    }

    final minQty = num.tryParse(instrument.minOrderVolume);
    final maxQty = num.tryParse(instrument.maxOrderVolume);
    if (minQty != null && quantity < minQty) {
      throw FormatException('Quantity is below minimum: $minQty');
    }
    if (maxQty != null && maxQty > 0 && quantity > maxQty) {
      throw FormatException('Quantity exceeds maximum: $maxQty');
    }

    final volumeStep = instrument.volumeTick;
    if (volumeStep > 0) {
      final units = quantity / volumeStep;
      if ((units - units.round()).abs() > 1e-8) {
        throw FormatException('Quantity must follow volume step: $volumeStep');
      }
    }

    return LbankOrderPreview(
      symbol: instrument.symbol,
      side: side,
      orderType: settings.orderType,
      quantity: quantityText.trim(),
      leverage: settings.leverage,
      marginMode: settings.marginMode,
      positionMode: settings.positionMode,
      manualConfirmation: settings.manualConfirmation,
      stopLossEnabled: settings.stopLossEnabled,
      takeProfitEnabled: settings.takeProfitEnabled,
    );
  }
}
