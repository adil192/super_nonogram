import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

abstract class GamesServicesHelper {
  static bool get osSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
}

Future<T?> runAfterGamesSignIn<T>(FutureOr<T> Function() callback) async {
  await GamesServices.signIn();
  if (!await GamesServices.isSignedIn) return null;
  return await callback();
}
