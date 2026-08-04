import 'constants.dart';

enum TileType { empty, ground, brick, questionBlock, pipe, flag }

class Tile {
  final TileType type;
  final int x, y;

  const Tile(this.type, this.x, this.y);
}

class LevelData {
  static const int width = 200;
  static const int height = 15;

  static List<List<TileType>> get level1 {
    final map = List.generate(height, (_) => List.filled(width, TileType.empty));

    for (int i = 0; i < width; i++) {
      map[13][i] = TileType.ground;
      map[14][i] = TileType.ground;
    }

    for (int i = 20; i < 23; i++) {
      map[12][i] = TileType.brick;
    }

    map[12][24] = TileType.questionBlock;

    for (int i = 30; i < 33; i++) {
      map[12][i] = TileType.brick;
    }
    for (int i = 33; i < 36; i++) {
      map[12][i] = TileType.questionBlock;
    }

    for (int i = 40; i < 43; i++) {
      map[12][i] = TileType.brick;
    }
    map[11][42] = TileType.brick;
    map[10][42] = TileType.brick;

    for (int i = 50; i < 60; i++) {
      map[12][i] = TileType.brick;
    }

    for (int i = 65; i < 68; i++) {
      map[12][i] = TileType.questionBlock;
    }

    for (int i = 70; i < 80; i++) {
      map[12][i] = TileType.brick;
    }
    for (int i = 70; i < 72; i++) {
      map[11][i] = TileType.brick;
    }

    for (int i = 85; i < 88; i++) {
      map[12][i] = TileType.questionBlock;
    }

    for (int i = 90; i < 95; i++) {
      map[12][i] = TileType.brick;
    }
    for (int i = 90; i < 92; i++) {
      map[11][i] = TileType.questionBlock;
    }

    for (int i = 100; i < 110; i++) {
      for (int j = 9; j < 13; j++) {
        map[j][i] = TileType.brick;
      }
    }

    for (int i = 115; i < 118; i++) {
      map[12][i] = TileType.questionBlock;
    }

    for (int i = 120; i < 125; i++) {
      map[12][i] = TileType.brick;
    }
    for (int i = 120; i < 123; i++) {
      map[9][i] = TileType.brick;
    }

    for (int i = 130; i < 133; i++) {
      map[12][i] = TileType.questionBlock;
    }

    for (int i = 140; i < 150; i++) {
      map[12][i] = TileType.brick;
    }

    for (int i = 155; i < 158; i++) {
      map[12][i] = TileType.questionBlock;
    }

    for (int i = 165; i < 175; i++) {
      map[12][i] = TileType.ground;
      map[13][i] = TileType.empty;
    }
    map[13][175] = TileType.ground;
    map[14][175] = TileType.ground;
    for (int i = 176; i < width; i++) {
      map[13][i] = TileType.ground;
      map[14][i] = TileType.ground;
    }

    for (int i = 180; i < 186; i++) {
      map[11 - (i - 180)][i] = TileType.brick;
    }

    map[0][195] = TileType.flag;

    return map;
  }
}
