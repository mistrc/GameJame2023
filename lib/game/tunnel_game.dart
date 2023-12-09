import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame01/components/character.dart';
import 'package:flame01/components/obstacle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';

import '../utilities/constants.dart';

class TunnelGame extends FlameGame with KeyboardEvents {
  double durationPassed = 0;
  static const transitionDuration = 2.0;

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
  final radiusSteps = List.generate(colourSteps.length,
      (index) => maxCircleRadius / (pow(1.7, colourSteps.length - index - 1)));
  // [20.0, 35.0, 65.0, 125.0, 245.0]

  final circles =
      List.generate(colourSteps.length - 1, (index) => CircleComponent());

  late final Character character;
  Obstacle? obstacle;

  @override
  Future<void> onLoad() async {
    await Flame.images.load(spriteFileName);

    final outerCircle = CircleComponent(radius: radiusSteps.last);
    outerCircle.paint = Paint()..color = colourSteps.last;
    outerCircle.position =
        _getTopLeftCornerOfCircleGivenRadius(radiusSteps.last);
    add(outerCircle);

    for (var i = circles.length - 1; i >= 0; i--) {
      // circles[i].debugMode = true;
      _onLoadAddTunnelSection(i);
    }

    final initialCenterOfRotation =
        _getTopLeftCornerOfCircleGivenRadius(radiusSteps.first);
    initialCenterOfRotation.add(Vector2(radiusSteps.first, radiusSteps.first));

    final finalCenterOfRotation =
        _getTopLeftCornerOfCircleGivenRadius(radiusSteps.last);
    finalCenterOfRotation.add(Vector2(radiusSteps.last, radiusSteps.last));

    obstacle = Obstacle(
        initialCenterOfRotation: initialCenterOfRotation,
        finalCenterOfRotation: finalCenterOfRotation,
        radiusToEdge: radiusSteps.last,
        lifetime: circles.length * transitionDuration);
    add(obstacle!);

    character = Character(
        centerOfRotation: finalCenterOfRotation,
        radiusToEdge: radiusSteps.last);
    add(character);
  }

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

    if (null != obstacle && obstacle!.hasFallenOffEdge) {
      remove(obstacle!);
      obstacle = null;
    }

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
}
