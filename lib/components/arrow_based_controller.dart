import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';

import 'character.dart';

class ArrowBasedController extends PositionComponent with TapCallbacks {
  final Sprite _sprite;
  final Character _character;
  final DirectionOfMovement _direction;

  ArrowBasedController(
      {required Character character,
      required Sprite sprite,
      required DirectionOfMovement direction,
      required super.position})
      : _sprite = sprite,
        _character = character,
        _direction = direction,
        super(size: sprite.srcSize.scaled(0.3));

  @override
  bool get debugMode => false;

  @override
  void render(Canvas canvas) {
    _sprite.render(canvas, size: _sprite.srcSize.scaled(0.3));

    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    _character.move(_direction);

    super.onTapDown(event);
  }
}
