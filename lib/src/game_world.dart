import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'player.dart';
import 'level.dart';

class MarioWorld extends FlameGame with HasCollisionDetection {
  late Player player;
  late GameLevel level;

  @override
  Future<void> onLoad() async {
    level = GameLevel();
    add(level);

    player = Player();
    player.position = Vector2(100, 300);
    add(player);

    camera.followComponent(player, worldBounds: Rect.fromLTWH(0, 0, 200 * 32, 15 * 32));
  }
}
