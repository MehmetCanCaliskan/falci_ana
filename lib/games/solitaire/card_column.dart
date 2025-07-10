import 'package:flutter/material.dart';
import 'playing_card.dart';
import 'transformed_card.dart';

typedef CardAcceptCallback = void Function(List<PlayingCard> card, int fromIndex);

// Bu widget bir kart sütunu temsil eder (Stack içinde üst üste yerleştirilen kartlar)
class CardColumn extends StatefulWidget {
  final List<PlayingCard> cards;
  final CardAcceptCallback onCardsAdded;
  final int columnIndex;

  const CardColumn({
    required this.cards,
    required this.onCardsAdded,
    required this.columnIndex,
    Key? key,
  }) : super(key: key);

  @override
  _CardColumnState createState() => _CardColumnState();
}

class _CardColumnState extends State<CardColumn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 13.0 * 15.0,
      width: 70.0,
      margin: const EdgeInsets.all(2.0),
      child: DragTarget<Map<String, dynamic>>(
        builder: (context, listOne, listTwo) {
          return Stack(
            children: widget.cards.map((card) {
              int index = widget.cards.indexOf(card);
              return TransformedCard(
                playingCard: card,
                transformIndex: index,
                attachedCards: widget.cards.sublist(index),
                columnIndex: widget.columnIndex,
              );
            }).toList(),
          );
        },
        onWillAccept: (value) {
          if (value == null || value["cards"] == null) return false;
          if (widget.cards.isEmpty) return true;

          final List<PlayingCard> draggedCards = value["cards"] as List<PlayingCard>;
          final PlayingCard firstCard = draggedCards.first;

          final PlayingCard lastColumnCard = widget.cards.last;

          if (firstCard.cardColor == lastColumnCard.cardColor) return false;

          int lastColumnIndex = CardType.values.indexOf(lastColumnCard.cardType);
          int draggedCardIndex = CardType.values.indexOf(firstCard.cardType);

          return lastColumnIndex == draggedCardIndex + 1;
        },
        onAccept: (value) {
          final cards = value["cards"] as List<PlayingCard>;
          final fromIndex = value["fromIndex"] as int;
          widget.onCardsAdded(cards, fromIndex);
        },
      ),
    );
  }
}
