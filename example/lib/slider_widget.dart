import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  final void Function(Color) onSlide;
  const SliderWidget({super.key, required this.onSlide});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double _value = 0.0;
  List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 300,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 8,
          trackShape: GradientRectSliderTrackShape(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
        child: RotatedBox(
          quarterTurns: 3,
          child: Slider(
            value: _value,
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                _value = value;
                // final color = Color(0xaa112211);
                // widget.onSlide(color);
              });
            },
            activeColor: Colors.white,
            inactiveColor: Colors.transparent,
            divisions: 100,
          ),
        ),
      ),
    );
  }
}

class GradientRectSliderTrackShape extends RectangularSliderTrackShape {
  GradientRectSliderTrackShape({required this.gradient});

  final Gradient gradient;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    // double additionalActiveTrackHeight = 2,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 2.0;
    final trackLeft = offset.dx + 20;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - 2 * 20;

    final rect = Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);

    final paint = Paint()..shader = gradient.createShader(rect);

    context.canvas.drawRect(rect, paint);
  }
}
