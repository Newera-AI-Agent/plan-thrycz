import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'tile.dart';
import 'level_data.dart';
import 'constants.dart';

class LevelComponent extends Component with HasGameRef {
  final LevelData _levelData = LevelData();
  final List<List<TileType>> _map = LevelData.level1;
  final List<TileComponent> _tiles = [];

  List<TileComponent> get tiles => _tiles;
  TileType getTileAt(int col, int row) {
    if (col < 0 || col >= GameConstants.worldColumns || row < 0 || row >= GameConstants.worldRows) {
      return TileType.empty;
    }
    return _map[row][col];
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildTileMap();
  }

  void _buildTileMap() {
    for (int row = 0; row < GameConstants.worldRows; row++) {
      for (int col = 0; col < GameConstants.worldColumns; col++) {
        final type = _map[row][col];
        if (type == TileType.empty) continue;
        final tile = TileComponent(
          type: type,
          position: Vector2(
            col * GameConstants.tileSize,
            row * GameConstants.tileSize,
          ),
          size: Vector2.all(GameConstants.tileSize),
        );
        tile.add(RectangleHitbox()..collisionType = CollisionType.passive);
        add(tile);
        _tiles.add(tile);
      }
    }
  }
}
