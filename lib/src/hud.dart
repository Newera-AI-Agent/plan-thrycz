import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_state.dart';

class HudComponent extends Component with HasGameRef {
  final GameState state;

  HudComponent(this.state);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final tp = TextPainter(
      text: TextSpan(
        text: 'MARIO\n\nSCORE: ${state.score}\nCOINS: ${state.coins}\nLIVES: ${state.lives}\nWORLD: ${state.world}-${state.level}',
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(gameRef.camera.position.x + 16, 16));
  }
}
