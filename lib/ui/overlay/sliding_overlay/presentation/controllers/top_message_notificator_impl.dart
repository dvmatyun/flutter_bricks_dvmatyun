import 'dart:async';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_message.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/common/models/overlay_params.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/domain/controllers/sliding_overlay_controller.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/domain/controllers/top_message_notificator.dart';
import 'package:flutter_bricks_dvmatyun/ui/overlay/sliding_overlay/presentation/controllers/sliding_overlay_controller_impl.dart';

class TopMessageNotificatorImpl extends SlidingOverlayControllerImpl implements ITopMessageNotificator {
  final TypedMessageBuilder _typedMessageBuilder;
  StreamSubscription? _subscription;

  final _overlayThrottlers = <String, _Throttler>{};

  TopMessageNotificatorImpl({
    required OverlayInsertFunc overlayInsertFunc,
    required Stream<OverlayMessage> typedMessageStream,
    required TypedMessageBuilder typedMessageBuilder,
  })  : _typedMessageBuilder = typedMessageBuilder,
        super(overlayInsertFunc) {
    /// Constructor:
    _subscription = typedMessageStream.listen(_processTypedMessage);
  }

  _Throttler? _getThrottlerByOverlayKey(OverlayParams overlayParams) {
    if (overlayParams.key == null || overlayParams.overlayStayDuration == null) {
      return null;
    }
    if (_overlayThrottlers.containsKey(overlayParams.key)) {
      return _overlayThrottlers[overlayParams.key]!;
    }

    /// * 2 is time to show and hide the message box
    final throttler = _Throttler(
      delayMs: overlayParams.animationDuration.inMilliseconds * 2 + overlayParams.overlayStayDuration!.inMilliseconds,
      hideMs: overlayParams.animationDuration.inMilliseconds + overlayParams.overlayStayDuration!.inMilliseconds,
    );
    _overlayThrottlers[overlayParams.key!] = throttler;
    return throttler;
  }

  void _processTypedMessage(OverlayMessage typedMessage) {
    final throttler = _getThrottlerByOverlayKey(typedMessage.overlayParams);
    if (throttler == null) {
      return;
    }

    throttler.run(() {
      _showOverlay(typedMessage);
      Future<void>.delayed(Duration(milliseconds: throttler.hideMs)).then((value) {
        super.hideSlidingOverlay(key: typedMessage.overlayParams.key);
      });
    });
  }

  void _showOverlay(OverlayMessage typedMessage) {
    super.showSlidingOverlayFromTop(
      child: _typedMessageBuilder(typedMessage),
      overlayParams: typedMessage.overlayParams,
    );
  }

  @override
  void close() {
    _subscription?.cancel();
    super.close();
  }
}

/// Prevents the callback from executing until [delayMs] has passed after previous run
class _Throttler {
  final int hideMs;

  final int delayMs;

  Timer? _timer;

  _Throttler({required this.delayMs, required this.hideMs});

  void run(void Function() action) {
    if (_timer?.isActive ?? false) {
      return;
    }
    _timer = Timer(Duration(milliseconds: delayMs), () {});
    action();
  }

  void stop() {
    _timer?.cancel();
  }
}
