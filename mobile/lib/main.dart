import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/nordic_theme.dart';
import 'features/share_intent/presentation/controllers/share_intent_controller.dart';
import 'features/share_intent/presentation/widgets/job_clip_preview_sheet.dart';
import 'features/share_intent/services/share_intent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PaniundApp(),
    ),
  );
}

class PaniundApp extends ConsumerStatefulWidget {
  const PaniundApp({super.key});

  @override
  ConsumerState<PaniundApp> createState() => _PaniundAppState();
}

class _PaniundAppState extends ConsumerState<PaniundApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Share Intent listener for incoming LinkedIn / Indeed / Bayt URLs
    ShareIntentService.initialize(
      onJobUrlReceived: (url) {
        ref.read(shareIntentControllerProvider.notifier).handleIncomingUrl(url);
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const JobClipPreviewSheet(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    ShareIntentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'paniund',
      debugShowCheckedModeBanner: false,
      theme: NordicTheme.lightTheme,
      routerConfig: router,
    );
  }
}
