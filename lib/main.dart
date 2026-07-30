import 'package:beshence_sdk_flutter/beshence_sdk_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:gallery/router.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/adapters.dart';

Future<void> main() async {
  await Hive.initFlutter();
  //Hive.registerAdapters();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  BeshenceEventRegistry registry = BeshenceEventRegistry();
  await Beshence.init(registry: registry);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      final lightColorScheme = lightDynamic?.harmonized() ??
          ColorScheme.fromSeed(
              seedColor: Colors.lightGreen,
              brightness: Brightness.light
          );
      final darkColorScheme = darkDynamic?.harmonized() ??
          ColorScheme.fromSeed(
            seedColor: Colors.lightGreen,
            brightness: Brightness.dark,
          );

      return MaterialApp.router(
          routerConfig: router,
          title: 'Beshence Gallery',
          theme: ThemeData(
            colorScheme: lightColorScheme,
            appBarTheme: AppBarTheme(backgroundColor: lightColorScheme.surface),
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            appBarTheme: AppBarTheme(backgroundColor: darkColorScheme.surface),
          ),
          themeMode: ThemeMode.system
      );
    });
  }
}