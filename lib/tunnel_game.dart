import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class TunnelGame extends FlameGame {
  double durationPassed = 0;
  static const transitionDuration = 5.0;

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
    Color.fromARGB(170, 157, 157, 214),
    Color.fromARGB(170, 118, 118, 219),
    Color.fromARGB(170, 77, 77, 221),
    Color.fromARGB(170, 46, 46, 228),
    Color(0xAA0000EE)
  ];

  /// The separation between each of these steps is intentionally
  /// larger and larger so that the closer parts of the tunnel
  /// feel like they are moving faster
  static const radiusSteps = [20.0, 35.0, 65.0, 125.0, 245.0];

  final circles = [
    CircleComponent(),
    CircleComponent(),
    CircleComponent(),
    CircleComponent()
  ];

  @override
  Future<void> onLoad() async {
    final outerCircle = CircleComponent(radius: radiusSteps.last);
    outerCircle.paint = Paint()..color = colourSteps.last;
    outerCircle.position = getCirclePositionGivenRadius(radiusSteps.last);
    add(outerCircle);

    onLoadAddTunnelSection(3);
    onLoadAddTunnelSection(2);
    onLoadAddTunnelSection(1);
    onLoadAddTunnelSection(0);
  }

  void onLoadAddTunnelSection(int index) {
    circles[index].paint = Paint()..color = colourSteps[index];
    circles[index].radius = radiusSteps[index];
    add(circles[index]);
  }

  @override
  void update(double dt) {
    durationPassed += dt;

    final transitionPercentage =
        ((durationPassed % transitionDuration) / transitionDuration);

    updateTunnelRender(transitionPercentage, 0);
    updateTunnelRender(transitionPercentage, 1);
    updateTunnelRender(transitionPercentage, 2);
    updateTunnelRender(transitionPercentage, 3);

    debugPrint(
        '${transitionPercentage.toStringAsFixed(3)}  The aimed for colour ${colourSteps.last} what the colour has got to ${circles.last.paint.color}');

    super.update(dt);
  }

  void updateTunnelRender(double transitionPercentage, int index) {
    final radius = lerpDouble(
        radiusSteps[index], radiusSteps[index + 1], transitionPercentage)!;
    final color = Color.lerp(
        colourSteps[index], colourSteps[index + 1], transitionPercentage);

    circles[index].radius = radius;
    circles[index].position = getCirclePositionGivenRadius(radius);
    circles[index].paint.color = color!;
  }

  Vector2 getCirclePositionGivenRadius(double radius) => Vector2(
      circleXCoordinate - radius,
      circleYCoordinateConst + (radius * circleYCoordinateCoef));
}
