import 'package:flutter/material.dart';
import '../games/solitaire/solitaire_game_page.dart';

class OyunlarMenusuPage extends StatelessWidget {
  const OyunlarMenusuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> games = [
      {
        'title': 'Solitaire',
        'image': 'assets/icons/solitaire.png',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SolitaireGamePage()),
          );
        },
      },
      {
        'title': 'Dino Koşusu',
        'image': 'assets/icons/dino.png',
        'onTap': () {
          // TODO: Dino oyununa yönlendir
        },
      },
      {
        'title': '2048',
        'image': 'assets/icons/2048.png',
        'onTap': () {
          // TODO: 2048 oyununa yönlendir
        },
      },
      {
        'title': 'Candy Crush',
        'image': 'assets/icons/crush.png',
        'onTap': () {
          // TODO: Match-3 oyununa yönlendir
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Oyna ve Jeton Kazan'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: games.map((game) {
          return GestureDetector(
            onTap: game['onTap'],
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final iconSize = constraints.maxWidth * 0.7;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(game['image'], width: iconSize, height: iconSize),
                      const SizedBox(height: 8),
                      Text(
                        game['title'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
