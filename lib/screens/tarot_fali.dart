import 'dart:math';
import 'package:flutter/material.dart';

class TarotFaliPage extends StatefulWidget {
  const TarotFaliPage({Key? key}) : super(key: key);

  @override
  State<TarotFaliPage> createState() => _TarotFaliPageState();
}

class _TarotFaliPageState extends State<TarotFaliPage>
    with TickerProviderStateMixin {
  List<int> selectedCards = [];
  List<AnimationController> controllers = [];
  List<Animation<Offset>> animations = [];
  final int totalCards = 6 * 13; // 6 sütun x 13 sıra

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < totalCards; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      final animation = Tween<Offset>(
        begin: const Offset(0, -2),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
      controllers.add(controller);
      animations.add(animation);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < totalCards; i++) {
        Future.delayed(Duration(milliseconds: 20 * i), () {
          controllers[i].forward();
        });
      }
    });
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void onCardTap(int index) {
    if (selectedCards.contains(index) || selectedCards.length >= 3) return;
    setState(() {
      selectedCards.add(index);
    });

    if (selectedCards.length == 3) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TarotResultPage(cards: selectedCards),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lütfen 3 kart seçiniz')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, // 6 sütun
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: totalCards,
            itemBuilder: (context, index) {
              return SlideTransition(
                position: animations[index],
                child: GestureDetector(
                  onTap: () => onCardTap(index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedCards.contains(index)
                              ? Colors.greenAccent
                              : Colors.white,
                          width: 2),
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        image:
                            AssetImage('assets/tarot/tarot_card_back.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class TarotResultPage extends StatelessWidget {
  final List<int> cards;
  const TarotResultPage({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fal Sonucu')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < cards.length; i++)
              Text('Kart ${i + 1}: Kart ID ${cards[i]}'),
          ],
        ),
      ),
    );
  }
}
