import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TarotFaliPage extends StatefulWidget {
  const TarotFaliPage({super.key});

  @override
  State<TarotFaliPage> createState() => _TarotFaliPageState();
}

class _TarotFaliPageState extends State<TarotFaliPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> tarotCards = [];
  List<String> allCards = [];

  List<String> selectedCards = [];
  List<bool> revealed = List.filled(6, false);
  List<AnimationController> controllers = [];
  List<Animation<double>> animations = [];
  bool allAnimated = false;

  @override
  @override
  void initState() {
    super.initState();
    print("[DEBUG] initState başladı");

    loadTarotCards().then((data) {
    setState(() {
      tarotCards = data;
      allCards = tarotCards.map((e) => e["image"] as String).toList();
      revealed = List.filled(allCards.length >= 6 ? 6 : allCards.length, false);

      // 💡 ANİMASYON KONTROLLERİ BURADA OLUŞTURULMALI
      for (int i = 0; i < revealed.length; i++) {
        final controller = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: this,
        );
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);

        controllers.add(controller);
        animations.add(animation);
      }
    });

    _startAnimations();
  });

  }



  Future<void> _startAnimations() async {
    print("[DEBUG] _startAnimations başladı. revealed.length = ${revealed.length}");

    for (int i = 0; i < revealed.length; i++) {
      await Future.delayed(Duration(milliseconds: 200));
      print("[DEBUG] Animating card $i");
      setState(() {
        revealed[i] = true;
      });
    }

    setState(() {
      allAnimated = true;
    });

    print("[DEBUG] Animasyon tamamlandı");
  }



  void _onCardTap(int index) {
    if (index >= controllers.length || index >= allCards.length) {
      print("[HATA] _onCardTap için geçersiz index: $index");
      return;
    }

    if (!selectedCards.contains(allCards[index])) {
      controllers[index].forward();
      setState(() {
        selectedCards.add(allCards[index]);
      });

      if (selectedCards.length == 3) {
        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TarotResultPage(selectedCards),
            ),
          );
        });
      }
    }
  }


  Widget _buildCard(int index) {
    print("[DEBUG] _buildCard çağrıldı - index: $index");

    if (index >= allCards.length) {
      print("[ERROR] allCards[$index] erişilemedi. Mevcut uzunluk: ${allCards.length}");
      return const SizedBox.shrink();
    }

    bool isSelected = selectedCards.contains(allCards[index]);

    return GestureDetector(
      onTap: allAnimated ? () => _onCardTap(index) : null,
      child: AnimatedOpacity(
        opacity: index < revealed.length && revealed[index] ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: AnimatedBuilder(
          animation: index < animations.length
              ? animations[index]
              : AlwaysStoppedAnimation(0.0),
          builder: (context, child) {
            final rotateValue = index < animations.length
                ? animations[index].value
                : 0.0;
            final angle = pi * rotateValue;
            final isFront = rotateValue < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isFront
                  ? Image.asset('assets/tarot/tarot_card_back.png')
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: Image.asset(allCards[index]),
                    ),
            );
          },
        ),
      ),
    );
  }




  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("[DEBUG] build() çalıştı. allCards.length = ${allCards.length}");

    if (allCards.isEmpty || allCards.length < 6) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tarot Falı")),
      body: Center(
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: List.generate(
            6,
            (index) => _buildCard(index),
          ),
        ),
      ),
    );
  }

}

class TarotResultPage extends StatelessWidget {
  final List<String> selectedImages; // Örn: assets/tarot/m00.jpg gibi
  const TarotResultPage(this.selectedImages, {super.key});

  Future<List<Map<String, dynamic>>> loadTarotCards() async {
    final jsonString = await rootBundle.loadString('assets/tarot_cards.json');
    final List data = json.decode(jsonString);
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fal Sonucu")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadTarotCards(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allCards = snapshot.data!;
          final matchedCards = selectedImages.map((selectedPath) {
            return allCards.firstWhere(
              (card) => card["image"] == selectedPath,
              orElse: () => {
                "name": "Bilinmeyen Kart",
                "image": selectedPath,
                "description": "Bu kart için bir açıklama bulunamadı."
              },
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Kart görselleri ve isimleri (küçük boyutlu)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: matchedCards.map((card) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 160,
                          child: Image.asset(card["image"]!, fit: BoxFit.cover),
                        ),
                        const SizedBox(height: 8),
                        Text(card["name"] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                // Kart açıklamaları
                Expanded(
                  child: ListView.builder(
                    itemCount: matchedCards.length,
                    itemBuilder: (context, index) {
                      final card = matchedCards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            card["description"] ?? "",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



Future<List<Map<String, dynamic>>> loadTarotCards() async {
  final jsonString = await rootBundle.loadString('assets/tarot_cards.json');
  final List data = json.decode(jsonString);
  return data.cast<Map<String, dynamic>>();
}
