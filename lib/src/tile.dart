import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'level_data.dart';

class TileComponent extends PositionComponent {
  final TileType tileType;
  final int gridX;
  final int gridY;

  TileComponent({
    required this.tileType,
    required this.gridX,
    required this.gridY,
  }) : super(
          position: Vector2(
            gridX * GameConstants.tileSize,
            gridY * GameConstants.tileSize,
          ),
          size: Vector2.all(GameConstants.tileSize),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint();
    final rect = size.toRect();

    switch (tileType) {
      case TileType.ground:
        paint.color = const Color(0xFF8B4513);
        canvas.drawRect(rect, paint);
        paint.color = const Color(0xFF228B22);
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.x, 4),
          paint,
        );
        break;
      case TileType.brick:
        paint.color = const Color(0xFFCD853F);
        canvas.drawRect(rect, paint);
        paint.color = const Color(0xFF8B4513);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        canvas.drawLine(const Offset(0, 0), Offset(size.x, 0), paint);
        canvas.drawLine(const Offset(0, 0), const Offset(0, size.y), paint);
        canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), paint);
        canvas.drawLine(Offset(size.x, 0), Offset(size.x, size.y), paint);
        canvas.drawLine(const Offset(0, size.y / 2), Offset(size.x, size.y / 2), paint);
        canvas.drawLine(Offset(size.x / 2, 0), Offset(size.x / 2, size.y), paint);
        paint.style = PaintingStyle.fill;
        break;
      case TileType.questionBlock:
        paint.color = const Color(0xFFFFA500);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          paint,
        );
        paint.color = Colors.white;
        final textPainter = TextPainter(
          text: const TextSpan(
            text: '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            (size.x - textPainter.width) / 2,
            (size.y - textPainter.height) / 2,
          ),
        );
        break;
      case TileType.pipe:
        paint.color = const Color(0xFF2E8B57);
        canvas.drawRect(rect, paint);
        paint.color = const Color(0xFF228B22);
        canvas.drawRect(Rect.fromLTWH(0, 0, 6, size.y), paint);
        canvas.drawRect(Rect.fromLTWH(size.x - 6, 0, 6, size.y), paint);
        paint.color = const Color(0xFF1A5C34);
        canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 6), paint);
        break;
      case TileType.flag:
        paint.color = const Color(0xFF808080);
        canvas.drawRect(Rect.fromLTWH(14, 0, 4, size.y), paint);
        paint.color = const Color(0xFF00FF00);
        final path = Path()
          ..moveTo(18, 4)
          ..lineTo(30, 10)
          ..lineTo(18, 16)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case TileType.empty:
        break;
    }
  }
}
