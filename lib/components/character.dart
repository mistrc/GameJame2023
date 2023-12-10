import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame01/components/power_up.dart';
import 'package:flame01/game/tunnel_game.dart';

import '../utilities/constants.dart';
import 'obstacle.dart';

enum DirectionOfMovement { left, right }

class Character extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<TunnelGame> {
  static const frameInterval = 0.07;

  late final SpriteAnimation _movingLeftAnimation;
  late final SpriteAnimation _movingRightAnimation;

  final double _radiusToEdge;
  static const _bufferFromEdge = 10.0;

  final RectangleHitbox _hitBox = RectangleHitbox();

  /// A measure of how fast the character is moving round the tunnel
  double _angularMomentum = 0;

  /// Multiplier to apply to how much gravity caused the character to go back to the bottom of the tunnel
  static const _gravitationalConstant = 0.1;

  static const _dimensions = 40.0;

  final Vector2 _centreOfRotation;

  Character({required Vector2 centerOfRotation, required double radiusToEdge})
      : _radiusToEdge = radiusToEdge,
        _centreOfRotation = centerOfRotation,
        super(
            position: centerOfRotation.clone(),
            size: Vector2(_dimensions, _dimensions));

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    _loadSpriteAnimation();
    animation = _getSpriteAnimation();

    add(_hitBox);
    _hitBox.debugMode = false;

    return super.onLoad();
  }

  void move(DirectionOfMovement movement) {
    switch (movement) {
      case DirectionOfMovement.left:
        _angularMomentum += pi / 16;
        _setAnimation(_movingLeftAnimation);
        break;

      case DirectionOfMovement.right:
        _angularMomentum -= pi / 16;
        _setAnimation(_movingRightAnimation);
        break;
    }
  }

  void _setAnimation(SpriteAnimation sprite) {
    if (animation != sprite) {
      animation = sprite;
    }
  }

  @override
  void update(double dt) {
    if (game.isStillAlive) {
      final angleInTunnel = angle % (2 * pi);
      _angularMomentum -= _gravitationalConstant * sin(angleInTunnel);

      /// Don't want the character osculating forever, so applying some damping
      _angularMomentum *= 0.995;

      /// Don't want the character spinning away
      _angularMomentum = clampDouble(_angularMomentum, -5.5, 5.5);

      _setAnimationRate();

      angle += _angularMomentum * dt;

      final deltaX =
          (_radiusToEdge - _bufferFromEdge - _dimensions) * sin(angle);
      final deltaY =
          (_radiusToEdge - _bufferFromEdge - _dimensions) * cos(angle);

      position =
          Vector2(_centreOfRotation.x - deltaX, _centreOfRotation.y + deltaY);
    }
    super.update(dt);
  }

  void _setAnimationRate() {
    /// Are we coming to a stop
    if (0.08 > _angularMomentum && _angularMomentum > -0.08) {
      animation!.loop = false;
    } else {
      animation!.stepTime = 0.1 / _angularMomentum.abs();

      animation!.loop = true;
      _setAnimation((_angularMomentum > 0
          ? _movingLeftAnimation
          : _movingRightAnimation));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
      game.looseLifeBecauseOfObstacle(other);
    } else if (other is PowerUp) {
      game.hitPowerUp(other);
    }

    super.onCollision(intersectionPoints, other);
  }

  void _loadSpriteAnimation() {
    _movingRightAnimation = SpriteAnimation.fromFrameData(
        Flame.images.fromCache(catMovementFile),
        SpriteAnimationData([
          SpriteAnimationFrameData(
              srcPosition: Vector2(826, 138),
              srcSize: Vector2(329, 257),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(68, 497),
              srcSize: Vector2(335, 245),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(445, 490),
              srcSize: Vector2(343, 252),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(816, 453),
              srcSize: Vector2(353, 289),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(82, 60),
              srcSize: Vector2(344, 336),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(444, 143),
              srcSize: Vector2(358, 252),
              stepTime: frameInterval),
        ]));

    _movingLeftAnimation = SpriteAnimation.fromFrameData(
        Flame.images.fromCache(catMovementFile),
        SpriteAnimationData([
          SpriteAnimationFrameData(
              srcPosition: Vector2(1287, 141),
              srcSize: Vector2(329, 257),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(2039, 501),
              srcSize: Vector2(330, 245),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(1654, 462),
              srcSize: Vector2(343, 284),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(1277, 459),
              srcSize: Vector2(349, 287),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(2016, 119),
              srcSize: Vector2(339, 282),
              stepTime: frameInterval),
          SpriteAnimationFrameData(
              srcPosition: Vector2(1644, 146),
              srcSize: Vector2(349, 252),
              stepTime: frameInterval),
        ]));
  }

  SpriteAnimation _getSpriteAnimation(
      {DirectionOfMovement direction = DirectionOfMovement.left}) {
    switch (direction) {
      case DirectionOfMovement.left:
        return _movingLeftAnimation;
      case DirectionOfMovement.right:
        return _movingRightAnimation;
    }
  }
}
