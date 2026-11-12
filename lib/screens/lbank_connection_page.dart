import 'package:flutter/material.dart';

import '../security/lbank_credentials_store.dart';
import '../services/lbank_futures_market_service.dart';

class LbankConnectionPage extends StatefulWidget {
  const LbankConnectionPage({super.key});

  @override
  State<LbankConnectionPage> createState() => _LbankConnectionPageState();
}

class _LbankConnectionPageState extends State<LbankConnectionPage> {
  final _store = LbankCredentialsStore();
  final _marketService = LbankFuturesMarketService();
  final _apiKeyController = TextEditingController();
  final _secretController = TextEditingController();
  bool _saving = false;
  bool _hasSavedCredentials = false;
  bool _hideSecret = true;
  bool _loadingSymbols = false;
  String? _symbolError;
  String? _selectedSymbol = 'BTCUSDT';
  List<LbankFutureInstrument> _instruments = const [];

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _loadSymbols();
  }

  Future<void> _loadSymbols() async {
    setState(() {
      _loadingSymbols = true;
      _symbolError = null;
    });
    try {
      final instruments = await _marketService.fetchActiveUsdtContracts();
      if (!mounted) return;
      setState(() {
        _instruments = instruments;
        // Keep BTCUSDT as the initial selection whenever it is listed.
        // If it is temporarily unavailable, select the first live contract.
        if (!instruments.any((item) => item.symbol == _selectedSymbol)) {
          _selectedSymbol = instruments.any((item) => item.symbol == 'BTCUSDT')
              ? 'BTCUSDT'
              : instruments.first.symbol;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _symbolError = error.toString());
    } finally {
      if (mounted) setState(() => _loadingSymbols = false);
    }
  }

  Future<void> _refreshStatus() async {
    final saved = await _store.hasCredentials();
    if (mounted) setState(() => _hasSavedCredentials = saved);
  }

  Future<void> _save() async {
    if (_apiKeyController.text.trim().isEmpty ||
        _secretController.text.isEmpty) {
      _message('هر دو فیلد API Key و Secret Key الزامی هستند.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _store.save(
        apiKey: _apiKeyController.text,
        secretKey: _secretController.text,
      );
      _apiKeyController.clear();
      _secretController.clear();
      await _refreshStatus();
      _message('کلیدها به‌صورت امن روی دستگاه ذخیره شدند.');
    } catch (_) {
      _message('ذخیره‌سازی انجام نشد. تنظیمات امنیتی دستگاه را بررسی کنید.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    await _store.clear();
    await _refreshStatus();
    if (!mounted) return;
    _message('کلیدهای ذخیره‌شده از دستگاه پاک شدند.');
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  @override
  void dispose() {
    _marketService.close();
    _apiKeyController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اتصال LBank Futures')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.shield_outlined, size: 48),
            const SizedBox(height: 12),
            Text(
              'اتصال امن حساب معاملاتی',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'کلیدها فقط روی همین دستگاه و با استفاده از فضای امن سیستم‌عامل ذخیره می‌شوند. آن‌ها را در چت یا کد برنامه وارد نکنید.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'نماد قرارداد Futures',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          tooltip: 'به‌روزرسانی فهرست',
                          onPressed: _loadingSymbols ? null : _loadSymbols,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_loadingSymbols)
                      const LinearProgressIndicator()
                    else if (_symbolError != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'دریافت فهرست نمادها ناموفق بود: $_symbolError',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          TextButton(
                            onPressed: _loadSymbols,
                            child: const Text('تلاش دوباره'),
                          ),
                        ],
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: _selectedSymbol,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'انتخاب نماد',
                        ),
                        items: _instruments.map((instrument) {
                          return DropdownMenuItem<String>(
                            value: instrument.symbol,
                            child: Text(
                              instrument.name == instrument.symbol
                                  ? instrument.symbol
                                  : '${instrument.symbol} — ${instrument.name}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSymbol = value);
                          }
                        },
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'فهرست از قراردادهای SwapU و نمادهایی که داده بازار جاری دارند ساخته می‌شود. انتخاب فعلی: ${_selectedSymbol ?? '—'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _apiKeyController,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _secretController,
              obscureText: _hideSecret,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Secret Key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _hideSecret = !_hideSecret),
                  icon: Icon(_hideSecret ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.lock),
              label: Text(_saving ? 'در حال ذخیره...' : 'ذخیره امن کلیدها'),
            ),
            const SizedBox(height: 12),
            if (_hasSavedCredentials) ...[
              const ListTile(
                leading: Icon(Icons.verified_user, color: Colors.green),
                title: Text('کلیدهای API روی این دستگاه ذخیره شده‌اند'),
                subtitle: Text('هنوز اتصال خصوصی حساب و دسترسی Futures آزمایش نشده است.'),
              ),
              OutlinedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('حذف کلیدهای ذخیره‌شده'),
              ),
            ],
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'هشدار: برای API فقط مجوز خواندن و معامله Futures را فعال کنید. مجوز برداشت و انتقال دارایی را خاموش نگه دارید. این مرحله فقط فهرست عمومی قراردادها را می‌خواند؛ ارسال سفارش فعال نیست.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
