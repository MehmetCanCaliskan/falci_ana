import 'package:flutter/material.dart';
import '../coin_service.dart';

class WatchAdPage extends StatelessWidget {
  const WatchAdPage({super.key});

  Future<void> _simulateAd(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reklam izleniyor...')),
    );

    await Future.delayed(const Duration(seconds: 3)); // Simülasyon

    await CoinService().addCoins(2);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('+2 jeton kazandınız 🎁')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reklam İzle')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_circle_fill),
          label: const Text('Reklamı İzle ve +2 Jeton Kazan'),
          onPressed: () => _simulateAd(context),
        ),
      ),
    );
  }
}
