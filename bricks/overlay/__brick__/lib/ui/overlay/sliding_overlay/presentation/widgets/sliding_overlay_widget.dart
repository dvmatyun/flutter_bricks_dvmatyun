import 'dart:async';

import 'package:flutter/material.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_params.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_ui_command.dart';

class SlidingOverlayWidget extends StatefulWidget {
  const SlidingOverlayWidget({
    required this.overlayKey,
    required this.streamCommands,
    required this.overlayParams,
    required this.child,
    Key? key,
  }) : super(key: key);

  final String overlayKey;
  final Widget child;
  final Stream<OverlayUiCommand> streamCommands;
  final OverlayParams overlayParams;

  @override
  State<SlidingOverlayWidget> createState() => _SlidingOverlayWidgetState();
}

class _SlidingOverlayWidgetState extends State<SlidingOverlayWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: widget.overlayParams.animationDuration,
    vsync: this,
  );
  late final Animation<Offset> _offsetAnimation;

  StreamSubscription? sub;
  @override
  void initState() {
    final additionalDy = (widget.overlayParams.overlayHeight ?? 0) == 0
        ? 0.0
        : (widget.overlayParams.topOffset) / widget.overlayParams.overlayHeight!;
    final startOyPosition = -1 - additionalDy;
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, startOyPosition),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));

    super.initState();
    sub = widget.streamCommands.listen((event) {
      if (event.key == widget.overlayKey) {
        if (event.doOpen) {
          _controller.animateTo(1);
        } else {
          _controller.animateTo(0);
        }
      }
    });
  }

  @override
  void dispose() {
    sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
