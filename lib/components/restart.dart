import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';

import '../game/tunnel_game.dart';
import '../utilities/constants.dart';

class RestartGame extends PositionComponent
    with TapCallbacks, HasGameReference<TunnelGame> {
  final Sprite _sprite;

  RestartGame()
      : _sprite = Sprite(
          Flame.images.fromCache(restartFile),
          srcPosition: Vector2(226, 113),
          srcSize: Vector2(653, 611),
        ),
        super(position: Vector2(290, 80), size: Vector2.all(400));

  @override
  bool get debugMode => false;

  @override
  void render(Canvas canvas) {
    _sprite.render(canvas, size: size);

    super.render(canvas);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.restart();

    super.onTapUp(event);
  }
}
