# LBank Futures integration status

## Implemented foundation

- API Key and Secret Key are stored locally through Flutter Secure Storage.
- HmacSHA256 signing follows the official Contract API canonicalization flow:
  sorted parameters + `signature_method`, `timestamp`, and `echostr`;
  uppercase MD5 digest; HmacSHA256 over that digest.
- No credentials are embedded in Dart source, assets, or this repository.
- No withdrawal or transfer code is included.

## Dynamic Futures symbol list

- The Android app requests the public `instrument` and `marketData` endpoints for `productGroup=SwapU`.
- The selector intersects the instrument list with symbols currently returned by market data, sorts the resulting symbols, and provides a refresh action.
- `BTCUSDT` is selected by default when it is present. If LBank does not return it, the first currently quoted contract is selected as a safe UI fallback.
- Instrument metadata displayed/available to later order forms includes min/max order volume, price tick, volume tick, and default leverage.
- This is public market-data access only; it does not authenticate the account or place orders.

The public instrument response schema does not document a dedicated active/status field. Therefore, the app uses presence in the current market-data response as the active/quoted filter. The result is a live quoted-contract list, not a claim that every returned contract is guaranteed to accept orders at every moment.

## Verified official futures API details

The official Contract API documentation identifies:

- REST base URL: `https://lbkperp.lbank.com/`
- WebSocket URL: `wss://lbkperpws.lbank.com/ws`
- Public contract endpoints:
  - `GET /cfd/openApi/v1/pub/getTime`
  - `GET /cfd/openApi/v1/pub/instrument?productGroup=...`
  - `GET /cfd/openApi/v1/pub/marketData?productGroup=...`
  - `GET /cfd/openApi/v1/pub/marketOrder?depth=...&symbol=...`

The currently published Contract API page exposes public market-data endpoints, but does not expose the private futures account, position, order-placement, or order-cancellation schemas in the page inspected. Do not guess these paths or payloads. Verify the current private endpoint definitions and permissions with LBank before enabling account reads or live trading.

Official documentation: https://www.lbank.com/docs/contract.html

## Required security setup before live use

1. Create a dedicated LBank API key with futures read/trade permissions only.
2. Disable withdrawal and transfer permissions.
3. Apply an IP allowlist where possible. LBank documents that unbound API keys expire after 30 days.
4. Do not paste API credentials into chat, issues, logs, screenshots, or source files.
5. Before enabling live orders, add explicit order confirmation, quantity/notional limits, leverage caps, and a kill switch.
6. Test with an LBank-provided test account or sandbox first.

## Current limitation

The dynamic public Futures symbol selector is implemented on the development branch, but it has not yet been built or tested in a Flutter/Android SDK environment. The app still does not connect to private futures endpoints, fetch positions/balances, place/cancel orders, or produce a verified APK. Those steps require the current private futures endpoint schemas and a Flutter build/test run.
