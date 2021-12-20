import 'dart:math' as math;

import 'package:flutter/material.dart';

typedef JoystickCallback = void Function(double speed, double angleInDegree);

class Joystick extends StatefulWidget {
  const Joystick({
    Key? key,
    this.backgroundRadius = 50.0,
    this.cursorRadius = 20.0,
    this.backgroundColor = Colors.grey,
    this.cursorColor = Colors.blueAccent,
    this.onChanged,
  }) : super(key: key);

  final double backgroundRadius;
  final double cursorRadius;
  final Color backgroundColor;
  final Color cursorColor;
  final JoystickCallback? onChanged;

  @override
  _JoystickState createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  late math.Point<double> _backgroundOrigin;
  late math.Point<double> _cursorLocation;

  double get backgroundDiameter => 2.0 * widget.backgroundRadius;
  double get stickerDiameter => 2.0 * widget.cursorRadius;

  void _analysePositionByPanDown(DragDownDetails details) {
    _analysePosition(offset: details.localPosition);
  }

  void _analysePositionByPanUp(DragUpdateDetails details) {
    _analysePosition(offset: details.localPosition);
  }

  void _analysePosition({required Offset offset}) {
    late double cursorX;
    late double cursorY;

    final double touchX = offset.dx.clamp(0.0, backgroundDiameter);
    final double touchY = offset.dy.clamp(0.0, backgroundDiameter);
    cursorX = touchX;
    cursorY = touchY;

    // Atan2 range ................................................ [-pi to pi]
    var angleInRadian = math.atan2(
      touchX - _backgroundOrigin.x,
      touchY - _backgroundOrigin.y,
    );

    // Correction to convert atan2 to correct radian
    final correction = angleInRadian >= (math.pi / 2.0)
        ? (-1.0) * math.pi / 2.0
        : (3.0 * math.pi) / 2.0;
    angleInRadian += correction;

    // TouchPosition ................................................... (x, y)
    // Origin .......................................................... (a, b)
    // Touch in circle ............................... (x - a)² + (y - b)² < R²
    final dxAtPow2 = math.pow(touchX - _backgroundOrigin.x, 2.0);
    final dyAtPow2 = math.pow(touchY - _backgroundOrigin.y, 2.0);
    final distanceToOriginAtPow2 = dxAtPow2 + dyAtPow2;

    // Touch is out of background
    final innerRadius = widget.backgroundRadius - widget.cursorRadius;
    if (distanceToOriginAtPow2 > math.pow(innerRadius, 2.0)) {
      cursorX = _backgroundOrigin.x + innerRadius * math.cos(angleInRadian);
      cursorY = _backgroundOrigin.y - innerRadius * math.sin(angleInRadian);
    }

    if (widget.onChanged != null) {
      final correctedDxAtPow2 = math.pow(cursorX - _backgroundOrigin.x, 2.0);
      final correctedDyAtPow2 = math.pow(cursorY - _backgroundOrigin.y, 2.0);
      final correctedDistanceToOrigin =
          math.sqrt(correctedDxAtPow2 + correctedDyAtPow2);
      final speedRatio = (correctedDistanceToOrigin * 100.0) / innerRadius;
      final angleInDegree = (angleInRadian * 360.0) / (2.0 * math.pi);

      widget.onChanged?.call(speedRatio, angleInDegree);
    }

    setState(() => _cursorLocation = math.Point<double>(cursorX, cursorY));
  }

  void _resetPosition() => setState(() => _cursorLocation = _backgroundOrigin);

  void _setupPositions() {
    _backgroundOrigin = math.Point<double>(
      widget.backgroundRadius,
      widget.backgroundRadius,
    );

    _cursorLocation = _backgroundOrigin;
  }

  @override
  void initState() {
    super.initState();
    _setupPositions();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _analysePositionByPanUp,
      onPanDown: _analysePositionByPanDown,
      onPanEnd: (_) => _resetPosition(),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(
            width: backgroundDiameter,
            height: backgroundDiameter,
            decoration: BoxDecoration(
              color: widget.backgroundColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: _cursorLocation.x,
            top: _cursorLocation.y,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
              child: Container(
                width: stickerDiameter,
                height: stickerDiameter,
                decoration: BoxDecoration(
                  color: widget.cursorColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
