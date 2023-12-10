import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Speedometer extends PositionComponent {
  Speedometer({required super.position});

  final paintWhite = Paint()..color = Colors.white;
  final paintWhiteWithWidth = Paint()
    ..color = Colors.white
    ..strokeWidth = 10;
  final paintBlue = Paint()..color = const Color.fromARGB(255, 50, 50, 150);
  final paintOrange = Paint()
    ..color = Colors.orange
    ..strokeWidth = 5;

  static const _totalAngle = 14 * pi / 8;
  static const _dimension = 250.0;
  static const _lineWidth = 5.0;

  late final _centre = Vector2((_dimension / 2), (_dimension / 2));
  // Vector2(position.x + (_dimension / 2), position.y + (_dimension / 2));

  @override
  void render(Canvas canvas) {
    // drawArc draws a filled in ard, so need the second one to remove the fill and only leave the outline
    canvas.drawArc(const Rect.fromLTRB(0, 0, _dimension, _dimension),
        pi / 2 + pi / 8, _totalAngle, true, paintWhite);

    canvas.drawArc(
        const Rect.fromLTRB(_lineWidth, _lineWidth, _dimension - _lineWidth,
            _dimension - _lineWidth),
        pi / 2 + pi / 8,
        _totalAngle,
        true,
        paintBlue);

    // draw the marks on the speedometer
    const numberOfDivisions = 10;
    const angleOffset = pi / 8;
    const arcAngle = _totalAngle / (numberOfDivisions - 1);
    for (var i = 0; i < numberOfDivisions; i++) {
      bool isFirstOrLast = i == 0 || (i + 1) == numberOfDivisions;
      _markLine(
          canvas,
          i * arcAngle + angleOffset,
          (isFirstOrLast) ? _dimension - 60 : _dimension - 30,
          paintWhiteWithWidth);
    }

    // draw the line for the speed
    _markLine(canvas, 5 * pi / 8, _dimension * 1 / 100, paintOrange);

    super.render(canvas);
  }

  void _markLine(Canvas canvas, double angle, double length, Paint paint) {
    final point1 = Offset(_centre.x - (_dimension * sin(angle) / 2),
        _centre.y + (_dimension * cos(angle) / 2));

    final point2 = Offset(_centre.x - (length * sin(angle) / 2),
        _centre.y + (length * cos(angle) / 2));

    canvas.drawLine(point1, point2, paint);
  }
}
