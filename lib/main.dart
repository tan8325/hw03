import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const MaterialApp(home: GameScreen()),
    );
  }
}

class GameProvider extends ChangeNotifier {
  List<String> values = ['🔥', '🌈', '🍀', '🎩', '🎸', '🚀', '🎯', '💎']
      .expand((e) => [e, e])
      .toList()
    ..shuffle();
  List<bool> flipped = List.generate(16, (_) => false);
  List<int> selected = [];
  bool isGameWon = false;

  void flipCard(int index) {
    if (selected.length == 2 || flipped[index] || isGameWon) return;
    flipped[index] = true;
    selected.add(index);
    notifyListeners();
    if (selected.length == 2) Future.delayed(const Duration(milliseconds: 500), _checkMatch);
  }

  void _checkMatch() {
    if (values[selected[0]] != values[selected[1]]) {
      flipped[selected[0]] = flipped[selected[1]] = false;
    }
    selected.clear();
    _checkWinCondition();
    notifyListeners();
  }

  void _checkWinCondition() {
    if (flipped.every((e) => e)) {
      isGameWon = true;
    }
  }

  void resetGame() {
    values.shuffle();
    flipped.fillRange(0, flipped.length, false);
    selected.clear();
    isGameWon = false;
    notifyListeners();
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('HW03')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: CardGrid()),
          if (game.isGameWon)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("You win!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ElevatedButton(onPressed: game.resetGame, child: const Text('Restart')),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class CardGrid extends StatelessWidget {
  const CardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: 16,
      itemBuilder: (_, index) => CardWidget(index: index),
    );
  }
}

class CardWidget extends StatefulWidget {
  final int index;
  const CardWidget({super.key, required this.index});

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final isFlipped = game.flipped[widget.index];

    if (isFlipped && _controller.status == AnimationStatus.dismissed) _controller.forward();
    if (!isFlipped && _controller.status == AnimationStatus.completed) _controller.reverse();

    return GestureDetector(
      onTap: () => game.flipCard(widget.index),
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (_, __) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(_flipAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blueAccent),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
            ),
            child: Center(
              child: Text(isFlipped ? game.values[widget.index] : "❓", style: const TextStyle(fontSize: 32)),
            ),
          ),
        ),
      ),
    );
  }
}
