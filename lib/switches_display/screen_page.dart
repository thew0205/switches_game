import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:switches_game/connection_provider.dart';
import 'package:switches_game/core/colors.dart';

import '../widget/input_form.dart';

class SwitchesScreenPage extends StatefulWidget {
  const SwitchesScreenPage({super.key});

  @override
  State<SwitchesScreenPage> createState() => _SwitchesScreenPageState();
}

class _SwitchesScreenPageState extends State<SwitchesScreenPage> {
  // ignore: unused_field
  StreamSubscription<MapEntry<String, bool>>? _isConnectedStreamSubscription;
  String? serverName;
  bool isFirstTime = true;
  bool joystickControl = true;
  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 2000);
    const animationDuration = Duration(milliseconds: 300);

    serverName = context.read<DisplayConnectionProvider>().server.name;
    _isConnectedStreamSubscription = context
        .read<DisplayConnectionProvider>()
        .IsConnectedStream
        ?.listen((pair) {
      if (pair.key == ConnectionProvider.cannotConnectKey) {
        if (pair.value) {
          showTopSnackBar(
            reverseAnimationDuration: animationDuration,
            animationDuration: animationDuration,
            context,
            displayDuration: duration,
            const CustomSnackBar.error(
              message:
                  "An error occurred while trying to connect. Please try again.",
            ),
          );
          Future.delayed(duration + animationDuration * 3)
              .then((value) => Navigator.of(context).pop());
        }
      } else if (pair.key == ConnectionProvider.isConnectedKey) {
        if (pair.value) {
          showTopSnackBar(
            context,
            CustomSnackBar.success(
              backgroundColor: switchesColor,
              message: "You are connected with $serverName.",
            ),
          );
        } else {
          showTopSnackBar(
            reverseAnimationDuration: animationDuration,
            animationDuration: animationDuration,
            context,
            displayDuration: duration,
            CustomSnackBar.error(
                message:
                    "Something went wrong while connecting with with $serverName. Please try again"),
          );
        }
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map<String, String> dataToSend = {};
  Action currentAction =
      const Action(action: 'a', description: "Append new sentence");
  final _formKey = GlobalKey<FormState>();
  final _textTextEditingController = TextEditingController();
  // String action = 'a';
  String pin = '';
  static const actions = [
    Action(action: 'a', description: "Append new sentence"),
    Action(action: 'i', description: "Insert new sentence"),
    Action(action: 't', description: "Change Update time."),
    Action(action: 'c', description: "Change change a sentence."),
    Action(action: 'd', description: "Delete sentence."),
    Action(action: 'p', description: "Change password."),
    Action(action: 's', description: "Change scroll direction"),
    Action(action: 'f', description: "Change font."),
    Action(action: 'n', description: "Change spacing."),
  ];
  toSend(Map<String, String> dataToBeSent) => dataToSend = dataToBeSent;

  @override
  Widget build(BuildContext context) {
    final actionWidget = {
      'a': AppendPage(
        textEditingController: _textTextEditingController,
        toSend: toSend,
      ),
      'i': InsertSentencePage(
        textEditingController: _textTextEditingController,
        toSend: toSend,
      ),
      'd': DeletePage(
        toSend: toSend,
      ),
      't': SetTimePage(
        toSend: toSend,
      ),
      'c': ChangeSentencePage(
        textEditingController: _textTextEditingController,
        toSend: toSend,
      ),
      'p': SetPinPage(
        toSend: toSend,
      ),
      'f': SetFontPage(
        toSend: toSend,
      ),
      's': SetScrollDirectionPage(
        toSend: toSend,
      ),
      'n': SetSpacingPage(
        toSend: toSend,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Switches Screen"), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
      ]),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Input 4 digit pin"),
                          const SizedBox(height: 10),
                          InputForm(
                            hintText: "Input pin.",
                            onSaved: (value) {
                              pin = value ?? '';
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Choose a command"),
                        const SizedBox(height: 10),
                        DropdownButtonHideUnderline(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: switchesColor),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: DropdownButton<Action>(
                                focusColor: switchesColor,
                                value: currentAction,
                                items: actions
                                    .map((item) => DropdownMenuItem<Action>(
                                          value: item,
                                          child: Text(
                                            item.description,
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      currentAction = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              if (actionWidget[currentAction.action] != null)
                actionWidget[currentAction.action]!,
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // k:1234,c:a,w:matthew
                  _formKey.currentState?.save();
                  String temp = "k: $pin, c: ${currentAction.action}, ";
                  dataToSend.forEach(
                    (key, value) {
                      temp += "$key : $value";
                      temp += ', ';
                    },
                  );
                  print(temp);
                  context.read<DisplayConnectionProvider>().sendData(temp);
                  _textTextEditingController.clear();
                },
                child: const Text("Send Command"),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Action {
  final String action;
  final String description;
  const Action({
    required this.action,
    required this.description,
  });

  @override
  bool operator ==(covariant Action other) {
    if (identical(this, other)) return true;

    return other.action == action && other.description == description;
  }

  @override
  int get hashCode => action.hashCode ^ description.hashCode;
}

class AppendPage extends StatelessWidget {
  const AppendPage({Key? key, required this.toSend, this.textEditingController})
      : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;
  final TextEditingController? textEditingController;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: InputForm(
        textEditingController: textEditingController,
        hintText: "Input sentence to append",
        onSaved: (value) {
          toSend({'w': value ?? ""});
        },
      ),
    );
  }
}

class ChangeSentencePage extends StatefulWidget {
  const ChangeSentencePage(
      {Key? key, required this.toSend, this.textEditingController})
      : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;
  final TextEditingController? textEditingController;

  @override
  State<ChangeSentencePage> createState() => _ChangeSentencePageState();
}

class _ChangeSentencePageState extends State<ChangeSentencePage> {
  String val = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: InputForm(
            hintText: "Input index of sentence to change.",
            keyboardType: TextInputType.number,
            onSaved: (value) {
              val = value ?? "";
              widget.toSend({
                'i': value ?? "",
                'w': widget.textEditingController?.text ?? ""
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: InputForm(
            textEditingController: widget.textEditingController,
            hintText: "Input sentence to change",
            onSaved: (value) {
              widget.toSend({
                'i': val,
                'w': widget.textEditingController?.text ?? "",
              });
            },
          ),
        ),
      ],
    );
  }
}

class InsertSentencePage extends StatefulWidget {
  const InsertSentencePage(
      {Key? key, required this.toSend, this.textEditingController})
      : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;
  final TextEditingController? textEditingController;

  @override
  State<InsertSentencePage> createState() => _InsertSentencePageState();
}

class _InsertSentencePageState extends State<InsertSentencePage> {
  String val = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: InputForm(
            hintText: "Input index of sentence to insert.",
            keyboardType: TextInputType.number,
            onSaved: (value) {
              val = value ?? "";
              widget.toSend({
                'i': value ?? "",
                'w': widget.textEditingController?.text ?? ""
              });
            },
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: InputForm(
            textEditingController: widget.textEditingController,
            hintText: "Input sentence to change",
            onSaved: (value) {
              widget.toSend({
                'i': val,
                'w': widget.textEditingController?.text ?? "",
              });
            },
          ),
        ),
      ],
    );
  }
}

class SetPinPage extends StatelessWidget {
  const SetPinPage({Key? key, required this.toSend}) : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: InputForm(
        hintText: "Input new pin",
        onSaved: (value) {
          toSend({'p': value ?? ""});
        },
      ),
    );
  }
}

class DeletePage extends StatelessWidget {
  const DeletePage({Key? key, required this.toSend}) : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: InputForm(
        hintText: "Input index of sentence to delete.",
        keyboardType: TextInputType.number,
        onSaved: (value) {
          toSend({'i': value ?? ""});
        },
      ),
    );
  }
}

