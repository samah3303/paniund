import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentService {
  static StreamSubscription? _intentSub;

  static void initialize({required void Function(String url) onJobUrlReceived}) {
    // Native sharing intent is mobile-only (Android/iOS)
    if (kIsWeb) return;

    try {
      // 1. Listen to shared text when app is in memory (warm/foreground)
      _intentSub?.cancel();
      _intentSub = ReceiveSharingIntent.instance.getTextStream().listen(
        (String text) {
          final url = extractUrl(text);
          if (url != null) {
            onJobUrlReceived(url);
          }
        },
        onError: (err) {
          debugPrint("[ShareIntentService] Stream error: $err");
        },
      );

      // 2. Handle shared text when app was launched from scratch (cold boot)
      ReceiveSharingIntent.instance.getInitialText().then((String? text) {
        if (text != null) {
          final url = extractUrl(text);
          if (url != null) {
            onJobUrlReceived(url);
          }
        }
      }).catchError((err) {
        debugPrint("[ShareIntentService] Initial text error: $err");
      });
    } catch (e) {
      debugPrint("[ShareIntentService] Initialization warning: $e");
    }
  }

  static void dispose() {
    _intentSub?.cancel();
    _intentSub = null;
  }

  static String? extractUrl(String text) {
    if (text.isEmpty) return null;

    final urlRegExp = RegExp(
      r'((https?:\/\/)|(www\.))[^\s]+',
      caseSensitive: false,
    );
    final match = urlRegExp.firstMatch(text.trim());
    String? url = match?.group(0);

    if (url != null && url.startsWith("www.")) {
      url = "https://$url";
    }

    return url;
  }
}
