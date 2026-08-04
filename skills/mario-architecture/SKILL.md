---
name: flutter-mario-clone
description: Architecture and implementation plan for a 1:1 Mario-style side-scrolling platformer clone in Flutter using the Flame game engine, supporting phone (touch) and desktop (keyboard) with scoring, lives, and game states.
---

# SKILL.md

## When to use
When building a complete 2D side-scrolling platformer in Flutter that requires game-loop physics, sprite rendering, collision detection, input handling for both touch and keyboard, audio, and state management — all deliverable as a single-file `lib/main.dart` if needed, but structured for maintainability.

## Rules (hard constraints)

1. **Use Flame, not raw CustomPainter.** Flame provides the game loop, component system, collision detection, sprite loading, and input handling that would take weeks to rebuild. Never fall back to `CustomPainter` for core game rendering.
2. **Separate game logic from Flutter UI.** Game state (score, lives, level progress) must live in a plain Dart class outside the Flame widget. The Flutter widget tree reads from it via `ValueNotifier` or `StreamBuilder`. Flame components write to it. Never put level data in `StatefulWidget.state`.
3. **All game entities extend `PositionComponent` or `SpriteComponent`.** Player, enemies, coins, pipes, flag pole, and platforms are all Flame components with their own `update` and `onCollision` methods. No procedural drawing loops in `render`.
4. **Use Flame’s `HasCollisionDetection` mixin and hitboxes.** Every entity gets a `RectangleHitbox` sized to the visible sprite area, not the full asset dimensions. Collision callbacks (`onCollisionStart`) must return `void`, not `bool`, and must modify component state directly.
5. **Platforms are `PositionComponent` with `RectangleHitbox` and `CollisionType.passive`.** Player and enemies move into platforms but do not push them. The player’s vertical velocity zeroes on top collision; the enemy’s horizontal velocity flips on side collision.
6. **Input must be abstracted into an `InputController` mixin or component.** One implementation reads `KeyboardEvent`; another reads a `JoystickComponent` + button overlays. The player component queries `inputController.horizontal` and `inputController.jumpPressed` each frame — never a raw `RawKeyDownEvent` handler or `GestureDetector` inside `update`.
7. **All assets must be loaded via `await Flame.images.load()` before `runApp`.** Sprite sizes must be queried from the loaded `Image` objects to set hitbox dimensions. No hardcoded pixel sizes.
8. **Audio uses `flame_audio`.** Only one sound channel per category (sfx, music). `playSfx` for coin/jump/stomp/kill sounds; `bgm` for background music. Never use `audioplayers` directly — `flame_audio` wraps it and handles lifecycle.

## Steps

### Phase 1: Project scaffold and asset loading
1. Add `flame`, `flame_audio` packages to `pubspec.yaml`. No other game dependencies.
2. Create `lib/main.dart` with a `main()` that calls `Flame.device.fullScreen()` and `Flame.device.setOrientation(DeviceOrientation.portraitUp)`, then runs the Flutter app.
3. Create `assets/images/` and `assets/audio/` directories. Place placeholder sprite sheets (player, goomba, coin, platform tile, pipe, flag, background) and audio files.
4. Create a `GameAssets` class with a static `Future<void> load()` that calls `Flame.images.load()` for every asset. Call it in `main()` before `runApp`.
5. Build the `GameWidget.controlled` with a `MarioGame` class extending `FlameGame` with `HasCollisionDetection`. Verify a black screen renders with no crashes.

**Verification:** `flutter run -d chrome` shows a black fullscreen canvas. Console has no asset-load errors. Flame engine is in its game loop (confirm by logging `dt` in `MarioGame.update`).

### Phase 2: Player component with input abstraction
1. Create `InputController` class storing `double horizontal` (-1.0 to 1.0) and `bool jumpPressed`. Add methods `onKeyDown(LogicalKeyboardKey)` / `onKeyUp(LogicalKeyboardKey)` for Arrow/WASD/Space.
2. Create `Player` extending `SpriteComponent` with `RectangleHitbox`. Add `velocity: Vector2`, `isOnGround: bool`, `lives: int`.
3. In `Player.update(dt)`: apply gravity (constant `+y` acceleration), apply `horizontal * moveSpeed` to `velocity.x`, clamp `velocity.x` magnitude, if `jumpPressed && isOnGround` set `velocity.y = -jumpForce`. Update position by `velocity * dt`.
4. Create `DesktopInputController` that attaches keyboard listeners to `MarioGame` via `KeyboardHandler` mixin. Wire `onKeyEvent` to `inputController.onKeyDown/Up`.
5. Create `PhoneInputController` widget with a `JoystickComponent` and two transparent `Tapable` buttons (jump, run). Float it over the `GameWidget` using a `Stack`. The widget writes to the same `InputController` instance.

**Verification:** On desktop, arrow keys move player left/right, space jumps. On phone, joystick moves player, jump button jumps. Player falls with gravity, lands on screen bottom. No platforms yet — player falls off-screen.

### Phase 3: Platform and level structure
1. Create `Platform` extending `PositionComponent` with `RectangleHitbox`. Add `CollisionType.passive` in the mixin.
2. Create `LevelLoader` class that parses a 2D string array into positions. `X` = platform block, `?` = coin, `G` = goomba, `P` = pipe, `F` = flag. Each character maps to a grid coordinate `(col * tileSize, row * tileSize)`.
3. Instantiate `Platform` components for every `X` in the level array. Add them to the game world. Set their positions based on grid.
4. Add `Player.onCollisionStart(PositionComponent other)` that checks if `other is Platform`. If player’s bottom edge hits platform top edge, set `isOnGround = true` and `velocity.y = 0`. If side collision, set horizontal velocity to 0.

