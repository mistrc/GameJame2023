import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../utilities/constants.dart';

enum PowerUpType { fire, ice }

class PowerUp extends SpriteAnimationComponent with CollisionCallbacks {
  final RectangleHitbox _hitBox =
      RectangleHitbox(collisionType: CollisionType.inactive);
  static const frameInterval = 0.07;

  PowerUp({
    required Vector2 initialCenterOfRotation,
    required Vector2 finalCenterOfRotation,
    required List<double> radiusSteps,
    required double lifetime,
  })  : _initialCenterOfRotation = initialCenterOfRotation,
        _finalCenterOfRotation = finalCenterOfRotation,
        _radiusSteps = radiusSteps,
        _lifetime = lifetime,
        type = Random().nextBool() ? PowerUpType.fire : PowerUpType.ice;

  final PowerUpType type;

  final double _lifetime;
  double ageOfObstacle = 0;

  final Vector2 _initialCenterOfRotation;
  final Vector2 _finalCenterOfRotation;
  final List<double> _radiusSteps;
  late double currentRadius = _radiusSteps.first;
  static const _dimensions = 40.0;

  @override
  FutureOr<void> onLoad() {
    animation = getSpriteAnimation();

    add(_hitBox);
    // _hitBox.debugMode = true;

    return super.onLoad();
  }

  @override
  bool get debugMode => false;

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

    moduloValue += (currentRadius > maxRadius) ? 1 : 0;

    final centreOfCircle = Vector2(
        lerpDouble(_initialCenterOfRotation.x, _finalCenterOfRotation.x,
            percentageOfMovementDone)!,
        lerpDouble(_initialCenterOfRotation.y, _finalCenterOfRotation.y,
            percentageOfMovementDone)!);

    final deltaX = currentRadius * sin(angle);
    final deltaY = currentRadius * cos(angle);

    position = Vector2(centreOfCircle.x - deltaX, centreOfCircle.y + deltaY);

    final sizeDimension = lerpDouble(
        _dimensions * minRadius / _radiusSteps.last,
        _dimensions * maxRadius / _radiusSteps.last,
        percentageCompleteForRing)!;

    size = Vector2.all(sizeDimension);

    if ((0.9 * _dimensions) < sizeDimension &&
        sizeDimension < (1.1 * _dimensions)) {
      _hitBox.collisionType = CollisionType.passive;
    } else if (sizeDimension >= (1.1 * _dimensions)) {
      _hitBox.collisionType = CollisionType.inactive;
    }

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

  bool get hasFallenOffEdge => currentRadius > (_radiusSteps.last * 1.1);

  SpriteAnimation? getSpriteAnimation() {
    // TODO it might be better to only create these once

    if (type == PowerUpType.ice) {
      // Before anyone complains, I know the below are single frame animations
      // i.e. still images, but really the rest of this code works so
      // I do not want to reimpl it for PositionComponent et al
      switch (Random().nextInt(8)) {
        case 0:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(604, 1393),
                    srcSize: Vector2(726, 378),
                    stepTime: frameInterval),
              ]));

        case 1:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(139, 1377),
                    srcSize: Vector2(418, 394),
                    stepTime: frameInterval),
              ]));

        case 2:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(1385, 1400),
                    srcSize: Vector2(500, 371),
                    stepTime: frameInterval),
              ]));

        case 3:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(1338, 752),
                    srcSize: Vector2(519, 469),
                    stepTime: frameInterval),
              ]));

        case 4:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(678, 771),
                    srcSize: Vector2(593, 454),
                    stepTime: frameInterval),
              ]));

        case 5:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(166, 803),
                    srcSize: Vector2(441, 422),
                    stepTime: frameInterval),
              ]));

        case 6:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(147, 217),
                    srcSize: Vector2(433, 433),
                    stepTime: frameInterval),
              ]));

        case 7:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(666, 256),
                    srcSize: Vector2(586, 394),
                    stepTime: frameInterval),
              ]));

        case 8:
          return SpriteAnimation.fromFrameData(
              Flame.images.fromCache(iceSpriteFile),
              SpriteAnimationData([
                SpriteAnimationFrameData(
                    srcPosition: Vector2(1338, 291),
                    srcSize: Vector2(519, 359),
                    stepTime: frameInterval),
              ]));
      }
    }

    return SpriteAnimation.fromFrameData(
        Flame.images.fromCache(fireSpriteFile),
        SpriteAnimationData([
          SpriteAnimationFrameData(
              srcPosition: Vector2(786, 3775),
              srcSize: Vector2(286, 761),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(1935, 3765),
              srcSize: Vector2(478, 771),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(1825, 2798),
              srcSize: Vector2(752, 683),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(3247, 2710),
              srcSize: Vector2(287, 791),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(3086, 3619),
              srcSize: Vector2(721, 897),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(4450, 3794),
              srcSize: Vector2(574, 742),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(4273, 2544),
              srcSize: Vector2(820, 1045),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(5558, 2583),
              srcSize: Vector2(956, 869),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(5571, 1685),
              srcSize: Vector2(930, 732),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(4368, 1528),
              srcSize: Vector2(697, 957),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(3138, 1665),
              srcSize: Vector2(669, 918),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(1648, 1655),
              srcSize: Vector2(1066, 948),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(513, 1577),
              srcSize: Vector2(806, 791),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(636, 2573),
              srcSize: Vector2(683, 967),
              stepTime: frameInterval),
        ]));
  }
}
