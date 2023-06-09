import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:video_edit_example/draggable_card.dart';
import 'package:video_edit_example/slider_widget.dart';
import 'dart:math' as math;
import 'model.dart';

extension FancyIterable on Iterable<double> {
  double get max => reduce(math.max);

  double get min => reduce(math.min);
}

class DrawingAppCanvas extends StatelessWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<Image?> backgroundImage;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<bool> filled;
  final List<DraggableWidget> widgetList;

  const DrawingAppCanvas({
    super.key,
    required this.selectedColor,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
    required this.widgetList,
  });

  void onPointerDown(PointerDownEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        color: selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    final points = List<Offset>.from(currentSketch.value?.points ?? [])
      ..add(offset);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        color: selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerUp(PointerUpEvent details, BuildContext context) {
    // final box = context.findRenderObject() as RenderBox;
    // allSketches.value = List<Sketch>.from(allSketches.value)
    //   ..add(currentSketch.value!);
    // final maxX = allSketches.value.last.points.map((e) => e.dx).toList().max;
    // final minX = allSketches.value.last.points.map((e) => e.dx).toList().min;

    // final maxY = allSketches.value.last.points.map((e) => e.dy).toList().max;
    // final minY = allSketches.value.last.points.map((e) => e.dy).toList().min;

    // Rect rect = Rect.fromPoints(Offset(minX, minY), Offset(maxX, maxY));
    // rect.s

    // final x = rect.topCenter.dx / box.size.width;
    // final y = rect.topCenter.dy / box.size.height;

    // widgetList.add(DraggableWidget(
    //   onMove: (p0, p1) {},
    //   offset: Offset(x, y),
    //   child: Container(
    //     constraints: BoxConstraints(
    //       minHeight: rect.size.height,
    //       minWidth: rect.size.width,
    //     ),
    //     color: Colors.red,
    //     height: rect.size.height,
    //     width: rect.size.width,
    //     child: CustomPaint(
    //       painter: sketchDrawing(allSketches.value.last),
    //     ),
    //   ),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: Stack(
          children: [
            buildAllSketches(context),
            buildCurrentPath(context),
            Align(
              alignment: const Alignment(0.95, -0.8),
              child: SliderWidget(
                onSlide: (color) {
                  selectedColor.value = color;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAllSketches(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ValueListenableBuilder<List<Sketch>>(
        valueListenable: allSketches,
        builder: (context, sketches, _) {
          return RepaintBoundary(
            key: canvasGlobalKey,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches,
                  backgroundImage: backgroundImage.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (details) => onPointerDown(details, context),
      onPointerMove: (details) => onPointerMove(details, context),
      onPointerUp: (details) => onPointerUp(details, context),
      child: ValueListenableBuilder(
        valueListenable: currentSketch,
        builder: (context, sketch, child) {
          return RepaintBoundary(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: CustomPaint(
                painter: sketchDrawing(sketch),
              ),
            ),
          );
        },
      ),
    );
  }

  SketchPainter sketchDrawing(Sketch? sketch) {
    return SketchPainter(
      sketches: sketch == null ? [] : [sketch],
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;
  final Image? backgroundImage;

  const SketchPainter({
    Key? key,
    this.backgroundImage,
    required this.sketches,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      canvas.drawImageRect(
        backgroundImage!,
        Rect.fromLTWH(0, 0, backgroundImage!.width.toDouble(),
            backgroundImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint(),
      );
    }
    for (Sketch sketch in sketches) {
      final points = sketch.points;
      if (points.isEmpty) return;

      final path = Path();

      path.moveTo(points[0].dx, points[0].dy);
      if (points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: 1,
          ),
        );
      }

      for (int i = 1; i < points.length - 1; ++i) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
          p0.dx,
          p0.dy,
          (p0.dx + p1.dx) / 2,
          (p0.dy + p1.dy) / 2,
        );
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round;

      if (!sketch.filled) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 5;
      }

      // define first and last points for convenience
      Offset firstPoint = sketch.points.first;
      Offset lastPoint = sketch.points.last;

      // create rect to use rectangle and circle
      Rect rect = Rect.fromPoints(firstPoint, lastPoint);

      // Calculate center point from the first and last points
      Offset centerPoint = (firstPoint / 2) + (lastPoint / 2);

      // Calculate path's radius from the first and last points
      double radius = (firstPoint - lastPoint).distance / 2;

      if (sketch.type == SketchType.scribble) {
        canvas.drawPath(path, paint);
      } else if (sketch.type == SketchType.square) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          paint,
        );
      } else if (sketch.type == SketchType.line) {
        canvas.drawLine(firstPoint, lastPoint, paint);
      } else if (sketch.type == SketchType.circle) {
        canvas.drawOval(rect, paint);
        // Uncomment this line if you need a PERFECT CIRCLE
        // canvas.drawCircle(centerPoint, radius , paint);
      } else if (sketch.type == SketchType.polygon) {
        Path polygonPath = Path();
        int sides = sketch.sides;
        var angle = (math.pi * 2) / sides;

        double radian = 0.0;

        Offset startPoint =
            Offset(radius * math.cos(radian), radius * math.sin(radian));

        polygonPath.moveTo(
            startPoint.dx + centerPoint.dx, startPoint.dy + centerPoint.dy);
        for (int i = 1; i <= sides; i++) {
          double x = radius * math.cos(radian + angle * i) + centerPoint.dx;
          double y = radius * math.sin(radian + angle * i) + centerPoint.dy;
          polygonPath.lineTo(x, y);
        }
        polygonPath.close();
        canvas.drawPath(polygonPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) =>
      oldDelegate.sketches != sketches;
}
