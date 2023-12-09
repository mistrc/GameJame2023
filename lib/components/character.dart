import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/widgets.dart';

import '../utilities/constants.dart';

enum DirectionOfMovement { left, right }

class Character extends PositionComponent {
  final Sprite _person;
  final double _radiusToEdge;
  static const _bufferFromEdge = 10.0;

  /// A measure of how fast the character is moving round the tunnel
  double _angularMomentum = 0;

  /// Multiplier to apply to how much gravity caused the character to go back to the bottom of the tunnel
  static const _gravitationalConstant = 0.1;

  Character({required Vector2 centerOfRotation, required double radiusToEdge})
      : _radiusToEdge = radiusToEdge,
        _person = Sprite(
          Flame.images.fromCache(spriteFileName),
          srcPosition: Vector2(1176, 17),
          srcSize: Vector2(172, 183),
        ),
        super(position: centerOfRotation, size: Vector2(40, 40));

  @override
  bool get debugMode => true;

  @override
  void render(Canvas canvas) {
    _person.render(canvas,
        position: Vector2(0, _radiusToEdge - _bufferFromEdge),
        anchor: Anchor.bottomCenter,
        size: _person.srcSize.scaled(0.3));

    super.render(canvas);
  }

  void move(DirectionOfMovement movement) {
    switch (movement) {
      case DirectionOfMovement.left:
        _angularMomentum += pi / 16;
        break;

      case DirectionOfMovement.right:
        _angularMomentum -= pi / 16;
        break;
    }
  }

  @override
  void update(double dt) {
    final angleInTunnel = angle % (2 * pi);
    _angularMomentum -= _gravitationalConstant * sin(angleInTunnel);

    /// Don't want the character osculating forever, so applying some damping
    _angularMomentum *= 0.995;

    angle += _angularMomentum * dt;
    super.update(dt);
  }
}
