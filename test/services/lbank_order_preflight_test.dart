import 'package:flutter_test/flutter_test.dart';
import 'package:exm1/services/lbank_futures_market_service.dart';
import 'package:exm1/services/lbank_order_preflight.dart';
import 'package:exm1/services/lbank_trading_settings.dart';

void main() {
  const instrument = LbankFutureInstrument(
    symbol: 'BTCUSDT',
    name: 'BTCUSDT',
    minOrderVolume: '0.001',
    maxOrderVolume: '100',
    priceTick: 0.1,
    volumeTick: 0.001,
    defaultLeverage: 50,
  );
  const preflight = LbankOrderPreflight();
  const settings = LbankTradingSettings();

  test('creates a preview using selected trading preferences', () {
    final preview = preflight.buildPreview(
      instrument: instrument,
      side: LbankOrderSide.openLong,
      quantityText: '0.002',
      settings: settings,
    );

    expect(preview.symbol, 'BTCUSDT');
    expect(preview.quantity, '0.002');
    expect(preview.leverage, 50);
    expect(preview.marginMode, 'isolated');
    expect(preview.positionMode, 'oneway');
    expect(preview.orderType, 'market');
    expect(preview.manualConfirmation, isTrue);
  });

  test('rejects quantity below contract minimum', () {
    expect(
      () => preflight.buildPreview(
        instrument: instrument,
        side: LbankOrderSide.openLong,
        quantityText: '0.0005',
        settings: settings,
      ),
      throwsFormatException,
    );
  });

  test('rejects quantity not aligned to volume step', () {
    expect(
      () => preflight.buildPreview(
        instrument: instrument,
        side: LbankOrderSide.openShort,
        quantityText: '0.0015',
        settings: settings,
      ),
      throwsFormatException,
    );
  });
}
