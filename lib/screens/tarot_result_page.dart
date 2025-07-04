import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TarotResultPage extends StatelessWidget {
  final List<String> selectedImages;

  const TarotResultPage(this.selectedImages, {super.key});

  Future<List<Map<String, dynamic>>> loadTarotCards() async {
    final jsonString = await rootBundle.loadString('assets/tarot_cards.json');
    final List data = json.decode(jsonString);
    return data.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final positionTitles = ["Geçmiş", "Şimdi", "Gelecek"];
    final positionKeys = ["past", "present", "future"];

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
                "past": "Bu kartın geçmiş yorumu bulunamadı.",
                "present": "Bu kartın şimdiki yorumu bulunamadı.",
                "future": "Bu kartın gelecek yorumu bulunamadı.",
              },
            );
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                        Text(
                          card["name"] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: matchedCards.length,
                    itemBuilder: (context, index) {
                      final card = matchedCards[index];
                      final title = positionTitles[index];
                      final key = positionKeys[index];
                      final text = card[key] ?? "Yorum bulunamadı.";

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$title Yorumu",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                text,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
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
