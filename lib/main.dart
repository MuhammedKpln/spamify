import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:spamify/isar/base.db.dart';
import 'package:spamify/isar/local_account.db.dart';
import 'package:spamify/isar/messages.db.dart';
import 'package:spamify/services/di.service.dart';
import 'package:spamify/services/router.service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  initDb([LocalAccountSchema, MessagesDatabaseSchema])
      .then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MacosApp.router(
      title: 'Spamify',
      themeMode: ThemeMode.system,
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      // scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
    );
  }
}
