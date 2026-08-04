import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'level.dart';

enum PlayerState { idle, running, jumping, dead }

class Player extends SpriteComponent with CollisionCallbacks, HasGameRef {
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  PlayerState state = PlayerState.idle;
  bool facingRight = true;
  bool _invincible = false;
  double _invincibleTimer = 0;
  int lives = GameConstants.initialLives;

  Player()
      : super(
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      size: Vector2(GameConstants.playerWidth - 4, GameConstants.playerHeight - 2),
      position: Vector2(2, 1),
    )..collisionType = CollisionType.active);

    final canvas = await _generateSprite();
    sprite = Sprite(canvas);
  }

  Future<Canvas> _generateSprite() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final w = GameConstants.playerWidth;
    final h = GameConstants.playerHeight;

    final bodyPaint = Paint()..color = const Color(0xFFE4000F);
    final skinPaint = Paint()..color = const Color(0xFFFFC08A);
    final overallsPaint = Paint()..color = const Color(0xFF0038A8);
    final shoePaint = Paint()..color = const Color(0xFF5C2E00);
    final buttonPaint = Paint()..color = const Color(0xFFFFD700);

    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.05, w * 0.5, h * 0.15), bodyPaint);

    canvas.drawCircle(Offset(w * 0.5, h * 0.05), w * 0.13, skinPaint);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(w * 0.2, h * 0.15, w * 0.6, h * 0.35),
      ),
      overallsPaint,
    );

    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.5, w * 0.3, h * 0.2), overallsPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.55, h * 0.5, w * 0.3, h * 0.2), overallsPaint);

    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.7, w * 0.32, h * 0.25), shoePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.53, h * 0.7, w * 0.32, h * 0.25), shoePaint);

    canvas.drawCircle(Offset(w * 0.5, h * 0.28), w * 0.05, buttonPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.38), w * 0.05, buttonPaint);

    canvas.drawRect(Rect.fromLTWH(w * 0.35, h * 0.02, w * 0.06, h * 0.08), skinPaint);

    final capPaint = Paint()..color = const Color(0xFFE4000F);
    final capPath = Path()
      ..moveTo(w * 0.42, h * 0.02)
      ..lineTo(w * 0.68, h * 0.02)
      ..lineTo(w * 0.72, h * 0.08)
      ..lineTo(w * 0.38, h * 0.08)
      ..close();
    canvas.drawPath(capPath, capPaint);

    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(w * 0.58, h * 0.04), w * 0.03, eyePaint);

    return canvas;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == PlayerState.dead) return;

    if (_invincible) {
      _invincibleTimer -= dt;
      if (_invincibleTimer <= 0) _invincible = false;
    }

    velocity.y += GameConstants.gravity * dt;
    if (velocity.y > GameConstants.playerMaxFallSpeed) {
      velocity.y = GameConstants.playerMaxFallSpeed;
    }

    position += velocity * dt;

    if (velocity.x.abs() > 10 && isOnGround) {
      state = PlayerState.running;
    } else if (isOnGround && velocity.x.abs() < 10) {
      state = PlayerState.idle;
    } else if (!isOnGround) {
      state = PlayerState.jumping;
    }

    if (velocity.x > 0) facingRight = true;
    if (velocity.x < 0) facingRight = false;

    if (position.y > GameConstants.deathFallY) {
      die();
    }
  }

  void jump() {
    if (isOnGround && state != PlayerState.dead) {
      velocity.y = GameConstants.playerJumpForce;
      isOnGround = false;
      state = PlayerState.jumping;
    }
  }

  void moveLeft() {
    if (state == PlayerState.dead) return;
    velocity.x = -GameConstants.playerSpeed;
  }

  void moveRight() {
    if (state == PlayerState.dead) return;
    velocity.x = GameConstants.playerSpeed;
  }

  void stopHorizontal() {
    velocity.x = 0;
  }

  void die() {
    if (_invincible) return;
    state = PlayerState.dead;
    lives--;
    velocity = Vector2(0, -400);
  }

  void makeInvincible(double duration) {
    _invincible = true;
    _invincibleTimer = duration;
  }

  bool get isInvincible => _invincible;

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is TileComponent) {
      final overlap = _getOverlap(other);
      if (overlap.x > overlap.y) {
        if (position.y < other.position.y) {
          position.y = other.position.y - size.y / 2;
          velocity.y = 0;
          isOnGround = true;
        } else {
          position.y = other.position.y + other.size.y + size.y / 2;
          velocity.y = 0;
        }
      } else {
        if (position.x < other.position.x) {
          position.x = other.position.x - size.x / 2;
        } else {
          position.x = other.position.x + other.size.x + size.x / 2;
        }
        velocity.x = 0;
      }
    }
  }

  Vector2 _getOverlap(PositionComponent other) {
    final myLeft = position.x - size.x / 2;
    final myRight = position.x + size.x / 2;
    final myTop = position.y - size.y / 2;
    final myBottom = position.y + size.y / 2;

    final otherLeft = other.position.x - other.size.x / 2;
    final otherRight = other.position.x + other.size.x / 2;
    final otherTop = other.position.y - other.size.y / 2;
    final otherBottom = other.position.y + other.size.y / 2;

    final overlapX = (myRight > otherLeft && myLeft < otherRight)
        ? (myRight - otherLeft).abs().clamp(0, size.x)
        : 0.0;
    final overlapY = (myBottom > otherTop && myTop < otherBottom)
        ? (myBottom - otherTop).abs().clamp(0, size.y)
        : 0.0;

    return Vector2(overlapX, overlapY);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_invincible && (_invincibleTimer * 10).round() % 2 == 0) {
      return;
    }
  }
}
