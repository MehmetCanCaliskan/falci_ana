import 'package:flutter/material.dart';
import 'card_column.dart';
import 'playing_card.dart';
import 'transformed_card.dart';

class EmptyCardDeck extends StatefulWidget {
  final CardSuit cardSuit;
  final List<PlayingCard> cardsAdded;
  final CardAcceptCallback onCardAdded;
  final int? columnIndex;

  const EmptyCardDeck({
    required this.cardSuit,
    required this.cardsAdded,
    required this.onCardAdded,
    this.columnIndex,
    Key? key,
  }) : super(key: key);

  @override
  _EmptyCardDeckState createState() => _EmptyCardDeckState();
}

class _EmptyCardDeckState extends State<EmptyCardDeck> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      builder: (context, listOne, listTwo) {
        return widget.cardsAdded.isEmpty
            ? Opacity(
                opacity: 0.7,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                  ),
                  height: 60.0,
                  width: 40,
                  child: Center(
                    child: Image(
                      height: 20,
                      image: _suitToImage(),
                    ),
                  ),
                ),
              )
            : TransformedCard(
                playingCard: widget.cardsAdded.last,
                columnIndex: widget.columnIndex ?? 0, // 🔥 burası düzeldi
                attachedCards: [widget.cardsAdded.last],
              );
      },
      onWillAccept: (value) {
        if (value == null || value["cards"] == null) return false;

        final cardAdded = value["cards"].last as PlayingCard;
        if (cardAdded.cardSuit == widget.cardSuit) {
          if (CardType.values.indexOf(cardAdded.cardType) ==
              widget.cardsAdded.length) {
            return true;
          }
        }
        return false;
      },
      onAccept: (value) {
        widget.onCardAdded(
          value["cards"] as List<PlayingCard>,
          value["fromIndex"] as int,
        );
      },
    );
  }

  AssetImage _suitToImage() {
    switch (widget.cardSuit) {
      case CardSuit.hearts:
        return const AssetImage('assets/solitaire/hearts.png');
      case CardSuit.diamonds:
        return const AssetImage('assets/solitaire/diamonds.png');
      case CardSuit.clubs:
        return const AssetImage('assets/solitaire/clubs.png');
      case CardSuit.spades:
        return const AssetImage('assets/solitaire/spades.png');
    }
  }
}

