import 'package:flutter/material.dart';

import '../switches_custom_loading_indicator.dart';

const switchesIndicator = Positioned.fill(
  child: ColoredBox(
    color: Colors.black38,
    child: Center(
      child: SwitchesLoadingIndicator(
        size: 150,
      ),
    ),
  ),
);

final switchesIndicator1 = Positioned.fill(
  child: ColoredBox(
    color: Colors.black38,
    child: Center(
      child: AlertDialog(
        content: Column(children: [
          const Text("Game is paused"),
          IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow)),
        ]),
      ),
    ),
  ),
);
