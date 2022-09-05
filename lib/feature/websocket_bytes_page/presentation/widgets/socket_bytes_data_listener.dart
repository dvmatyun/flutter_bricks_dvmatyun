import 'package:flutter/material.dart';

import '../../../../websocket_universal.dart';

/// SocketBytesDataListener
class SocketBytesDataListener extends StatefulWidget {
  const SocketBytesDataListener({
    required this.socketHandler,
    Key? key,
  }) : super(key: key);

  final IWebSocketHandler<List<int>, List<int>> socketHandler;

  @override
  State<SocketBytesDataListener> createState() => _SocketBytesDataListenerState();
} // SocketBytesDataListener

/// State for widget SocketBytesDataListener
class _SocketBytesDataListenerState extends State<SocketBytesDataListener> {
  IWebSocketHandler<List<int>, List<int>> get socketHandler => widget.socketHandler;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  final _debugEvents = <ISocketLogEvent>[];

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    socketHandler.logEventStream.listen(_listenToDebugEvents);
    // Первичная инициализация виджета
  }

  void _listenToDebugEvents(ISocketLogEvent state) {
    if (state.socketLogEventType == SocketLogEventType.ping) {
      //!return;
    }
    setState(() {
      _addDebugEvent(state);
    });
  }

  void _addDebugEvent(ISocketLogEvent state) {
    _debugEvents.insert(0, state);
    _listKey.currentState!.insertItem(0, duration: const Duration(milliseconds: 250));
  }

  // Remove an item
  // This is trigger when the trash icon associated with an item is tapped
  void _removeDebugItem(int index) {
    _listKey.currentState!.removeItem(index, (_, animation) {
      return SizeTransition(
        sizeFactor: animation,
        child: const Card(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: EdgeInsets.all(0),
          ),
        ),
      );
    }, duration: const Duration(milliseconds: 250));

    _debugEvents.removeAt(index);
  }

  @override
  void didUpdateWidget(SocketBytesDataListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Конфигурация виджета изменилась
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Изменилась конфигурация InheritedWidget'ов
    // Также вызывается после initState, но до build'а
  }

  @override
  void dispose() {
    // Перманетное удаление стейта из дерева
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Expanded(
        child: AnimatedList(
            key: _listKey,
            initialItemCount: 0,
            padding: const EdgeInsets.all(10),
            itemBuilder: (_, index, animation) {
              return SizeTransition(
                key: UniqueKey(),
                sizeFactor: animation,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    height: 102,
                    child: ColoredBox(
                      color: Colors.black12,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_debugEvents[index].socketLogEventType.value} (${_debugEvents[index].status.value})',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                SizedBox(
                                  width: (MediaQuery.of(context).size.width - 90),
                                  child: Text(
                                    processSubtitle(_debugEvents[index]),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            splashRadius: 12,
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.delete,
                              size: 12,
                            ),
                            onPressed: () => _removeDebugItem(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      );

  String processSubtitle(ISocketLogEvent event) {
    final sb = StringBuffer(_shortenString(event.message) ?? '');
    if (event.data != null) {
      sb.write(' / data=[${_shortenString(event.data)}]');
    }
    sb.write('\n at ${timeNumberToStr(event.time.minute)}:${timeNumberToStr(event.time.second)}.');
    sb.write(' Ping=${event.pingMs} ms.');
    return sb.toString();
  }

  String timeNumberToStr(int time) {
    if (time < 10) {
      return '0$time';
    }
    return time.toString();
  }

  String? _shortenString(String? data) {
    const int symbols = 150;
    if (data == null) {
      return null;
    }
    if (data.length <= symbols) {
      return data;
    }
    return data.substring(0, symbols);
  }
} // _SocketBytesDataListenerState
