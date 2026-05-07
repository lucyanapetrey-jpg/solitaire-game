import 'package:flutter/material.dart';
import '../game/card.dart';
import '../game/klondike.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Klondike _game = Klondike();

  @override
  void initState() {
    super.initState();
    _game.newGame();
  }

  void _onTapCard(GameCard card) {
    setState(() {
      // try to auto-move to foundation if it's the top of a tableau or waste
      if (_isTopOfPile(card) && _game.autoMoveToFoundation(card)) {
        _checkWin();
        return;
      }
    });
  }

  bool _isTopOfPile(GameCard card) {
    for (final pile in _game.tableau) {
      if (pile.isNotEmpty && pile.last == card) return true;
    }
    if (_game.waste.isNotEmpty && _game.waste.last == card) return true;
    return false;
  }

  void _checkWin() {
    if (_game.isWon) {
      Future.microtask(() {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('🎉 Câștigat!'),
            content: const Text('Felicitări! Ai aranjat toate cărțile.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  setState(() => _game.newGame());
                },
                child: const Text('Joc Nou'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solitaire'),
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _game.newGame()),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          final cardW = (w - 8 * 7) / 7;
          final cardH = cardW * 1.45;
          return Column(
            children: [
              const SizedBox(height: 8),
              _topRow(cardW, cardH),
              const SizedBox(height: 16),
              Expanded(child: _tableauRow(cardW, cardH)),
            ],
          );
        }),
      ),
    );
  }

  Widget _topRow(double w, double h) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _game.drawFromStock()),
            child: _stockPile(w, h),
          ),
          const SizedBox(width: 4),
          _wastePile(w, h),
          const Spacer(),
          for (var i = 0; i < 4; i++) ...[
            DragTarget<List<GameCard>>(
              onAcceptWithDetails: (d) {
                if (d.data.length != 1) return;
                setState(() {
                  if (_game.moveToFoundation(d.data.first, i)) {
                    _checkWin();
                  }
                });
              },
              builder: (ctx, _, __) => _foundationPile(i, w, h),
            ),
            if (i < 3) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  Widget _stockPile(double w, double h) {
    return SizedBox(
      width: w,
      height: h,
      child: _game.stock.isEmpty
          ? _emptyPile('↻')
          : _cardBack(w, h),
    );
  }

  Widget _wastePile(double w, double h) {
    if (_game.waste.isEmpty) return SizedBox(width: w, height: h, child: _emptyPile(''));
    final card = _game.waste.last;
    return _draggableCard([card], w, h);
  }

  Widget _foundationPile(int i, double w, double h) {
    final pile = _game.foundations[i];
    if (pile.isEmpty) {
      return SizedBox(width: w, height: h, child: _emptyPile(_foundationSymbol(i)));
    }
    return _draggableCard([pile.last], w, h);
  }

  String _foundationSymbol(int i) => ['♠', '♥', '♦', '♣'][i];

  Widget _tableauRow(double w, double h) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var col = 0; col < 7; col++) ...[
            Expanded(child: _tableauColumn(col, w, h)),
            if (col < 6) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  Widget _tableauColumn(int col, double w, double h) {
    final pile = _game.tableau[col];
    return DragTarget<List<GameCard>>(
      onAcceptWithDetails: (d) {
        setState(() {
          if (_game.moveToTableau(d.data, col)) _checkWin();
        });
      },
      builder: (ctx, _, __) {
        if (pile.isEmpty) {
          return SizedBox(width: w, height: h, child: _emptyPile(''));
        }
        const overlap = 22.0;
        return SizedBox(
          width: w,
          height: h + (pile.length - 1) * overlap + 30,
          child: Stack(
            children: [
              for (var i = 0; i < pile.length; i++)
                Positioned(
                  top: i * overlap,
                  child: pile[i].faceUp
                      ? _draggableCard(pile.sublist(i), w, h)
                      : _cardBack(w, h),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _draggableCard(List<GameCard> cards, double w, double h) {
    final top = cards.first;
    return Draggable<List<GameCard>>(
      data: cards,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: SizedBox(
            width: w,
            height: h + (cards.length - 1) * 22,
            child: Stack(
              children: [
                for (var i = 0; i < cards.length; i++)
                  Positioned(top: i * 22.0, child: _cardFront(cards[i], w, h)),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: SizedBox(width: w, height: h),
      child: GestureDetector(
        onTap: () => _onTapCard(top),
        child: _cardFront(top, w, h),
      ),
    );
  }

  Widget _cardFront(GameCard card, double w, double h) {
    final color = card.suit.isRed ? Colors.red[700] : Colors.black;
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black54),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1))],
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.rankLabel,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: w * 0.28)),
          Text(card.suit.symbol,
              style: TextStyle(color: color, fontSize: w * 0.28, height: 0.9)),
        ],
      ),
    );
  }

  Widget _cardBack(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black54),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.diamond_outlined, color: Colors.white24, size: 28),
      ),
    );
  }

  Widget _emptyPile(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 24)),
    );
  }
}
