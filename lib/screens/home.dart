import 'package:beshence_sdk_flutter/beshence_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Beshence Gallery"),
            actionsPadding: .only(right: 8),
            actions: [
              Beshence.selectedAccount!.avatarButton(
                  onPressed: () => BeshenceWidgets.showAccountChooserModal(
                      context: context,
                      children: [
                        BeshenceWidgets.accountChooserTile(
                            title: "Beshence Gallery settings",
                            leading: Icon(Icons.settings),
                            onTap: () => context.push("/settings")
                        ),
                      ]
                  )
              ),
            ]
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          left: true,
          right: true,
          child: SizedBox(),
        )
    );
  }

  @override
  void initState() {
    BeshenceDaemon.of(Beshence.selectedAccount!).startDaemon();
    super.initState();
  }
}