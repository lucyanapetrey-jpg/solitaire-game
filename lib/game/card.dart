enum Suit { hearts, diamonds, clubs, spades }

extension SuitX on Suit {
  bool get isRed => this == Suit.hearts || this == Suit.diamonds;
  String get symbol => switch (this) {
        Suit.hearts => '♥',
        Suit.diamonds => '♦',
        Suit.clubs => '♣',
        Suit.spades => '♠',
      };
}

class GameCard {
  final Suit suit;
  final int rank; // 1=A, 11=J, 12=Q, 13=K
  bool faceUp;

  GameCard({required this.suit, required this.rank, this.faceUp = false});

  String get rankLabel => switch (rank) {
        1 => 'A',
        11 => 'J',
        12 => 'Q',
        13 => 'K',
        _ => '$rank',
      };

  bool canStackOnTableau(GameCard other) {
    return faceUp &&
        other.faceUp &&
        other.suit.isRed != suit.isRed &&
        other.rank == rank + 1;
  }

  bool canPlaceOnFoundation(GameCard? top) {
    if (!faceUp) return false;
    if (top == null) return rank == 1;
    return top.suit == suit && top.rank == rank - 1;
  }
}