class SetTimePage extends StatelessWidget {
  const SetTimePage({Key? key, required this.toSend}) : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: InputForm(
        hintText: "Input new update time.",
        keyboardType: TextInputType.number,
        onSaved: (value) {
          toSend({'t': value ?? ""});
        },
      ),
    );
  }
}

class SetSpacingPage extends StatelessWidget {
  const SetSpacingPage({Key? key, required this.toSend}) : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: InputForm(
        hintText: "Input new number of spacing.",
        keyboardType: TextInputType.number,
        onSaved: (value) {
          toSend({'n': value ?? ""});
        },
      ),
    );
  }
}

class SetScrollDirectionPage extends StatefulWidget {
  const SetScrollDirectionPage({Key? key, required this.toSend})
      : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;

  @override
  State<SetScrollDirectionPage> createState() => _SetScrollDirectionPageState();
}

class _SetScrollDirectionPageState extends State<SetScrollDirectionPage> {
  int selectedScrollDirection = 0;
  final scrollDirections = {
    0: "Horizontal left",
    2: "Horizontal right",
    3: "Vertical left",
    1: "Vertical right"
  };
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: DropdownButtonHideUnderline(
        child: DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), color: switchesColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<int>(
              focusColor: switchesColor,
              value: selectedScrollDirection,
              items: scrollDirections.entries
                  .map((item) => DropdownMenuItem<int>(
                        value: item.key,
                        child: Text(
                          item.value,
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedScrollDirection = value;
                  });
                  widget.toSend({'s': value.toString()});
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class SetFontPage extends StatefulWidget {
  const SetFontPage({Key? key, required this.toSend}) : super(key: key);
  final void Function(Map<String, String> dataToBeSent) toSend;

  @override
  State<SetFontPage> createState() => _SetFontPageState();
}

class _SetFontPageState extends State<SetFontPage> {
  int selectedFont = 1;
  final fonts = {
    1: "Arial14",
    2: "Arial_Black_16",
    3: "SystemFont5x7",
    4: " Droid_Sans_12"
  };
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: DropdownButtonHideUnderline(
        child: DecoratedBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), color: switchesColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<int>(
              focusColor: switchesColor,
              value: selectedFont,
              items: fonts.entries
                  .map((item) => DropdownMenuItem<int>(
                        value: item.key,
                        child: Text(
                          item.value,
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFont = value;
                  });
                  widget.toSend({'f': value.toString()});
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// class SettingsPage extends StatefulWidget {
//   @override
//   State<SettingsPage> createState() => SettingsPageState();
// }

// class SettingsPageState extends State<SettingsPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isFirstTime = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Settings"),
//       ),
//       body: Form(
//         key: _formKey,
//         child: _isFirstTime
//             ? Center(
//                 child: Column(
//                   children: [
//                     Container(
//                       child: TextFormField(decoration: InputDecoration()),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {},
//                       child: Text("login"),
//                     )
//                   ],
//                 ),
//               )
//             : Center(
//                 child: Column(
//                   children: [
//                     Container(
//                       child: TextFormField(decoration: InputDecoration()),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {},
//                       child: Text("login"),
//                     )
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
