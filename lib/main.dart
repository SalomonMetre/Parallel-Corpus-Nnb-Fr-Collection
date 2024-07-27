import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:transcollect_nnb_fr_hub/firebase_options.dart';
import 'package:transcollect_nnb_fr_hub/routes.dart';
import 'package:transcollect_nnb_fr_hub/screens/sentences.dart';
import 'package:transcollect_nnb_fr_hub/styling/theme.dart';
import 'package:provider/provider.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => SentenceProvider(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: appThemeData,
        routerConfig: router,
      ),
    ),
  );
}
