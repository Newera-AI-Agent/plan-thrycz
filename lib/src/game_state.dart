import 'package:flame/components.dart';
import 'constants.dart';

enum GameStatus { running, paused, dead, levelComplete, gameOver }

class GameState {
  GameStatus status = GameStatus.running;
  int lives = GameConstants.initialLives;
  int coins = 0;
  int score = 0;
  double timeRemaining = 400.0;
  bool isInvincible = false;
  double invincibilityTimer = 0.0;

  void addCoin() {
    coins++;
    score += GameConstants.coinScore;
    if (coins >= GameConstants.coinsPerLife) {
      coins = 0;
      lives++;
    }
  }

  void addScore(int points) {
    score += points;
  }

  void die() {
    lives--;
    if (lives <= 0) {
      status = GameStatus.gameOver;
    } else {
      status = GameStatus.dead;
    }
  }

  void respawn() {
    status = GameStatus.running;
    isInvincible = true;
    invincibilityTimer = 2.0;
  }

  void levelComplete() {
    score += GameConstants.flagpoleScore;
    status = GameStatus.levelComplete;
  }

  void togglePause() {
    if (status == GameStatus.running) {
      status = GameStatus.paused;
    } else if (status == GameStatus.paused) {
      status = GameStatus.running;
    }
  }

  void update(double dt) {
    if (status != GameStatus.running) return;
    timeRemaining -= dt;
    if (timeRemaining <= 0) {
      timeRemaining = 0;
      die();
    }
    if (isInvincible) {
      invincibilityTimer -= dt;
      if (invincibilityTimer <= 0) {
        isInvincible = false;
      }
    }
  }

  void reset() {
    status = GameStatus.running;
    lives = GameConstants.initialLives;
    coins = 0;
    score = 0;
    timeRemaining = 400.0;
    isInvincible = false;
    invincibilityTimer = 0.0;
  }
}
