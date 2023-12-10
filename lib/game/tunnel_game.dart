import 'dart:ui';

import 'package:calc/calc.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame01/components/character.dart';
import 'package:flame01/components/obstacle.dart';
import 'package:flame01/components/speedometer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/arrow_based_controller.dart';
import '../components/power_up.dart';
import '../utilities/constants.dart';

class TunnelGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  double durationPassed = 0;
  double transitionDuration = 2.0;

  /// Center each circle at the same point on the x-axis
  static const circleXCoordinate = 500.0;

  /// The y coordinate for the centre of the circle is dependant on the radius
  /// For now the calculation is linear, but would be good to see impact of it
  /// being quadratic, as it might make the tunnel look like it is bending
  /// Coefficients for the linear representation are as per
  ///     circle_centre = constant{P} + radius*coefficient{Q}
  static const circleYCoordinateConst = 1100 / 3;
  static const circleYCoordinateCoef = -4 / 3;

  /// Provides the illusion of motion because the colours transition from one
  /// to the next
  /// Note that the difference in hue cannot be too much otherwise the lerp
  /// will not have transitioned far enough when the reset happens after each
  /// transitionDuration has passed
  static const colourSteps = [
    Color.fromARGB(255, 210, 210, 150),
    Color.fromARGB(255, 180, 180, 150),
    Color.fromARGB(255, 150, 150, 150),
    Color.fromARGB(255, 120, 120, 150),
    Color.fromARGB(255, 90, 90, 150),
    Color.fromARGB(255, 50, 50, 150),
    Color.fromARGB(255, 0, 0, 150),
  ];

  static const maxCircleRadius = 250.0;

  /// The separation between each of these steps is intentionally
  /// larger and larger so that the closer parts of the tunnel
  /// feel like they are moving faster
  final radiusSteps = List.generate(
      colourSteps.length,
      (index) =>
          maxCircleRadius /
          (pow(scaleFactorBetweenRings, colourSteps.length - index - 1)));
  // [20.0, 35.0, 65.0, 125.0, 245.0]

  final circles =
      List.generate(colourSteps.length - 1, (index) => CircleComponent());

  late final Character character;

  /// Maximum number of obstacles will increase as the game goes on
  int maxNumberOfObstacles = 10;
  double likelihoodOfGettingObstacle = 0.85;
  final _obstacles = <Obstacle>[];

  int maxNumberOfPowerUps = 3;
  double likelihoodOfGettingPowerUp = 0.88;
  final _powerUps = <PowerUp>[];

  /// Using this distribution function to generate the locations of the
  /// obstacles to be mostly around the bottom of the tunnel
  final distribution = NormalDistribution(mean: 0, variance: pi / 3);

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 50, 50, 150);
  }

  /// ----------------- ONLOAD ------------------
  @override
  Future<void> onLoad() async {
    await Flame.images.loadAll([
      spriteFileName,
      fireSpriteFile,
      iceSpriteFile,
      leftArrowFile,
      rightArrowFile
    ]);

    final outerCircle = CircleComponent(radius: radiusSteps.last);
    outerCircle.paint = Paint()..color = colourSteps.last;
    outerCircle.position =
        _getTopLeftCornerOfCircleGivenRadius(radiusSteps.last);
    add(outerCircle);

    for (var i = circles.length - 1; i >= 0; i--) {
      _onLoadAddTunnelSection(i);
    }

    character = Character(
        centerOfRotation: finalCenterOfRotation,
        radiusToEdge: radiusSteps.last);
    add(character);

    add(Speedometer(position: Vector2(800, 200)));

    final moveLeft = ArrowBasedController(
        character: character,
        sprite: Sprite(
          Flame.images.fromCache(leftArrowFile),
          srcPosition: Vector2(117, 111),
          srcSize: Vector2(376, 243),
        ),
        direction: DirectionOfMovement.left,
        position: Vector2(350, 550));
    add(moveLeft);

    final moveRight = ArrowBasedController(
        character: character,
        sprite: Sprite(
          Flame.images.fromCache(rightArrowFile),
          srcPosition: Vector2(268, 251),
          srcSize: Vector2(376, 246),
        ),
        direction: DirectionOfMovement.right,
        position: Vector2(530, 550));
    add(moveRight);
  }

  late final _initialCenterOfRotation = _calcInitialCenterOfRotation();
  Vector2 _calcInitialCenterOfRotation() {
    var val = _getTopLeftCornerOfCircleGivenRadius(radiusSteps.first);
    val.add(Vector2(radiusSteps.first, radiusSteps.first));
    return val;
  }

  Vector2 get initialCenterOfRotation => _initialCenterOfRotation;

  late final _finalCenterOfRotation = _calcFinalCenterOfRotation();
  Vector2 _calcFinalCenterOfRotation() {
    var val = _getTopLeftCornerOfCircleGivenRadius(radiusSteps.last);
    val.add(Vector2(radiusSteps.last, radiusSteps.last));
    return val;
  }

  Vector2 get finalCenterOfRotation => _finalCenterOfRotation;

  void _onLoadAddTunnelSection(int index) {
    circles[index].paint = Paint()..color = colourSteps[index];
    circles[index].radius = radiusSteps[index];
    add(circles[index]);
  }

  @override
  void update(double dt) {
    durationPassed += dt;

    final transitionPercentage =
        ((durationPassed % transitionDuration) / transitionDuration);

    for (var i = 0; i < circles.length; i++) {
      _updateTunnelRender(transitionPercentage, i);
    }

    // Add obstacles, using the normal dist curve to limit how many
    // come out at the same time, otherwise they will all be grouped in one place
    if (_obstacles.length < maxNumberOfObstacles) {
      if (distribution.sample() > (pi * likelihoodOfGettingObstacle)) {
        final obstacle = Obstacle(
            initialCenterOfRotation: initialCenterOfRotation,
            finalCenterOfRotation: finalCenterOfRotation,
            radiusSteps: radiusSteps,
            lifetime: circles.length * transitionDuration);
        obstacle.angle = distribution.sample();
        _obstacles.add(obstacle);
        add(obstacle);
      }
    }

    _obstacles.removeWhere((obstacle) {
      if (obstacle.hasFallenOffEdge) {
        remove(obstacle);
        return true;
      }
      return false;
    });

    // Add powerUps, using the normal dist curve to limit how many
    // come out at the same time, otherwise they will all be grouped in one place
    if (_powerUps.length < maxNumberOfPowerUps) {
      if (distribution.sample() > (pi * 0.88)) {
        final fire = PowerUp(
            initialCenterOfRotation: initialCenterOfRotation,
            finalCenterOfRotation: finalCenterOfRotation,
            radiusSteps: radiusSteps,
            lifetime: circles.length * transitionDuration)
          ..anchor = Anchor.bottomCenter
          ..angle = distribution.sample();
        _powerUps.add(fire);
        add(fire);
      }
    }

    _powerUps.removeWhere((powerUp) {
      if (powerUp.hasFallenOffEdge) {
        remove(powerUp);
        return true;
      }
      return false;
    });

    super.update(dt);
  }

  void _updateTunnelRender(double transitionPercentage, int index) {
    final radius = lerpDouble(
        radiusSteps[index], radiusSteps[index + 1], transitionPercentage)!;
    final color = Color.lerp(
        colourSteps[index], colourSteps[index + 1], transitionPercentage);

    circles[index].radius = radius;
    circles[index].position = _getTopLeftCornerOfCircleGivenRadius(radius);
    circles[index].paint.color = color!;
  }

  Vector2 _getTopLeftCornerOfCircleGivenRadius(double radius) => Vector2(
      circleXCoordinate - radius,
      circleYCoordinateConst + (radius * circleYCoordinateCoef));

  /// Accepting keyboard input to add a delta push to the character
  /// in that direction
  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.length == 1 && event is RawKeyDownEvent) {
      final key = keysPressed.first;
      if (key == LogicalKeyboardKey.arrowLeft) {
        character.move(DirectionOfMovement.left);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        character.move(DirectionOfMovement.right);
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void hitPowerUp(PowerUp powerUp) {
    // Yes I know that (0.95 * 1.05) != 1
    switch (powerUp.type) {
      case PowerUpType.fire:
        transitionDuration *= 0.95;
        break;

      case PowerUpType.ice:
        transitionDuration *= 1.05;
        break;
    }

    debugPrint('transitionInterval is now $transitionDuration');

    // As animation gets faster, the number of times that update is called decreases
    // so need to compensate by making it more likely that and object will appear
    if (transitionDuration < 1.8) {
      likelihoodOfGettingObstacle = 0.8;
      likelihoodOfGettingPowerUp = 0.85;
    } else if (transitionDuration < 1.5) {
      likelihoodOfGettingObstacle = 0.75;
      likelihoodOfGettingPowerUp = 0.82;
    } else if (transitionDuration < 1.2) {
      likelihoodOfGettingObstacle = 0.7;
      likelihoodOfGettingPowerUp = 0.79;
    } else if (transitionDuration < 0.9) {
      likelihoodOfGettingObstacle = 0.4;
      likelihoodOfGettingPowerUp = 0.76;
    } else {
      likelihoodOfGettingObstacle = 0.85;
      likelihoodOfGettingPowerUp = 0.88;
    }

    _powerUps.remove(powerUp);
    remove(powerUp);
  }
}
