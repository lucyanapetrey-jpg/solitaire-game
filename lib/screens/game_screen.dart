import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/card.dart';
import '../game/klondike.dart';
import '../services/rewards_service.dart';
import 'shop_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Klondike _game = Klondike();
  final _missions = MissionsService();
  final _rewards = RewardsService();
  final List<Klondike> _undoStack = [];
  bool _usedUndo = false;
  int _moveCount = 0;
  int _diamonds = 0;
  Map<String, int> _powers = {};

  @override
  void initState() {
    super.initState();
    _game.newGame();
    _missions.increment('play_5_games');
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    final d = await _rewards.getDiamonds();
    final p = await SharedPreferences.getInstance();
    final powers = <String, int>{};
    for (final id in ['hint', 'undo_all', 'shuffle', 'peek']) {
      powers[id] = p.getInt('power_$id') ?? 0;
    }
    if (!mounted) return;
    setState(() {
      _diamonds = d;
      _powers = powers;
    });
  }

  Klondike _cloneGame(Klondike src) {
    final dst = Klondike();
    dst.tableau.clear();
    dst.tableau.addAll(src.tableau.map((p) => p.map((c) => GameCard(
        suit: c.suit, rank: c.rank, faceUp: c.faceUp)).toList()));
    dst.foundations.clear();
    dst.foundations.addAll(src.foundations.map((p) => p.map((c) => GameCard(
        suit: c.suit, rank: c.rank, faceUp: c.faceUp)).toList()));
    dst.stock.clear();
    dst.stock.addAll(src.stock.map((c) => GameCard(
        suit: c.suit, rank: c.rank, faceUp: c.faceUp)));
    dst.waste.clear();
    dst.waste.addAll(src.waste.map((c) => GameCard(
        suit: c.suit, rank: c.rank, faceUp: c.faceUp)));
    return dst;
  }

  void _saveSnap() {
    _undoStack.add(_cloneGame(_game));
    if (_undoStack.length > 10) _undoStack.removeAt(0);
    _moveCount++;
    _missions.increment('fifty_moves');
  }

  void _restoreSnap(Klondike snap) {
    _game.tableau.clear();
    _game.tableau.addAll(snap.tableau);
    _game.foundations.clear();
    _game.foundations.addAll(snap.foundations);
    _game.stock.clear();
    _game.stock.addAll(snap.stock);
    _game.waste.clear();
    _game.waste.addAll(snap.waste);
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      _restoreSnap(_undoStack.removeLast());
      _usedUndo = true;
    });
    HapticFeedback.lightImpact();
  }

  void _onTapCard(GameCard card) {
    if (!_isTopOfPile(card)) return;
    _saveSnap();
    setState(() {
      if (!_game.autoMoveToFoundation(card)) {
        _undoStack.removeLast();
        _moveCount--;
      } else {
        _missions.increment('foundation_50');
        _checkWin();
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
      _missions.increment('first_win');
      _missions.increment('three_wins');
      _missions.increment('ten_wins');
      if (!_usedUndo) {
        _missions.increment('no_undo_win');
      }
      _rewards.addDiamonds(20); // win bonus
      Future.microtask(() {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: const Color(0xFF1B5E20),
            title: const Text('🎉 Câștigat!',
                style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Felicitări! Ai aranjat toate cărțile.',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond, color: Color(0xFF80DEEA)),
                      const SizedBox(width: 8),
                      const Text('+20',
                          style: TextStyle(
                              color: Color(0xFFFFD740),
                              fontSize: 24,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  setState(() {
                    _game.newGame();
                    _undoStack.clear();
                    _usedUndo = false;
                    _moveCount = 0;
                  });
                  _missions.increment('play_5_games');
                },
                child: const Text('Joc Nou', style: TextStyle(color: Color(0xFFFFD740))),
              ),
            ],
          ),
        );
      });
    }
  }

  Future<void> _usePower(String id) async {
    if ((_powers[id] ?? 0) <= 0) {
      // not owned, send to shop
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopScreen()),
      );
      _loadCounters();
      return;
    }
    final p = await SharedPreferences.getInstance();
    await p.setInt('power_$id', (_powers[id] ?? 0) - 1);
    _missions.increment('use_3_powers');
    HapticFeedback.mediumImpact();
    setState(() {});
    if (id == 'undo_all') {
      while (_undoStack.isNotEmpty) {
        _restoreSnap(_undoStack.removeLast());
      }
      _moveCount = 0;
      setState(() {});
    } else if (id == 'shuffle') {
      _saveSnap();
      _game.stock.shuffle();
      setState(() {});
    } else if (id == 'hint') {
      _showHint();
    } else if (id == 'peek') {
      _showPeek();
    }
    _loadCounters();
  }

  void _showHint() {
    // Find any card that can go to foundation
    for (final pile in _game.tableau) {
      if (pile.isEmpty) continue;
      final card = pile.last;
      for (var i = 0; i < 4; i++) {
        if (card.canPlaceOnFoundation(
            _game.foundations[i].isEmpty ? null : _game.foundations[i].last)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mută ${card.rankLabel}${card.suit.symbol} la fundație!')),
          );
          return;
        }
      }
    }
    if (_game.waste.isNotEmpty) {
      final card = _game.waste.last;
      for (var i = 0; i < 4; i++) {
        if (card.canPlaceOnFoundation(
            _game.foundations[i].isEmpty ? null : _game.foundations[i].last)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mută ${card.rankLabel}${card.suit.symbol} de la waste la fundație!')),
          );
          return;
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trage o carte din stack')),
    );
  }

  void _showPeek() {
    final next3 = _game.stock.reversed.take(3).toList();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Următoarele 3 cărți'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: next3.isEmpty
              ? [const Text('Stack gol')]
              : next3.map((card) {
                  final color = card.suit.isRed ? Colors.red : Colors.black;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black54),
                    ),
                    child: Column(
                      children: [
                        Text(card.rankLabel,
                            style: TextStyle(
                                color: color,
                                fontSize: 24,
                                fontWeight: FontWeight.w900)),
                        Text(card.suit.symbol,
                            style: TextStyle(color: color, fontSize: 24)),
                      ],
                    ),
                  );
                }).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Solitaire'),
            const SizedBox(width: 16),
            const Icon(Icons.diamond, color: Color(0xFF80DEEA), size: 18),
            const SizedBox(width: 4),
            Text('$_diamonds',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w900)),
          ],
        ),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _game.newGame();
                  _undoStack.clear();
                  _usedUndo = false;
                  _moveCount = 0;
                });
              }),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2818), Color(0xFF1B5E20)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(builder: (context, c) {
                  final w = c.maxWidth;
                  // 25% bigger cards: gap factor was 8*7=56, now use 6*7=42 → cards larger
                  final gap = 6.0;
                  final cardW = (w - gap * 7 - 16) / 7;
                  final cardH = cardW * 1.5;
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      _topRow(cardW, cardH, gap),
                      const SizedBox(height: 16),
                      Expanded(child: _tableauRow(cardW, cardH, gap)),
                    ],
                  );
                }),
              ),
              _powersBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _powersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: const Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          for (final pw in [
            ('hint', Icons.lightbulb, 'Indiciu', Color(0xFFFFB300)),
            ('undo_all', Icons.history, 'Reset', Color(0xFF8E24AA)),
            ('shuffle', Icons.shuffle, 'Amestec', Color(0xFF1E88E5)),
            ('peek', Icons.visibility, 'Privește', Color(0xFF00ACC1)),
          ])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _usePower(pw.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: pw.$4.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: pw.$4),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(pw.$2, color: pw.$4, size: 24),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${_powers[pw.$1] ?? 0}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(pw.$3,
                            style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _topRow(double w, double h, double gap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _saveSnap();
              setState(() => _game.drawFromStock());
            },
            child: _stockPile(w, h),
          ),
          SizedBox(width: gap),
          _wastePile(w, h),
          const Spacer(),
          for (var i = 0; i < 4; i++) ...[
            DragTarget<List<GameCard>>(
              onAcceptWithDetails: (d) {
                if (d.data.length != 1) return;
                _saveSnap();
                setState(() {
                  if (_game.moveToFoundation(d.data.first, i)) {
                    _missions.increment('foundation_50');
                    _checkWin();
                  } else {
                    _undoStack.removeLast();
                    _moveCount--;
                  }
                });
              },
              builder: (ctx, _, __) => _foundationPile(i, w, h),
            ),
            if (i < 3) SizedBox(width: gap),
          ],
        ],
      ),
    );
  }

  Widget _stockPile(double w, double h) {
    return SizedBox(
      width: w,
      height: h,
      child: _game.stock.isEmpty ? _emptyPile('↻') : _cardBack(w, h),
    );
  }

  Widget _wastePile(double w, double h) {
    if (_game.waste.isEmpty) return SizedBox(width: w, height: h, child: _emptyPile(''));
    return _draggableCard([_game.waste.last], w, h);
  }

  Widget _foundationPile(int i, double w, double h) {
    final pile = _game.foundations[i];
    if (pile.isEmpty) {
      return SizedBox(width: w, height: h, child: _emptyPile(['♠', '♥', '♦', '♣'][i]));
    }
    return _draggableCard([pile.last], w, h);
  }

  Widget _tableauRow(double w, double h, double gap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var col = 0; col < 7; col++) ...[
            Expanded(child: _tableauColumn(col, w, h)),
            if (col < 6) SizedBox(width: gap),
          ],
        ],
      ),
    );
  }

  Widget _tableauColumn(int col, double w, double h) {
    final pile = _game.tableau[col];
    return DragTarget<List<GameCard>>(
      onAcceptWithDetails: (d) {
        _saveSnap();
        setState(() {
          if (!_game.moveToTableau(d.data, col)) {
            _undoStack.removeLast();
            _moveCount--;
          } else {
            _checkWin();
          }
        });
      },
      builder: (ctx, _, __) {
        if (pile.isEmpty) {
          return SizedBox(width: w, height: h, child: _emptyPile(''));
        }
        const overlap = 26.0;
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
            height: h + (cards.length - 1) * 26,
            child: Stack(
              children: [
                for (var i = 0; i < cards.length; i++)
                  Positioned(top: i * 26.0, child: _cardFront(cards[i], w, h)),
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: SizedBox(width: w, height: h),
      child: GestureDetector(
        onTap: () {
          _saveSnap();
          setState(() {
            if (!_game.autoMoveToFoundation(top)) {
              _undoStack.removeLast();
              _moveCount--;
            } else {
              _missions.increment('foundation_50');
              _checkWin();
            }
          });
        },
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
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF5F5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 3, offset: Offset(1, 2)),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.rankLabel,
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: w * 0.34)),
              Text(card.suit.symbol,
                  style: TextStyle(color: color, fontSize: w * 0.34, height: 0.9)),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: Transform.rotate(
              angle: 3.14159,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.rankLabel,
                      style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: w * 0.22)),
                  Text(card.suit.symbol,
                      style: TextStyle(color: color, fontSize: w * 0.22, height: 0.9)),
                ],
              ),
            ),
          ),
          // Center suit symbol
          Center(
            child: Text(card.suit.symbol,
                style: TextStyle(color: color!.withValues(alpha: 0.25), fontSize: w * 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _cardBack(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 0.5, 1],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black54),
      ),
      child: const Center(
        child: Icon(Icons.auto_awesome, color: Colors.white24, size: 32),
      ),
    );
  }

  Widget _emptyPile(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white38, fontSize: 28)),
    );
  }
}
