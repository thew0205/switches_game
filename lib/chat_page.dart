import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import 'connection_provider.dart';
import 'core/colors.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPage createState() => _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static const clientID = 0;
  String? serverName;

  final String _messageBuffer = '';

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  // List<_Message> messages = List<_Message>.empty(growable: true);
  // bool isConnecting = true;
  // bool get isConnected => (connection?.isConnected ?? false);

  // bool isDisconnecting = false;
  @override
  void initState() {
    super.initState();
    serverName = context.read<DisplayConnectionProvider>().server.name;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionProvider = context.watch<DisplayConnectionProvider>();
    final List<Row> list = connectionProvider.messages.map((_message) {
      return Row(
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color: _message.whom == clientID ? switchesColor : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
          title: connectionProvider.isConnecting
              ? Text('Connecting pad to ${serverName ?? "Unknown"} ...')
              : connectionProvider.isConnected
                  ? Text('Connected with ${serverName ?? "Unknown"}')
                  : Text('Connection error with ${serverName ?? "Unknown"}')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: connectionProvider.isConnecting
                            ? 'Wait until connected...'
                            : connectionProvider.isConnected
                                ? 'Type your message...'
                                : 'Chat got disconnected',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: connectionProvider.isConnected,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: connectionProvider.isConnected
                          ? () => _sendMessage(textEditingController.text)
                          : null),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    // text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        bool success = await context
            .read<DisplayConnectionProvider>()
            .sendData(text + "\r\n");
        if (success) {
          Future.delayed(const Duration(milliseconds: 333)).then((_) {
            listScrollController.animateTo(
                listScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 333),
                curve: Curves.easeOut);
          });
        }
      } catch (e) {
        // Ignore error, but notify state

      }
    }
  }
}
