import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'game_state.dart';

class HudComponent extends Component with HasGameRef {
  final GameState state;

  HudComponent(this.state);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final cameraPos = gameRef.camera.viewport.position;
    final tp = TextPainter(
      text: TextSpan(
        text: 'MARIO\n\nSCORE: ${state.score}\nCOINS: ${state.coins}\nLIVES: ${state.lives}',
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
    tp.paint(canvas, Offset(cameraPos.x + 16, 16));
  }
}
