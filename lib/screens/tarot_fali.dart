import 'package:flutter/material.dart';

class TarotFaliPage extends StatefulWidget {
  const TarotFaliPage({super.key});
  @override
  _TarotFaliPageState createState() => _TarotFaliPageState();
}

class _TarotFaliPageState extends State<TarotFaliPage>
    with SingleTickerProviderStateMixin {
  final int total = 6;
  late final AnimationController _ctrl;
  final List<bool> _chosen = [];
  List<Animation<Offset>> _animations = [];

  @override
  void initState() {
    super.initState();
    _chosen.addAll(List.filled(total, false));
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animations = List.generate(total, (i) {
      final start = i * 0.1;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(2, -2),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      ));
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _cardName(int i) {
    return ['Fool','Magician','High Priestess','Empress','Lovers','Chariot'][i];
  }

  Widget _buildCard(int i) {
    final chosen = _chosen[i];
    return SlideTransition(
      position: _animations[i],
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_chosen.where((c) => c).length < 3 || chosen) {
              _chosen[i] = !chosen;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: chosen
                ? Border.all(color: Colors.purple, width: 4)
                : null,
            boxShadow: chosen
                ? [BoxShadow(color: Colors.purpleAccent, blurRadius: 8)]
                : null,
          ),
          child: Image.asset(
            'assets/tarot/${_cardName(i).toLowerCase()}.png',
            height: 100,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chosenCount = _chosen.where((c) => c).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Tarot Falı')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: List.generate(total, (i) {
                return Positioned(
                  top: 50,
                  left: 20 + i * 60,
                  child: _buildCard(i),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: chosenCount == 3
                  ? () {
                      // Seçilen üç karta göre fal göster
                      final selected = List.generate(total, (i) => i)
                          .where((i) => _chosen[i])
                          .map((i) => _cardName(i))
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TarotResultPage(selected),
                        ),
                      );
                    }
                  : null,
              child: Text('Falımı Göster ($chosenCount / 3)'),
            ),
          ),
        ],
      ),
    );
  }
}

class TarotResultPage extends StatelessWidget {
  final List<String> cards;
  const TarotResultPage(this.cards, {super.key});

  @override
  Widget build(BuildContext context) {
    final explanations = cards.map((c) {
      switch (c) {
        case 'Fool':
          return 'The Fool: Yeni başlangıçlar, masumiyet.';
        case 'Magician':
          return 'The Magician: Yaratıcılık ve irade.';
        // ...
        default:
          return c;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Seçilen Kartlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: explanations
            .map((t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(t, style: const TextStyle(fontSize: 18)),
                ))
            .toList(),
      ),
    );
  }
}
