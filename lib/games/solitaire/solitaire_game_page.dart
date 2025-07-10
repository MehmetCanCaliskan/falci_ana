import 'package:flutter/material.dart';
import '../../coin_service.dart'; // jeton servisini dahil et
import 'game_screen.dart'; // embed edilen oyun

class SolitaireGamePage extends StatefulWidget {
  const SolitaireGamePage({super.key});

  @override
  State<SolitaireGamePage> createState() => _SolitaireGamePageState();
}

class _SolitaireGamePageState extends State<SolitaireGamePage> {
  bool _rewardGiven = false;

  void _onGameWon() async {
    if (_rewardGiven) return;
    await CoinService().addCoins(5);
    setState(() => _rewardGiven = true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('+5 jeton kazandın! 🎉')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🃏 Solitaire')),
      body: GameScreen(onWin: _onGameWon),
    );
  }
}
