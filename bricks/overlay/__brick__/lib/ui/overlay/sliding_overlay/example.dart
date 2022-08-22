import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/overlay_params.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/common/models/typed_message.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/sliding_overlay/domain/controllers/top_message_notificator.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/sliding_overlay/presentation/controllers/top_message_notificator_impl.dart';
import 'package:{{packageName.snakeCase()}}/ui/overlay/sliding_overlay/presentation/widgets/notification_message_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  ITopMessageNotificator? _topMessageNotificator;

  late final msgStream = Stream<String>.periodic(
    const Duration(milliseconds: 1300),
    ((i) => 'message $i'),
  );
  StreamSubscription? sub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _topMessageNotificator = TopMessageNotificatorImpl(
          overlayInsertFunc: (entry) => Overlay.of(context)?.insert(entry),
          typedMessageBuilder: _typedMessageBuilder,
          typedMessageStream: msgStream.map(_mapStringToTypedMsg));
    });
  }

  Widget _typedMessageBuilder(TypedMessage typedMessage) => NotificationMessageWidget(
        child: Text(typedMessage.message),
        onClose: () => _topMessageNotificator!.hideSlidingOverlay(key: typedMessage.overlayParams.key),
      );

  late final overlayParams = OverlayParams(
    key: 'top-message-01',
    screenHeight: MediaQuery.of(context).size.height,
    screenWidth: MediaQuery.of(context).size.width,
    overlayHeight: 60,
    overlayWidth: min(MediaQuery.of(context).size.width / 2, 1000),
    topOffset: 10,
    animationDuration: const Duration(milliseconds: 1000),
    overlayStayDuration: const Duration(milliseconds: 2000),
  );

  late final overlayParams2 = overlayParams.copyWith(
    key: 'top-message-02',
    topOffset: (overlayParams.topOffset * 2 + (overlayParams.overlayHeight ?? 0)),
  );

  TypedMessage _mapStringToTypedMsg(String message) {
    if (_topMessageNotificator!.isOverlayIsShown(overlayParams.key!)) {
      return TypedMessage(type: 'simple', message: message, overlayParams: overlayParams2);
    }
    return TypedMessage(type: 'simple', message: message, overlayParams: overlayParams);
  }

  @override
  void dispose() {
    sub?.cancel();
    _topMessageNotificator?.close();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
