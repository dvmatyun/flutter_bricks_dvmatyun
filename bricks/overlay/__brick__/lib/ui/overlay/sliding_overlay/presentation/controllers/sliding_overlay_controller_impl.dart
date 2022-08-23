import 'dart:async';

import 'package:flutter/material.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_params.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_ui_command.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/sliding_overlay/domain/controllers/sliding_overlay_controller.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/sliding_overlay/presentation/widgets/sliding_overlay_widget.dart';

class SlidingOverlayControllerImpl implements ISlidingOverlayController {
  final OverlayInsertFunc _overlayInsertFunc;
  final _anonymousEntries = <OverlayEntry>[];
  final _namedEntries = <String, OverlayEntry>{};

  final _entriesStates = <String, bool>{};
  @override
  Map<String, bool> get entriesStates => _entriesStates;

  final _entriesParams = <String, OverlayParams>{};

  final _commandsSc = StreamController<OverlayUiCommand>.broadcast();

  bool _isDisposed = false;

  SlidingOverlayControllerImpl(
    OverlayInsertFunc overlayInsertFunc,
  ) : _overlayInsertFunc = overlayInsertFunc;

  static const unknownKey = 'unknown';

  @override
  void hideSlidingOverlay({String? key}) {
    if (key != null) {
      final params = _entriesParams[key];
      _commandsSc.add(
        OverlayUiCommand(
          key: key,
          doOpen: true,
        ),
      );

      if (params != null) {
        _commandsSc.add(
          OverlayUiCommand(
            key: key,
            doOpen: false,
          ),
        );
        if (_entriesStates[key] ?? false) {
          Future<void>.delayed(params.animationDuration).then((value) => immediateHideOverlay(key: key));
        }
      } else {
        immediateHideOverlay(key: key);
      }
      _entriesStates[key] = false;
    } else {
      immediateHideOverlay(key: key);
    }
  }

  @override
  void immediateHideOverlay({String? key}) {
    if (key == null) {
      for (final oe in _anonymousEntries) {
        oe.remove();
      }
      _anonymousEntries.clear();
    } else {
      final oe = _namedEntries.remove(key);
      _entriesStates[key] = false;
      oe?.remove();
    }
  }

  @override
  void showSlidingOverlayFromTop({required Widget child, required OverlayParams overlayParams}) {
    if (_isDisposed) {
      return;
    }
    final key = overlayParams.key;
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlayParams.topOffset,
        left: overlayParams.leftOffset,
        width: overlayParams.overlayWidth,
        height: overlayParams.overlayHeight,
        child: SlidingOverlayWidget(
          overlayKey: key ?? 'unknown',
          overlayParams: overlayParams,
          streamCommands: _commandsSc.stream,
          child: child,
        ),
      ),
    );

    //Overlay.of(_context)!.insert(entry);
    _overlayInsertFunc(entry);

    if (key == null) {
      _anonymousEntries.add(entry);
    } else {
      if (_namedEntries[key] != null) {
        immediateHideOverlay(key: key);
      }
      _namedEntries[key] = entry;
      _entriesStates[key] = true;
      _entriesParams[key] = overlayParams;
      Future<void>.delayed(const Duration(milliseconds: 100)).then(
        (_) => _commandsSc.add(
          OverlayUiCommand(
            key: key,
            doOpen: true,
          ),
        ),
      );
    }
  }

  @override
  void close() {
    _commandsSc.close();
    immediateHideOverlay();
    for (final key in _namedEntries.keys) {
      immediateHideOverlay(key: key);
    }
    _isDisposed = true;
  }

  @override
  bool isOverlayIsShown(String key) => _entriesStates[key] ?? false;
}
