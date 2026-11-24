import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ShareIntentService {
  static StreamSubscription? _intentSub;

  static void initialize({required void Function(String url) onJobUrlReceived}) {
    // Native sharing intent is mobile-only (Android/iOS)
    if (kIsWeb) return;

    try {
      // 1. Listen to shared text/media when app is in memory (warm/foreground)
      _intentSub?.cancel();
      _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> value) {
          for (final file in value) {
            final url = extractUrl(file.path) ?? (file.message != null ? extractUrl(file.message!) : null);
            if (url != null) {
              onJobUrlReceived(url);
              break;
            }
          }
        },
        onError: (err) {
          debugPrint("[ShareIntentService] Stream error: $err");
        },
      );

      // 2. Handle shared text/media when app was launched from scratch (cold boot)
      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
        for (final file in value) {
          final url = extractUrl(file.path) ?? (file.message != null ? extractUrl(file.message!) : null);
          if (url != null) {
            onJobUrlReceived(url);
            break;
          }
        }
        ReceiveSharingIntent.instance.reset();
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
