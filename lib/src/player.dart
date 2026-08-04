import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'constants.dart';
import 'tile.dart';

class Player extends PositionComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool isBig = false;
  bool isInvincible = false;
  double _opacity = 1.0;
  double invincibleTimer = 0;
  static const double invincibleDuration = 2.0;

  Player()
      : super(
          size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
          anchor: Anchor.bottomCenter,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox(
      size: Vector2(GameConstants.playerWidth - 4, GameConstants.playerHeight - 2),
      position: Vector2(2, 1),
    )..collisionType = CollisionType.active);

    final picture = await _generatePicture();
    final image = await picture.toImage(
      GameConstants.playerWidth.toInt(),
      GameConstants.playerHeight.toInt(),
    );
    // SpriteComponent handles rendering via priority — Player renders in render()
  }

  Future<Picture> _generatePicture() async {
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
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.20, w * 0.7, h * 0.14), skinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.20, h * 0.34, w * 0.6, h * 0.14), skinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.15, h * 0.16), skinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.70, h * 0.15, w * 0.15, h * 0.16), skinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.28, h * 0.40), overallsPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.52, h * 0.48, w * 0.28, h * 0.40), overallsPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.26, h * 0.43, w * 0.12, h * 0.1), buttonPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.62, h * 0.43, w * 0.12, h * 0.1), buttonPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.15, h * 0.84, w * 0.28, h * 0.16), shoePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.57, h * 0.84, w * 0.28, h * 0.16), shoePaint);
    return recorder.endRecording();
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += GameConstants.gravity * dt;
    if (velocity.y > GameConstants.playerMaxFallSpeed) {
      velocity.y = GameConstants.playerMaxFallSpeed;
    }
    position += velocity * dt;

    if (isInvincible) {
      invincibleTimer -= dt;
      if (invincibleTimer <= 0) {
        isInvincible = false;
      }
      _opacity = (invincibleTimer * 4).toInt() % 2 == 0 ? 1.0 : 0.4;
    }

    if (position.y > GameConstants.deathFallY) {
      findGame()?.onPlayerDeath();
    }
  }

  void jump() {
    if (isOnGround) {
      velocity.y = GameConstants.playerJumpForce;
      isOnGround = false;
    }
  }

  void moveLeft() => velocity.x = -GameConstants.playerSpeed;
  void moveRight() => velocity.x = GameConstants.playerSpeed;
  void stopHorizontal() => velocity.x = 0;

  void powerUp() {
    if (!isBig) {
      isBig = true;
      size = Vector2(GameConstants.playerWidth, GameConstants.playerHeight * 1.6);
    }
  }

  void takeDamage() {
    if (isInvincible) return;
    if (isBig) {
      isBig = false;
      size = Vector2(GameConstants.playerWidth, GameConstants.playerHeight);
      isInvincible = true;
      invincibleTimer = invincibleDuration;
    } else {
      findGame()?.onPlayerDeath();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is TileComponent && other.tileType.isSolid) {
      for (final point in intersectionPoints) {
        final overlapX = (size.x + other.size.x) / 2 - (absoluteCenter.x - other.absoluteCenter.x).abs();
        final overlapY = (size.y + other.size.y) / 2 - (absoluteCenter.y - other.absoluteCenter.y).abs();
        if (overlapX < overlapY) {
          if (absoluteCenter.x < other.absoluteCenter.x) {
            position.x -= overlapX;
          } else {
            position.x += overlapX;
          }
        } else {
          if (absoluteCenter.y < other.absoluteCenter.y) {
            position.y -= overlapY;
            velocity.y = 0;
            isOnGround = true;
          } else {
            position.y += overlapY;
            velocity.y = 0;
          }
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.saveLayer(size.toRect(), Paint()..color = Color(0xFFFFFF).withOpacity(_opacity));
    final w = size.x;
    final h = size.y;
    
    final bodyPaint = Paint()..color = const Color(0xFFE4000F);
    final skinPaint = Paint()..color = const Color(0xFFFFC08A);
    final overallsPaint = Paint()..color = const Color(0xFF0038A8);
    final shoePaint = Paint()..color = const Color(0xFF5C2E00);
    final buttonPaint = Paint()..color = const Color(0xFFFFD700);

    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.05, w * 0.5, h * 0.15), bodyPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.05), w * 0.13, skinPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.3), overallsPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.55, w * 0.35, h * 0.2), shoePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.55, h * 0.55, w * 0.35, h * 0.2), shoePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.15, h * 0.1), bodyPaint);
    
    canvas.drawCircle(Offset(w * 0.15, h * 0.08), w * 0.06, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(Offset(w * 0.15, h * 0.08), w * 0.03, Paint()..color = const Color(0xFF000000));
    canvas.drawCircle(Offset(w * 0.42, h * 0.3), w * 0.04, buttonPaint);
    canvas.drawCircle(Offset(w * 0.58, h * 0.3), w * 0.04, buttonPaint);
    
    canvas.restore();
  }

  MarioWorld? findGame() {
    return parent as MarioWorld?;
  }
}
