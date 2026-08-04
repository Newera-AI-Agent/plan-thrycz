import 'package:flutter/foundation.dart';
import 'constants.dart';

class GameState extends ChangeNotifier {
  int score = 0;
  int lives = GameConstants.initialLives;
  int coins = 0;
  bool isGameOver = false;
  bool isLevelComplete = false;

  void addScore(int points) {
    score += points;
    notifyListeners();
  }

  void addCoin() {
    coins++;
    addScore(GameConstants.coinScore);
    if (coins % GameConstants.coinsPerLife == 0) {
      lives++;
    }
    notifyListeners();
  }

  void loseLife() {
    lives--;
    if (lives <= 0) {
      isGameOver = true;
    }
    notifyListeners();
  }

  void completeLevel() {
    isLevelComplete = true;
    addScore(GameConstants.flagpoleScore);
    notifyListeners();
  }

  void reset() {
    score = 0;
    lives = GameConstants.initialLives;
    coins = 0;
    isGameOver = false;
    isLevelComplete = false;
    notifyListeners();
  }
}
