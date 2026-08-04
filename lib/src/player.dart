
import 'package:flame/components.dart';
import 'constants.dart';
import 'level_data.dart';
import 'level.dart';

class Player extends PositionComponent {
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;

  Player() : super(size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight));

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += GameConstants.gravity * dt;
    if (velocity.y > GameConstants.playerMaxFallSpeed) {
      velocity.y = GameConstants.playerMaxFallSpeed;
    }
    position += velocity * dt;
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
}
