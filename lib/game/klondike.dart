import 'dart:math';
import 'card.dart';

class Klondike {
  final List<List<GameCard>> tableau = List.generate(7, (_) => []);
  final List<List<GameCard>> foundations = List.generate(4, (_) => []);
  final List<GameCard> stock = [];
  final List<GameCard> waste = [];

  void newGame() {
    tableau.forEach((p) => p.clear());
    foundations.forEach((p) => p.clear());
    stock.clear();
    waste.clear();

    final deck = <GameCard>[];
    for (final s in Suit.values) {
      for (var r = 1; r <= 13; r++) {
        deck.add(GameCard(suit: s, rank: r));
      }
    }
    deck.shuffle(Random());

    var idx = 0;
    for (var col = 0; col < 7; col++) {
      for (var row = 0; row <= col; row++) {
        final card = deck[idx++];
        if (row == col) card.faceUp = true;
        tableau[col].add(card);
      }
    }
    while (idx < deck.length) {
      stock.add(deck[idx++]);
    }
  }

  void drawFromStock() {
    if (stock.isEmpty) {
      // recycle waste back to stock
      while (waste.isNotEmpty) {
        final c = waste.removeLast();
        c.faceUp = false;
        stock.add(c);
      }
      return;
    }
    final c = stock.removeLast();
    c.faceUp = true;
    waste.add(c);
  }

  bool moveToFoundation(GameCard card, int foundationIdx) {
    final f = foundations[foundationIdx];
    if (!card.canPlaceOnFoundation(f.isEmpty ? null : f.last)) return false;
    _removeCard(card);
    f.add(card);
    _flipTopOfTableau();
    return true;
  }

  bool moveToTableau(List<GameCard> cards, int tableauIdx) {
    if (cards.isEmpty) return false;
    final t = tableau[tableauIdx];
    final first = cards.first;
    if (t.isEmpty) {
      if (first.rank != 13) return false;
    } else {
      if (!first.canStackOnTableau(t.last)) return false;
    }
    for (final c in cards) {
      _removeCard(c);
    }
    t.addAll(cards);
    _flipTopOfTableau();
    return true;
  }

  void _removeCard(GameCard card) {
    for (final pile in tableau) {
      final i = pile.indexOf(card);
      if (i >= 0) {
        pile.removeAt(i);
        return;
      }
    }
    if (waste.isNotEmpty && waste.last == card) {
      waste.removeLast();
      return;
    }
    for (final f in foundations) {
      if (f.isNotEmpty && f.last == card) {
        f.removeLast();
        return;
      }
    }
  }

  void _flipTopOfTableau() {
    for (final pile in tableau) {
      if (pile.isNotEmpty && !pile.last.faceUp) {
        pile.last.faceUp = true;
      }
    }
  }

  bool autoMoveToFoundation(GameCard card) {
    for (var i = 0; i < 4; i++) {
      if (moveToFoundation(card, i)) return true;
    }
    return false;
  }

  bool get isWon => foundations.every((f) => f.length == 13);
}
