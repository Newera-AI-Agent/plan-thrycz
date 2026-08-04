import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

enum ItemType { coin, mushroom }

class Item extends PositionComponent {
  final ItemType itemType;
  double _bounceOffset = 0;
  double _bounceDirection = 1;
  bool collected = false;

  Item({
    required this.itemType,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(
            itemType == ItemType.coin
                ? GameConstants.coinSize
                : GameConstants.mushroomSize,
          ),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (itemType == ItemType.coin) {
      _startBounce();
    }
  }

  void _startBounce() {
    final originalY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (collected) return;
    if (itemType == ItemType.coin) {
      _bounceOffset += GameConstants.coinBounceSpeed * dt * _bounceDirection;
      if (_bounceOffset.abs() >= GameConstants.coinBounceHeight) {
        _bounceDirection *= -1;
      }
      position.y += _bounceOffset;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (collected) return;
    final paint = Paint();
    final rect = size.toRect();

    if (itemType == ItemType.coin) {
      paint.color = const Color(0xFFFFD700);
      canvas.drawCircle(rect.center, size.x / 2, paint);
      paint.color = const Color(0xFFFFA500);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawCircle(rect.center, size.x / 2, paint);
    } else {
      paint.color = const Color(0xFFFF0000);
      canvas.drawOval(rect, paint);
      paint.color = Colors.white;
      canvas.drawOval(
        Rect.fromLTWH(size.x * 0.2, size.y * 0.2, size.x * 0.25, size.y * 0.25),
        paint,
      );
      canvas.drawOval(
        Rect.fromLTWH(size.x * 0.55, size.y * 0.2, size.x * 0.25, size.y * 0.25),
        paint,
      );
    }
  }
}
