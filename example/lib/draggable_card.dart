import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class DraggableWidget extends StatefulWidget {
  final Offset? offset;
  final Widget child;
  final Size video;
  final void Function(double, double) onMove;
  const DraggableWidget({
    super.key,
    required this.child,
    required this.onMove,
    required this.video,
    this.offset,
  });

  @override
  State<DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Alignment _dragAlignment;

  late Animation<Alignment> _animation;

  final _spring = const SpringDescription(
    mass: 10,
    stiffness: 1000,
    damping: 0.9,
  );

  double _normalizeVelocity(Offset velocity, Size size) {
    final normalizedVelocity = Offset(
      velocity.dx / size.width,
      velocity.dy / size.height,
    );
    return -normalizedVelocity.distance;
  }

  void _runAnimation(Offset velocity, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );

    final simulation =
        SpringSimulation(_spring, 0, 0.0, _normalizeVelocity(velocity, size));

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();

    if (widget.offset != null) {
      _dragAlignment = Alignment(widget.offset!.dx, widget.offset!.dy);
    } else {
      _dragAlignment = const Alignment(0.0, 0.0);
    }

    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() => _dragAlignment = _animation.value));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onMove(topLeftPosition().dx, topLeftPosition().dy);
    });
  }

  Offset get getVideoOffset {
    final size = MediaQuery.of(context).size;

    var spacingY = (size.height - widget.video.height) / 2;
    var spacingX = (size.width - widget.video.width) / 2;
    var imageTop =
        math.max(size.height - widget.video.height - spacingY, 0).toDouble();
    var imageLeft =
        math.max(size.width - widget.video.width - spacingX, 0).toDouble();
    var offset = Offset(imageLeft, imageTop);

    return offset;
  }

  Offset get getImageOffset {
    final size = MediaQuery.of(context).size;
    final imageOffset = _dragAlignment.alongSize(size);
    final imageHeight = (widget.child as Image).height!;
    final imageWidth = (widget.child as Image).width!;

    var offset = Offset((imageOffset.dx - (imageWidth / 2)),
        (imageOffset.dy - (imageHeight / 2)));
    log(offset.toString());
    return offset;
  }

  Offset topLeftPosition() {
    return getImageOffset - getVideoOffset;
  }

  @override
  Widget build(BuildContext context) {
    // 392.72727272727275
    // 805.0909090909091
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onPanStart: (details) => _controller.stop(canceled: true),
      onPanUpdate: (details) {
        setState(() => _dragAlignment += Alignment(
              details.delta.dx / (size.width / 2),
              details.delta.dy / (size.height / 2),
            ));
      },
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond, size);
        widget.onMove(topLeftPosition().dx, topLeftPosition().dy);
      },
      child: Align(
        alignment: _dragAlignment,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
