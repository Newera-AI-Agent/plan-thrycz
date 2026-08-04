import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'src/game_world.dart';

void main() {
  runApp(const MarioApp());
}

class MarioApp extends StatelessWidget {
  const MarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MarioScreen(),
    );
  }
}

class MarioScreen extends StatefulWidget {
  const MarioScreen({super.key});

  @override
  State<MarioScreen> createState() => _MarioScreenState();
}

class _MarioScreenState extends State<MarioScreen> {
  late final MarioWorld game;

  @override
  void initState() {
    super.initState();
    game = MarioWorld();
  }

  void _onLeftDown(_) => game.player.moveLeft();
  void _onLeftUp(_) => game.player.stopHorizontal();
  void _onRightDown(_) => game.player.moveRight();
  void _onRightUp(_) => game.player.stopHorizontal();
  void _onJumpDown(_) => game.player.jump();
  void _onJumpUp(_) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          Positioned(
            left: 16,
            bottom: 32,
            child: Row(
              children: [
                _TouchButton(label: '◀', onPressed: null, onDown: _onLeftDown, onUp: _onLeftUp),
                const SizedBox(width: 8),
                _TouchButton(label: '▶', onPressed: null, onDown: _onRightDown, onUp: _onRightUp),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 32,
            child: _TouchButton(label: '▲', onPressed: null, onDown: _onJumpDown, onUp: _onJumpUp),
          ),
        ],
      ),
    );
  }
}

class _TouchButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final void Function(TapDownDetails)? onDown;
  final void Function(TapUpDetails)? onUp;

  const _TouchButton({
    required this.label,
    this.onPressed,
    this.onDown,
    this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onDown,
      onTapUp: onUp,
      onTapCancel: () {},
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
