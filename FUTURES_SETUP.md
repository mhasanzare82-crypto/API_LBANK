# LBank Futures integration status

## Implemented foundation

- API Key and Secret Key are stored locally through Flutter Secure Storage.
- HmacSHA256 signing helper is present; do not use it for private requests until the exact current Contract API signing schema has been independently verified.
- No credentials are embedded in Dart source, assets, or this repository.
- No withdrawal or transfer code is included.

## Dynamic Futures symbol list

- The Android app requests the public `instrument` and `marketData` endpoints for `productGroup=SwapU`.
- The selector intersects the instrument list with symbols currently returned by market data, sorts the resulting symbols, and provides a refresh action.
- `BTCUSDT` is selected by default when it is present. If LBank does not return it, the first currently quoted contract is selected as a UI fallback.
- Instrument metadata includes min/max order volume, price tick, volume tick, and default leverage.
- This is public market-data access only; it does not authenticate the account or place orders.

## Editable Futures settings

The connection screen includes locally persisted preferences with these initial values:

- Default leverage: 50x (UI slider range 1x–125x; actual contract leverage limits must be checked per symbol)
- Margin mode: Isolated
- Position mode: One-Way
- Order type: Market
- Manual order confirmation: enabled
- Stop Loss: enabled
- Take Profit: enabled

All settings can be changed in the app and are saved locally using Flutter Secure Storage. They are preferences only; they are not yet submitted to LBank or applied to the exchange account.

## Order preflight foundation

`lib/services/lbank_order_preflight.dart` adds a local order-preview model and validates positive quantity, instrument minimum/maximum quantity, and volume-step alignment. It copies the selected settings into a preview. It intentionally has no network submit method and cannot place, close, or cancel an order.

This is not sufficient to approve a live order. Before live trading, the app must additionally validate contract-specific leverage ceilings, price/quantity precision, notional limits, margin sufficiency, position mode, reduce-only/close semantics, TP/SL semantics, duplicate submissions, and exchange response handling.

## Official futures API information

The official Contract API documentation identifies:

- REST base URL: `https://lbkperp.lbank.com/`
- WebSocket URL: `wss://lbkperpws.lbank.com/ws`
- Public endpoints:
  - `GET /cfd/openApi/v1/pub/getTime`
  - `GET /cfd/openApi/v1/pub/instrument?productGroup=...`
  - `GET /cfd/openApi/v1/pub/marketData?productGroup=...`
  - `GET /cfd/openApi/v1/pub/marketOrder?depth=...&symbol=...`

The private futures account, position, leverage/margin-setting, order-placement, close-position, and cancellation schemas have not yet been verified against a current authoritative specification. Do not guess these paths or payloads. Obtain the current private Contract API documentation from LBank support/developer portal before implementing signed requests or enabling live trading.

Official documentation: https://www.lbank.com/docs/contract.html

## Security requirements before live use

1. Use a dedicated API key with futures read/trade only.
2. Disable withdrawal and transfer permissions.
3. Prefer an IP allowlist where feasible; confirm LBank's current API-key expiration rules.
4. Never paste API credentials into chat, issues, logs, screenshots, or source files.
5. A mobile-only app stores the secret on the device and is less secure than a backend signing service.
6. Before enabling live orders, require explicit confirmation, risk/notional caps, contract leverage validation, idempotency protection, and a kill switch.
7. Test on an official sandbox/test account if available.

## Current status

The dynamic public symbol selector, editable local settings, and local order preflight/preview model are committed to the development branch. The app has not been built or tested in a Flutter/Android SDK environment. There is no verified APK. No private account request, live order, close, or cancel action is implemented. Live trading must remain disabled until LBank's current private Contract API schemas are obtained and verified, and Android build/tests pass.
