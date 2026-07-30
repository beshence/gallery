import 'dart:convert';
import 'dart:ui';

import 'package:beshence_sdk_flutter/beshence_sdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _showCodeDialog = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double dialogWidth = screenWidth > 600 ? 560.0 : screenWidth * 0.85;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("Beshence Gallery"),
          ),
          body: SizedBox.expand(),
        ),
        Container(
          color: Colors.black54,
          width: double.infinity,
          height: double.infinity,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: (!_showCodeDialog)
                ? WelcomeMainDialog(
                dialogWidth: dialogWidth,
                onContinue: () => setState(() {
                  _showCodeDialog = true;
                })
            )
                : WelcomeCodeDialog(
              dialogWidth: dialogWidth,
              onBack: () => setState(() {
                _showCodeDialog = false;
              }),
            )
        ),
      ],
    );
  }
}

class WelcomeMainDialog extends StatelessWidget {
  final double dialogWidth;
  final void Function() onContinue;

  const WelcomeMainDialog({super.key, required this.dialogWidth, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: BoxConstraints(maxWidth: dialogWidth),
      title: Text('Welcome to Beshence Gallery!',),
      content: Text(
        'To get started, register new Beshence Account or log in to existing one.', style: Theme.of(context).textTheme.bodyLarge,),
      actionsOverflowButtonSpacing: 8.0,
      actionsAlignment: .spaceBetween,
      icon: Icon(Icons.landscape_outlined, size: 36,),
      actionsOverflowDirection: .up,
      actions: [
        TextButton(
          onPressed: () {} /*=> showModalBottomSheet<void>(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => OfflineModal()
                )*/,
          child: const Text('Other options'),
        ),
        FilledButton(
          onPressed: () async {
            final Uri url = Uri.parse('https://account.beshence.com/#/oauth/authorize?'
                'client_id=com.beshence.gallery&'
                'response_type=base64account&'
                'scope=chain:main:r;chain:gallery:rw');
            onContinue();
            if (!await launchUrl(url)) {
              throw Exception('Could not launch $url');
            }
          },
          child: const Text('Register / Log in'),
        ),
      ],
    );
  }
}

class WelcomeCodeDialog extends StatefulWidget {
  final double dialogWidth;
  final void Function() onBack;

  const WelcomeCodeDialog({super.key, required this.dialogWidth, required this.onBack});

  @override
  State<StatefulWidget> createState() => _WelcomeCodeDialogState();

}

class _WelcomeCodeDialogState extends State<WelcomeCodeDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        constraints: BoxConstraints(maxWidth: widget.dialogWidth),
        title: Text('Provide the code',),
        content: Column(
          mainAxisSize: .min,
          children: [
            Text('You\'ve been redirected to Beshence '
                'Account Manager to create code. Copy '
                'it and then paste it down below.',
              style: Theme.of(context).textTheme.bodyLarge,),
            TextField(
              controller: _controller,
              onSubmitted: (value) async => await login(context, value),
            )
          ],
        ),
        actionsOverflowButtonSpacing: 8.0,
        actionsAlignment: .spaceBetween,
        icon: Icon(Icons.landscape_outlined, size: 36,),
        actionsOverflowDirection: .up,
        actions: [
          TextButton(
            onPressed: () => widget.onBack(),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () async => await login(context, _controller.text),
            child: const Text('Log in'),
          ),
        ]
    );
  }
}

Future<void> login(BuildContext context, String value) async {
  var json = jsonDecode(utf8.decode(base64Decode(value)));

  String tid = json["tid"];
  String aid = json["aid"];
  List<Map<String, dynamic>> vs = List<Map<String, dynamic>>.from(json["vs"]);

  BeshenceAccount account = await Beshence.createAccount(id: aid, oauthTokenId: tid, initAccountEvent: false);
  for (Map<String, dynamic> v in vs) {
    account.addVault(bankId: v["b"], vaultId: v["i"], priority: v["p"], addVaultEvent: false);
  }
  account.createChain("main");
  account.createChain("notes");
  BeshenceDaemon.of(account).startDaemon();
  context.go("/");
}

/*class OfflineModal extends StatelessWidget {
  const OfflineModal({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Continue offline?", style: TextTheme.of(context).headlineLarge,),
                SizedBox(height: 8,),
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  titleAlignment: ListTileTitleAlignment.top,
                  leading: Icon(Icons.cloud_off),
                  title: RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(text: "We'll create an "),
                            TextSpan(text: "offline Beshence Account", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ". It's the same Account but it will be available "),
                            TextSpan(text: "only in this app", style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline,)),
                            TextSpan(text: ", not in any else, and it won't be backed up to any Beshence Vaults."),
                          ]
                      )
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  titleAlignment: ListTileTitleAlignment.top,
                  leading: Icon(Icons.heart_broken_outlined),
                  title: RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(text: "In case of device breaking, accidental data removal (common in web browsers) or malicious attack "),
                            TextSpan(text: "you won't be able to restore your data", style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "."),
                          ]
                      )
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.all(0),
                  titleAlignment: ListTileTitleAlignment.top,
                  leading: Icon(Icons.dataset_outlined),
                  title: RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.bodyLarge,
                          children: [
                            TextSpan(text: "You will be able to make this Account online by connecting it to at least one Vault."),
                          ]
                      )
                  ),
                ),
                SizedBox(height: 8,),
                OverflowBar(
                    alignment: .spaceBetween,
                    overflowAlignment: .end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Continue'),
                      )
                    ]
                )
              ],
            ),
          ),
        )
    );
  }
}*/