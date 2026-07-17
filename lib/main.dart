import 'dart:io' show Platform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'services/notification_service.dart';
import 'services/review_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'i18n/app_strings.dart';
import 'screens/home_screen.dart';
import 'services/ads_service.dart';
import 'services/audio_service.dart';
import 'services/locale_service.dart';
import 'services/purchase_service.dart';
import 'widgets/remove_ads_offer.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleService().init();
  await PurchaseService.instance.initialize();  if (Platform.isIOS) {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 200));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (_) {}
  }

  AdsService.instance.initialize();
  AudioService().init();
  ReviewService.instance.registerLaunch();
  NotificationService.instance.scheduleDailyReminder(title: 'Solitaire Klondike', body: 'O partidă rapidă de Solitaire? 🃏');
  runApp(const SolitaireApp());
}

class SolitaireApp extends StatefulWidget {
  const SolitaireApp({super.key});

  @override
  State<SolitaireApp> createState() => _SolitaireAppState();
}

class _SolitaireAppState extends State<SolitaireApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Show the upsell right after a full-screen ad (App Open / interstitial) closes.
    AdsService.instance.adClosedTick.addListener(_onAdClosed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AdsService.instance.adClosedTick.removeListener(_onAdClosed);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AdsService.instance.showAppOpenIfReady();
    }
  }

  void _onAdClosed() {
    final ctx = navigatorKey.currentContext;
    if (ctx != null) RemoveAdsOffer.maybeShow(ctx);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleService(),
      builder: (context, _) {
        return MaterialApp(
          title: 'Solitaire',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          locale: LocaleService().locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppStrings.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF1B5E20),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2E7D32),
              brightness: Brightness.dark,
            ),
          ),
          home: UpgradeAlert(child: const HomeScreen()),
        );
      },
    );
  }
}
