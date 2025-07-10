import 'package:flutter/material.dart';
import 'card_column.dart';
import 'playing_card.dart';

// TransformedCard makes the card draggable and translates it according to
// position in the stack.
class TransformedCard extends StatefulWidget {
  final PlayingCard playingCard;
  final double transformDistance;
  final int transformIndex;
  final int columnIndex;
  final List<PlayingCard> attachedCards;

  const TransformedCard({
    required this.playingCard,
    this.transformDistance = 15.0,
    this.transformIndex = 0,
    required this.columnIndex,
    required this.attachedCards,
    Key? key,
  }) : super(key: key);

  @override
  _TransformedCardState createState() => _TransformedCardState();
}

class _TransformedCardState extends State<TransformedCard> {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, widget.transformIndex * widget.transformDistance),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    if (!widget.playingCard.faceUp) {
      debugPrint("📦 Kart kapalı — arka yüz gösteriliyor: ${widget.playingCard.cardSuit}");
      return Material(
        color: Colors.transparent,
        child: Container(
          height: 84.0,
          width: 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            border: Border.all(color: Colors.black),
            image: const DecorationImage(
              image: AssetImage('assets/solitaire/back.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    debugPrint("🟢 Kart sürüklenebilir: ${widget.playingCard.cardSuit} ${widget.playingCard.cardType}");
    debugPrint("📦 attachedCards: ${widget.attachedCards.length}");
    debugPrint("📦 fromIndex: ${widget.columnIndex}");

    return Draggable<Map<String, dynamic>>(
      data: {
        "cards": widget.attachedCards,
        "fromIndex": widget.columnIndex,
      },
      feedback: _buildFaceUpCard(), // artık düzgün çalışır
      child: _buildFaceUpCard(),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: () {
        debugPrint("🎯 Sürükleme başladı: ${widget.playingCard.cardSuit} ${widget.playingCard.cardType}");
      },
      onDraggableCanceled: (_, __) {
        debugPrint("❌ Sürükleme iptal edildi");
      },
      onDragEnd: (_) {
        debugPrint("✅ Sürükleme tamamlandı");
      },
    );
  }


  Widget _buildFaceUpCard() {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.white,
          border: Border.all(color: Colors.black),
        ),
        height: 84.0,
        width: 60,
        child: Stack(
          children: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Center(
                    child: Text(
                      _cardTypeToString(),
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Container(
                    height: 20.0,
                    child: _suitToImage(),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _cardTypeToString(),
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                    Container(
                      height: 10.0,
                      child: _suitToImage(),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cardTypeToString() {
    switch (widget.playingCard.cardType) {
      case CardType.one:
        return "1";
      case CardType.two:
        return "2";
      case CardType.three:
        return "3";
      case CardType.four:
        return "4";
      case CardType.five:
        return "5";
      case CardType.six:
        return "6";
      case CardType.seven:
        return "7";
      case CardType.eight:
        return "8";
      case CardType.nine:
        return "9";
      case CardType.ten:
        return "10";
      case CardType.jack:
        return "J";
      case CardType.queen:
        return "Q";
      case CardType.king:
        return "K";
      default:
        return "";
    }
  }

  Image _suitToImage() {
    switch (widget.playingCard.cardSuit) {
      case CardSuit.hearts:
        return Image.asset('assets/solitaire/hearts.png');
      case CardSuit.diamonds:
        return Image.asset('assets/solitaire/diamonds.png');
      case CardSuit.clubs:
        return Image.asset('assets/solitaire/clubs.png');
      case CardSuit.spades:
        return Image.asset('assets/solitaire/spades.png');
    }
  }

}
