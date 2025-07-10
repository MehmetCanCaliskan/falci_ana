
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TarotFaliPage extends StatefulWidget {
  const TarotFaliPage({super.key});

  @override
  State<TarotFaliPage> createState() => _TarotFaliPageState();
}

class _TarotFaliPageState extends State<TarotFaliPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> tarotCards = [];
  List<Map<String, dynamic>> selectedCards = [];
  List<GlobalKey> slotKeys = [GlobalKey(), GlobalKey(), GlobalKey()];
  double rotationAngle = 0.0;

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

  void _onCardSelected(GlobalKey fromKey, Map<String, dynamic> card) {
    if (selectedCards.contains(card) || selectedCards.length == 3) return;

    final toKey = slotKeys[selectedCards.length];
    _animateCardToTarget(card, fromKey, toKey);
  }

  void _animateCardToTarget(Map<String, dynamic> card, GlobalKey fromKey, GlobalKey toKey) {
    final overlay = Overlay.of(context);
    final fromBox = fromKey.currentContext?.findRenderObject() as RenderBox?;
    final toBox = toKey.currentContext?.findRenderObject() as RenderBox?;

    if (fromBox == null || toBox == null) return;

    final start = fromBox.localToGlobal(Offset.zero);
    final end = toBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return _FlyingCardOverlay(
          card: card,
          start: start,
          end: end,
          onDone: () {
            entry.remove();
            setState(() {
              selectedCards.add(card);
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
            });
          },
        );
      },
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final fanCards = tarotCards.take(30).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Tarot Falı")),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(3, (index) {
                    final card = index < selectedCards.length ? selectedCards[index] : null;
                    return Container(
                      key: slotKeys[index],
                      width: 100,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                      ),
                      child: card != null
                          ? Image.asset(card["image"], fit: BoxFit.cover)
                          : Center(child: Text(["Geçmiş", "Şimdi", "Gelecek"][index])),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      rotationAngle += details.delta.dx * 0.01;
                    });
                  },
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: fanCards.asMap().entries.map((entry) {
                          final i = entry.key;
                          final card = entry.value;
                          final total = fanCards.length;
                          final angleStep = pi / 1.5 / total;
                          final angle = -pi / 3 + i * angleStep + rotationAngle;

                          final radius = 300.0;
                          final x = radius * cos(angle);
                          final y = radius * sin(angle);
                          final key = GlobalKey();

                          return Positioned(
                            left: x + MediaQuery.of(context).size.width / 2 - 40,
                            top: y + 100,
                            child: Transform.rotate(
                              angle: angle - pi / 2,
                              child: GestureDetector(
                                onTap: () => _onCardSelected(key, card),
                                child: Container(
                                  key: key,
                                  width: 80,
                                  height: 120,
                                  child: Image.asset("assets/tarot/tarot_card_back.png"),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlyingCardOverlay extends StatefulWidget {
  final Map<String, dynamic> card;
  final Offset start;
  final Offset end;
  final VoidCallback onDone;

  const _FlyingCardOverlay({
    required this.card,
    required this.start,
    required this.end,
    required this.onDone,
  });

  @override
  State<_FlyingCardOverlay> createState() => _FlyingCardOverlayState();
}

class _FlyingCardOverlayState extends State<_FlyingCardOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _position = Tween<Offset>(
      begin: widget.start,
      end: widget.end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _position,
        builder: (context, child) {
          return Positioned(
            left: _position.value.dx,
            top: _position.value.dy,
            child: Image.asset(
              widget.card["image"],
              width: 80,
              height: 120,
            ),
          );
        },
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
                Text("$position - ${card["name"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 8),
                Image.asset(card["image"], width: 100),
                const SizedBox(height: 8),
                Text(
                  (card[key] is String ? card[key] : "Yorum bulunamadı."),
                  style: const TextStyle(fontSize: 16),
                ),
                const Divider(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }
}
