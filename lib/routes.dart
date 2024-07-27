import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transcollect_nnb_fr_hub/data/models/auth.dart';
import 'package:transcollect_nnb_fr_hub/screens/home.dart';
import 'package:transcollect_nnb_fr_hub/screens/sentences.dart';

final router = GoRouter(routes: <RouteBase>[
  GoRoute(
    path: '/',
    name: 'home',
    builder: (context, state) {
      if(FirebaseAuth.instance.currentUser == null){
        Auth().signIn().then((result) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 5),
          content: Text(result, style: const TextStyle(color: Colors.white),),
          action: SnackBarAction(
            onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
            label: 'Close',
          ),
        ));
      });
      }
      return const HomePage();
    },
  ),
  GoRoute(
    path: '/sentences',
    name: 'sentences',
    builder: (context, state){
      return SentenceListScreen();
    }
  ),
]);
