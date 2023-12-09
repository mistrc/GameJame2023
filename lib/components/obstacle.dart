import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/widgets.dart';

import '../utilities/constants.dart';

class Obstacle extends PositionComponent with CollisionCallbacks {
  final Sprite _sprite;
  late double currentRadius = _radiusToEdge / 10;
  double currentScaleFactor = _initialScaleFactor;
  final double _radiusToEdge;
  static const double _maxScaleFactor = 0.3;
  static const _initialScaleFactor = 0.03;

  final Vector2 _initialCenterOfRotation;
  final Vector2 _finalCenterOfRotation;

  final double _lifetime;
  double ageOfObstacle = 0;

  final RectangleHitbox _hitBox =
      RectangleHitbox(collisionType: CollisionType.passive);

  Obstacle(
      {required Vector2 initialCenterOfRotation,
      required Vector2 finalCenterOfRotation,
      required double radiusToEdge,
      required double lifetime})
      : _initialCenterOfRotation = initialCenterOfRotation,
        _finalCenterOfRotation = finalCenterOfRotation,
        _lifetime = lifetime,
        _radiusToEdge = radiusToEdge,
        _sprite = Sprite(
          Flame.images.fromCache(spriteFileName),
          srcPosition: Vector2(973, 14),
          srcSize: Vector2(177, 182),
        ),
        super(position: initialCenterOfRotation, size: Vector2(40, 40));

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    add(_hitBox);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final scaledSpriteSize = _sprite.srcSize.scaled(currentScaleFactor);

    _sprite.render(canvas,
        position: Vector2(0, currentRadius),
        anchor: Anchor.bottomCenter,
        size: scaledSpriteSize);

    _hitBox
      ..position = Vector2(
          0 - scaledSpriteSize.x / 2, currentRadius - scaledSpriteSize.y)
      ..size = scaledSpriteSize;

    super.render(canvas);
  }

  bool get hasFallenOffEdge => ageOfObstacle > (_lifetime * 1.1);

  @override
  void update(double dt) {
    ageOfObstacle += dt;

    var percentageOfMovementDone = ageOfObstacle / _lifetime;

    currentRadius = lerpDouble(
        _radiusToEdge / 10, _radiusToEdge, percentageOfMovementDone)!;
    currentScaleFactor = lerpDouble(
        _initialScaleFactor, _maxScaleFactor, percentageOfMovementDone)!;

    if (!contains(_hitBox) &&
        0.28 < currentScaleFactor &&
        currentScaleFactor < 3.2) {
      _hitBox.collisionType = CollisionType.passive;
    } else if (contains(_hitBox) && currentScaleFactor >= 3.2) {
      _hitBox.collisionType = CollisionType.inactive;
    }

    position = Vector2(
        lerpDouble(_initialCenterOfRotation.x, _finalCenterOfRotation.x,
            percentageOfMovementDone)!,
        lerpDouble(_initialCenterOfRotation.y, _finalCenterOfRotation.y,
            percentageOfMovementDone)!);

    super.update(dt);
  }
}
