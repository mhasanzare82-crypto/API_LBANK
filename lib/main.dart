import 'package:flutter/material.dart';

import 'screens/lbank_connection_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LbankApp());
}

class LbankApp extends StatelessWidget {
  const LbankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LBank Futures',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B5B)),
        useMaterial3: true,
      ),
      home: const LbankConnectionPage(),
    );
  }
}
