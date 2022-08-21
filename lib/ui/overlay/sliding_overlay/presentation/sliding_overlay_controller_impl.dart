import 'package:flutter/material.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_params.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/domain/sliding_overlay_controller.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/presentation/sliding_overlay_widget.dart';

class SlidingOverlayControllerImpl implements ISlidingOverlayController {
  final BuildContext _context;

  final _anonymousEntries = <OverlayEntry>[];
  final _namedEntries = <String, OverlayEntry>{};

  final _entriesStates = <String, bool>{};
  final VoidCallback _setState;

  SlidingOverlayControllerImpl(
    BuildContext context,
    VoidCallback setStateFunc,
  )   : _context = context,
        _setState = setStateFunc;

  @override
  void hideSlidingOverlay({String? key}) {
    // TODO: implement hideSlidingOverlay
  }

  @override
  void immediateHideOverlay({String? key}) {
    if (key == null) {
      for (final oe in _anonymousEntries) {
        oe.remove();
      }
    } else {
      final oe = _namedEntries.remove(key);
      oe?.remove();
    }
  }

  @override
  void showSlidingOverlayFromTop(Widget child, {String? key, OverlayParams? overlayParams}) {
    final width = overlayParams?.width ?? MediaQuery.of(_context).size.width;
    final height = overlayParams?.height ?? MediaQuery.of(_context).size.height;
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: (MediaQuery.of(_context).size.width - width) / 2,
        width: width,
        height: height,
        child: SlidingOverlayWidget(
          child: child,
        ),
      ),
    );

    if (key == null) {
      _anonymousEntries.add(entry);
    } else {
      if (_namedEntries[key] != null) {
        immediateHideOverlay(key: key);
      }
      _namedEntries[key] = entry;
      _entriesStates[key] = true;
    }

    Overlay.of(_context)!.insert(entry);
  }
}
