import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'player.dart';
import 'level.dart';
import 'enemy.dart';
import 'constants.dart';
import 'level_data.dart';
import 'game_state.dart';
import 'hud.dart';

class MarioWorld extends FlameGame with HasCollisionDetection {
  late Player player;
  late LevelComponent levelComponent;
  late GameState gameState;
  late Hud hud;
  final List<Enemy> enemies = [];
  bool _paused = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gameState = GameState();

    levelComponent = LevelComponent();
    add(levelComponent);

    _spawnEnemies();

    player = Player();
    player.position = Vector2(100, 300);
    add(player);

    hud = Hud(gameState: gameState);
    add(hud);

    camera.followComponent(
      player,
      worldBounds: Rect.fromLTWH(
        0,
        0,
        GameConstants.worldColumns * GameConstants.tileSize,
        GameConstants.worldRows * GameConstants.tileSize,
      ),
    );
  }

  void _spawnEnemies() {
    for (int row = 0; row < GameConstants.worldRows; row++) {
      for (int col = 0; col < GameConstants.worldColumns; col++) {
        final tile = levelComponent.getTileAt(col, row);
        if (tile == TileType.enemy) {
          final enemy = Enemy(
            position: Vector2(
              col * GameConstants.tileSize,
              row * GameConstants.tileSize,
            ),
          );
          add(enemy);
          enemies.add(enemy);
        }
      }
    }
  }

  @override
  void update(double dt) {
    if (_paused) return;
    super.update(dt);

    _checkCollisions();
    _checkPlayerDeath();
    _checkFlagpole();

    hud.update();
  }

  void _checkCollisions() {
    for (final tile in levelComponent.tiles) {
      if (player.toRect().overlaps(tile.toRect())) {
        _resolveTileCollision(tile);
      }
    }

    for (final enemy in enemies) {
      if (enemy.isAlive && player.toRect().overlaps(enemy.toRect())) {
        if (player.velocity.y > 0 && player.position.y + player.height - 10 < enemy.position.y + 10) {
          enemy.squash();
          player.velocity.y = GameConstants.playerJumpForce * 0.5;
          gameState.addScore(GameConstants.enemyStompScore);
        } else {
          playerDie();
        }
      }
    }
  }

  void _resolveTileCollision(TileComponent tile) {
    final pRect = player.toRect();
    final tRect = tile.toRect();

    final overlapLeft = pRect.right - tRect.left;
    final overlapRight = tRect.right - pRect.left;
    final overlapTop = pRect.bottom - tRect.top;
    final overlapBottom = tRect.bottom - pRect.top;

    final minOverlapX = overlapLeft < overlapRight ? overlapLeft : overlapRight;
    final minOverlapY = overlapTop < overlapBottom ? overlapTop : overlapBottom;

    if (minOverlapX < minOverlapY) {
      if (overlapLeft < overlapRight) {
        player.position.x = tRect.left - player.width;
        player.velocity.x = 0;
      } else {
        player.position.x = tRect.right;
        player.velocity.x = 0;
      }
    } else {
      if (overlapTop < overlapBottom) {
        player.position.y = tRect.top - player.height;
        player.velocity.y = 0;
        player.isOnGround = true;

        if (tile.tileType == TileType.questionBlock) {
          tile.hit();
          gameState.addScore(GameConstants.coinScore);
          gameState.addCoin();
        }
      } else {
        player.position.y = tRect.bottom;
        player.velocity.y = 0;

        if (tile.tileType == TileType.brick && player.isBig) {
          levelComponent.breakTile(tile);
          gameState.addScore(GameConstants.brickBreakScore);
        }
      }
    }
  }

  void _checkPlayerDeath() {
    if (player.position.y > GameConstants.deathFallY) {
      playerDie();
    }
  }

  void _checkFlagpole() {
    for (final tile in levelComponent.tiles) {
      if (tile.tileType == TileType.flagpole && player.toRect().overlaps(tile.toRect())) {
        gameState.addScore(GameConstants.flagpoleScore);
        _paused = true;
        hud.showWin();
      }
    }
  }

  void playerDie() {
    gameState.loseLife();
    if (gameState.lives <= 0) {
      _paused = true;
      hud.showGameOver();
    } else {
      player.position = Vector2(100, 100);
      player.velocity = Vector2.zero();
    }
  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (_paused) return KeyEventResult.handled;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      player.moveLeft();
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      player.moveRight();
    } else {
      player.stopHorizontal();
    }

    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW) {
        player.jump();
      }
    }

    return KeyEventResult.handled;
  }

  void onJumpPressed() {
    if (!_paused) player.jump();
  }

  void onLeftPressed() {
    if (!_paused) player.moveLeft();
  }

  void onRightPressed() {
    if (!_paused) player.moveRight();
  }

  void onHorizontalReleased() {
    if (!_paused) player.stopHorizontal();
  }
}
