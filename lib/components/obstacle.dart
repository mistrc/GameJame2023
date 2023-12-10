import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/widgets.dart';

import '../utilities/constants.dart';

class Obstacle extends PositionComponent with CollisionCallbacks {
  static const double _scaleFactor = 0.3;

  final Sprite _sprite;
  late double currentRadius = _radiusSteps.first;
  late double currentScaleFactor =
      _scaleFactor * _radiusSteps.first / _radiusSteps.last;
  final List<double> _radiusSteps;

  final Vector2 _initialCenterOfRotation;
  final Vector2 _finalCenterOfRotation;

  final double _lifetime;
  double ageOfObstacle = 0;

  final RectangleHitbox _hitBox =
      RectangleHitbox(collisionType: CollisionType.inactive);

  Obstacle(
      {required Vector2 initialCenterOfRotation,
      required Vector2 finalCenterOfRotation,
      required List<double> radiusSteps,
      required double lifetime})
      : _initialCenterOfRotation = initialCenterOfRotation,
        _finalCenterOfRotation = finalCenterOfRotation,
        _lifetime = lifetime,
        _radiusSteps = radiusSteps,
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

  bool get hasFallenOffEdge => currentRadius > (_radiusSteps.last * 1.1);

  /// This moduloValue is ued to ensure that the currentRadius and also
  /// currentScaleFactor continue to increase past the values of the current
  /// ring.
  /// Firstly we need the movement and the expansion to be approx. in time with
  /// the rings getting bigger, so needs to get faster as we get closer
  /// Hence using this to take away the right amount to ensure that
  /// percentageCompleteForRing is set correctly for each ring
  int moduloValue = 0;

  @override
  void update(double dt) {
    ageOfObstacle += dt;

    final percentageOfMovementDone = ageOfObstacle / _lifetime;

    final (minRadius, maxRadius) = getLimitsOfRadius();

    final percentageCompleteForRing =
        (percentageOfMovementDone * (_radiusSteps.length - 1)) - moduloValue;

    currentRadius =
        lerpDouble(minRadius, maxRadius, percentageCompleteForRing)!;

    currentScaleFactor = lerpDouble(
        _scaleFactor * minRadius / _radiusSteps.last,
        _scaleFactor * maxRadius / _radiusSteps.last,
        percentageCompleteForRing)!;

    moduloValue += (currentRadius > maxRadius) ? 1 : 0;

    if (0.28 < currentScaleFactor && currentScaleFactor < 0.32) {
      _hitBox.collisionType = CollisionType.passive;
    } else if (currentScaleFactor >= 0.32) {
      _hitBox.collisionType = CollisionType.inactive;
    }

    position = Vector2(
        lerpDouble(_initialCenterOfRotation.x, _finalCenterOfRotation.x,
            percentageOfMovementDone)!,
        lerpDouble(_initialCenterOfRotation.y, _finalCenterOfRotation.y,
            percentageOfMovementDone)!);

    super.update(dt);
  }

  (double, double) getLimitsOfRadius() {
    double minRadius = 0;
    double maxRadius = 0;
    for (var radius in _radiusSteps) {
      if (minRadius == maxRadius) {
        maxRadius = radius;
      }
      if (currentRadius >= radius) {
        minRadius = radius;
      }
    }

    if (maxRadius == minRadius) {
      maxRadius *= scaleFactorBetweenRings;
    }

    return (minRadius, maxRadius);
  }
}
