import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'tile.dart';

enum EnemyType { goomba, koopa }

class Enemy extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef {
  final EnemyType enemyType;
  Vector2 velocity = Vector2.zero();
  bool isAlive = true;
  bool squashed = false;
  double moveDirection = -1;
  double squashTimer = 0;
  static const double squashDuration = 0.3;

  Enemy({
    required this.enemyType,
    required Vector2 position,
  }) : super(position: position, size: Vector2(GameConstants.enemyWidth, GameConstants.enemyHeight), anchor: Anchor.bottomCenter);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    if (enemyType == EnemyType.goomba) {
      animation = SpriteAnimation.fromFrameData(
        gameRef.images.fromCache('goomba.png'),
        SpriteAnimationData.sequenced(amount: 2, stepTime: 0.15, textureSize: Vector2(16, 16)),
      );
    } else {
      animation = SpriteAnimation.fromFrameData(
        gameRef.images.fromCache('koopa.png'),
        SpriteAnimationData.sequenced(amount: 2, stepTime: 0.2, textureSize: Vector2(16, 24)),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) return;
    if (squashed) {
      squashTimer -= dt;
      if (squashTimer <= 0) removeFromParent();
      return;
    }
    velocity.y += GameConstants.enemyGravity * dt;
    if (velocity.y > GameConstants.playerMaxFallSpeed) velocity.y = GameConstants.playerMaxFallSpeed;
    velocity.x = moveDirection * GameConstants.enemySpeed;
    position.add(velocity * dt);
    if (position.y > GameConstants.deathFallY) removeFromParent();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) return;
    for (final point in intersectionPoints) {
      if (other is TileComponent && other.tile.isSolid) {
        final myCenter = absoluteCenter;
        final otherCenter = other.absoluteCenter;
        final overlapX = (size.x + other.size.x) / 2 - (myCenter.x - otherCenter.x).abs();
        final overlapY = (size.y + other.size.y) / 2 - (myCenter.y - otherCenter.y).abs();
        if (overlapX < overlapY) {
          if (myCenter.x < otherCenter.x) {
            position.x -= overlapX;
            moveDirection = 1;
          } else {
            position.x += overlapX;
            moveDirection = -1;
          }
          velocity.x = moveDirection * GameConstants.enemySpeed;
        } else {
          if (myCenter.y < otherCenter.y) {
            position.y -= overlapY;
            velocity.y = 0;
          }
        }
      }
    }
  }

  void squash() {
    squashed = true;
    squashTimer = squashDuration;
    size = Vector2(GameConstants.enemyWidth, GameConstants.enemyHeight * 0.3);
    velocity = Vector2.zero();
  }
}
