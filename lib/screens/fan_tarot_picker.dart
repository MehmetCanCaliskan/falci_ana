import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FanTarotPickerPage extends StatefulWidget {
  const FanTarotPickerPage({super.key});

  @override
  State<FanTarotPickerPage> createState() => _FanTarotPickerPageState();
}

class _FanTarotPickerPageState extends State<FanTarotPickerPage> {
  List<Map<String, dynamic>> tarotCards = [];
  List<Map<String, dynamic>> selectedCards = [];

  @override
  void initState() {
    super.initState();
    _loadTarotCards();
  }

  Future<void> _loadTarotCards() async {
    final jsonString = await rootBundle.loadString('assets/tarot_cards.json');
    final List data = json.decode(jsonString);
    setState(() {
      tarotCards = data.cast<Map<String, dynamic>>()..shuffle();
    });
  }

  void _onCardSelected(Map<String, dynamic> card) {
    if (selectedCards.contains(card) || selectedCards.length == 3) return;

    setState(() {
      selectedCards.add(card);
    });

    if (selectedCards.length == 3) {
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TarotResultPage(selectedCards: selectedCards),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tarot Falı")),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Seçilen kartlar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) {
                final card = index < selectedCards.length ? selectedCards[index] : null;
                return Container(
                  width: 90,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: card != null
                      ? Image.asset(card["image"], fit: BoxFit.cover)
                      : Center(
                          child: Text(
                            ["Geçmiş", "Şimdi", "Gelecek"][index],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                );
              }),
            ),
          ),
          const SizedBox(height: 30),
          // Kartlar scroll edilebilir
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: List.generate(tarotCards.length, (index) {
                  final card = tarotCards[index];
                  return Transform.translate(
                    offset: Offset(-index * 40.0, 0),
                    child: GestureDetector(
                      onTap: () => _onCardSelected(card),
                      child: Image.asset(
                        "assets/tarot/tarot_card_back.png",
                        width: 90,
                        height: 140,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class TarotResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> selectedCards;

  const TarotResultPage({super.key, required this.selectedCards});

  @override
  Widget build(BuildContext context) {
    final positions = ["Geçmiş", "Şimdi", "Gelecek"];
    final keys = ["past", "present", "future"];

    return Scaffold(
      appBar: AppBar(title: const Text("Fal Sonucu")),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: selectedCards.length,
          itemBuilder: (context, index) {
            final card = selectedCards[index];
            final position = positions[index];
            final key = keys[index];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$position - ${card["name"]}",
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Image.asset(card["image"], width: 120),
                const SizedBox(height: 8),
                Text(
                  card[key] is String ? card[key] : "Yorum bulunamadı.",
                  style: const TextStyle(color: Colors.white70),
                ),
                const Divider(color: Colors.white24, height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
