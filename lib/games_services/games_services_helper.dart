import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

abstract class GamesServicesHelper {
  static bool get osSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool _signedIn = false;

  static Future<bool> signIn() async {
    if (!osSupported) return _signedIn = false;
    await GamesServices.signIn();
    return _signedIn = await GamesServices.isSignedIn;
  }
}

Future<T?> runAfterGamesSignIn<T>(FutureOr<T> Function() callback) async {
  if (!GamesServicesHelper._signedIn) await GamesServicesHelper.signIn();
  if (!GamesServicesHelper._signedIn) return null;
  return await callback();
}
