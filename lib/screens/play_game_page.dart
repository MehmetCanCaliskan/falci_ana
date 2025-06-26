import 'package:flutter/material.dart';
import '../coin_service.dart';

class PlayGamePage extends StatelessWidget {
  const PlayGamePage({super.key});

  Future<void> _simulateGame(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oyun oynanıyor... 🎮')),
    );

    await Future.delayed(const Duration(seconds: 3)); // Simülasyon

    await CoinService().addCoins(3);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('+3 jeton kazandınız 🪙')),
    );

    Navigator.pop(context, true); // böylece HomePage "true" sonucu alır ve jetonu günceller

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyun')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.videogame_asset),
          label: const Text('Oyunu Oyna ve +3 Jeton Kazan'),
          onPressed: () => _simulateGame(context),
        ),
      ),
    );
  }
}