**Verification:** A simple level with a ground row and floating platforms. Player can jump onto platforms, walk on them, and fall off edges. Player no longer falls through the world.

### Phase 4: Camera and scrolling
1. Add `CameraComponent` to `MarioGame` with `world` set. Attach a `FixedResolutionViewport` (e.g., 640x360). Set camera to follow player by overriding `update` to call `camera.moveTo(Vector2(player.x, worldHeight / 2))`.
2. Clamp camera horizontal position so it never shows beyond the level bounds. Do not clamp vertical if level has height variation.
3. Add parallax background layers: distant mountains and near bushes. Move them at `camera.position * 0.2` and `camera.position * 0.5` respectively.

**Verification:** Player moves right, camera follows smoothly, left edge cannot scroll past x=0. Background shifts with parallax. On phone, the visible area is always centered on the player’s x.

### Phase 5: Enemies (Goombas)
1. Create `Goomba` extending `SpriteComponent` with `RectangleHitbox`. Add `horizontalDirection` (initialized to -1) and `speed`. In `update`, move horizontally; if a platform side collision is detected, flip direction.
2. Add `Goomba` instances at `G` positions from the level array.
3. In `Player.onCollisionStart`: if colliding with `Goomba` and player’s bottom edge hits goomba’s top edge (player is falling), remove the goomba, play stomp sound, add score. Else, player takes damage (lose life, brief invincibility, push back).

**Verification:** Goombas walk back and forth on platforms. Player jumping on top destroys them; player walking into them loses a life. Goombas fall off ledges (no pathfinding — they just fall).

### Phase 6: Collectibles, scoring, and UI overlay
1. Create `Coin` extending `SpriteComponent` with `CircleHitbox`. On collision with player, remove coin, play coin sound, increment score.
2. Create `GameState` class (not a Widget) with `ValueNotifier<int>` for score, lives, coins, and `ValueNotifier<GameStatus>` (playing, died, levelComplete, gameOver).
3. Create `GameOverlay` Flutter widget that listens to `GameState` notifiers using `AnimatedBuilder`. Show score, lives as heart icons, coin count. Position with `Positioned` in a `Stack` over the `GameWidget`.
4. The overlay also shows touch controls when `MediaQuery` detects a phone (no physical keyboard). Use `Platform.isAndroid || Platform.isIOS` or `kIsWeb && mobile user-agent`.

**Verification:** Collecting coins updates the coin counter in real-time. Lives display updates on death. Touch controls appear only on mobile devices.

### Phase 7: Pipes, flag pole, and level completion
1. Create `Pipe` component: a tall static `PositionComponent` with two segments (top and body sprites). `RectangleHitbox` covering the full pipe. Collision type passive. Player cannot pass through.
2. Create `FlagPole` component at the end of the level. On player collision, set `GameState.gameStatus = levelComplete`, play victory fanfare, show "LEVEL COMPLETE" overlay for 3 seconds, then transition to next level or restart.
3. Implement pipe entry: if player presses down while standing on a specific pipe top, play pipe sound, hide player for 2 seconds, teleport to bonus room or another pipe in the same level.

**Verification:** Player walks into pipe and stops. Player touches flag pole and sees level complete screen. After delay, game resets or advances.

### Phase 8: Game over, lives, and restart
1. On player death (enemy collision, falling into pit): decrement lives. If lives > 0, respawn player at start or checkpoint after 1-second delay. If lives == 0, set `gameStatus = gameOver`, show "GAME OVER" overlay, offer restart button.
2. Falling into a pit: if player y exceeds a death threshold (below lowest platform), trigger death immediately.
3. `GameOverlay` shows a semi-transparent centered dialog with score and "Tap to restart" when game over.
4. Restart resets `MarioGame` by calling `removeAll(world.children)`, re-running `LevelLoader`, resetting `GameState`.

**Verification:** Player dies 3 times, game over screen appears, tap/click restarts from level 1-1 with zero score. Falling into a pit kills the player without needing enemy collision.

### Phase 9: Polish — animations, particles, audio
1. Add sprite sheet animations: player walk cycle (swap sprites every 0.1s based on `horizontal != 0`), player jump sprite, goomba squish frame on death, coin spin (4 frames).
2. Add `ParticleSystemComponent` for coin collection sparkle, goomba death poof, player death.
3. Wire `flame_audio`: background music loops; sfx for jump, coin, stomp, pipe, flagpole, death, game over. Use shared `AudioPool` instances for coins and stomps that repeat rapidly.
4. Add screen shake on player death using `camera.shake(duration: 0.3)`.

**Verification:** Walk cycle plays when moving, jump sprite shows when airborne. Coin sparkles on collect. Music plays on level start, stops on game over. Rapid coin collection doesn't cut off audio.

## Definition of done
- A side-scrolling platformer runs on Chrome, Android emulator, and Windows/macOS desktop.
- Keyboard (arrows/WASD + space) controls player on desktop. On-screen joystick + two buttons control player on phone — both work simultaneously with no code branch.
- Player walks, jumps, lands on platforms, collects coins, stomps goombas, loses lives on enemy contact, dies falling into pits, touches flag pole to win.
- Score, lives, and coins display in a real-time overlay. Game over and level complete screens show and allow restart.
- Parallax background scrolls. Sound effects play for all interactions. Background music loops.
- The entire game runs from a single `lib/main.dart` (with/organized classes) or a well-structured `lib/` directory with component files — no monolithic unstructured file.
- Flame engine is the sole game framework; no `CustomPainter` game loops. All entities are Flame components with hitboxes.
- Level layout is data-driven from a string array; adding a new level is adding one array.