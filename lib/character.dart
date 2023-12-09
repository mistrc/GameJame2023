import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'utils/consts.dart';

class Character extends PositionComponent {
  final Sprite person;
  final Vector2 centerOfRotation;
  final double radiusToEdge;
  static const bufferFromEdge = 10.0;

  double angleOfRotation = 0;

  Character({required this.centerOfRotation, required this.radiusToEdge})
      : person = Sprite(
          Flame.images.fromCache(spriteFileName),
          srcPosition: Vector2(1176, 17),
          srcSize: Vector2(172, 183),
        ),
        super(position: centerOfRotation, size: Vector2(40, 40));

  @override
  bool get debugMode => true;

  @override
  void render(Canvas canvas) {
    canvas.save(); // think this will prevent the whole tunnel from rotating
    canvas.rotate(angleOfRotation);

    person.render(canvas,
        position: Vector2(0, radiusToEdge - bufferFromEdge),
        anchor: Anchor.bottomCenter,
        size: person.srcSize.scaled(0.3));

    super.render(canvas);
  }
}
