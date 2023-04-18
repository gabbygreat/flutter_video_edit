import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class DraggableWidget extends StatefulWidget {
  final Offset? offset;
  final Widget child;
  final void Function(double, double) onMove;
  const DraggableWidget({
    super.key,
    required this.child,
    required this.onMove,
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
      _dragAlignment = const Alignment(0, -0.2);
    }

    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() => _dragAlignment = _animation.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanStart: (details) => _controller.stop(canceled: true),
      onPanUpdate: (details) {
        widget.onMove(details.localPosition.dx, details.localPosition.dy);
        setState(() => _dragAlignment += Alignment(
              details.delta.dx / (size.width / 2),
              details.delta.dy / (size.height / 2),
            ));
      },
      onPanEnd: (details) =>
          _runAnimation(details.velocity.pixelsPerSecond, size),
      child: Align(
        alignment: _dragAlignment,
        child: widget.child,
      ),
    );
  }
}
