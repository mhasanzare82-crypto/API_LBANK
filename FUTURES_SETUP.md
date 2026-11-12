# LBank Futures integration status

## Implemented foundation

- API Key and Secret Key are stored locally through Flutter Secure Storage.
- HmacSHA256 signing follows the official Contract API canonicalization flow:
  sorted parameters + `signature_method`, `timestamp`, and `echostr`;
  uppercase MD5 digest; HmacSHA256 over that digest.
- No credentials are embedded in Dart source, assets, or this repository.
- No withdrawal or transfer code is included.

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

This repository change is a secure credential/signing foundation only. It does not yet connect to private futures endpoints, fetch positions/balances, place/cancel orders, or produce a verified APK. Those steps require the current private futures endpoint schemas and a Flutter build/test run.
