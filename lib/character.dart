import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/widgets.dart';

import 'utilities/constants.dart';

enum DirectionOfMovement { left, right }

class Character extends PositionComponent {
  final Sprite person;
  final Vector2 centerOfRotation;
  final double radiusToEdge;
  static const bufferFromEdge = 10.0;

  /// A measure of how fast the character is moving round the tunnel
  double angularMomentum = 0;

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
    person.render(canvas,
        position: Vector2(0, radiusToEdge - bufferFromEdge),
        anchor: Anchor.bottomCenter,
        size: person.srcSize.scaled(0.3));

    super.render(canvas);
  }

  void move(DirectionOfMovement movement) {
    switch (movement) {
      case DirectionOfMovement.left:
        angularMomentum += pi / 16;
        break;

      case DirectionOfMovement.right:
        angularMomentum -= pi / 16;
        break;
    }
  }

  static const gravitationalConstant = 0.1;

  @override
  void update(double dt) {
    final angleInTunnel = angle % (2 * pi);
    angularMomentum -= gravitationalConstant * sin(angleInTunnel);

    /// Don't want the character osculating forever, so applying some damping
    angularMomentum *= 0.995;

    angle += angularMomentum * dt;
    super.update(dt);
  }
}
