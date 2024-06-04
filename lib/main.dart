import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dtpocketfm/firebase_options.dart';
import 'package:dtpocketfm/pages/musicdetails.dart';
import 'package:dtpocketfm/pages/splash.dart';
import 'package:dtpocketfm/provider/audiosectiondataprovider.dart';
import 'package:dtpocketfm/provider/avatarprovider.dart';
import 'package:dtpocketfm/provider/channelsectionprovider.dart';
import 'package:dtpocketfm/provider/musicdetailprovider.dart';
import 'package:dtpocketfm/provider/musicprovider.dart';
import 'package:dtpocketfm/provider/notificationprovider.dart';
import 'package:dtpocketfm/provider/novelsectiondataprovider.dart';
import 'package:dtpocketfm/provider/rewardprovider.dart';
import 'package:dtpocketfm/provider/seallprovider.dart';
import 'package:dtpocketfm/provider/threadprovider.dart';
import 'package:dtpocketfm/provider/episodeprovider.dart';
import 'package:dtpocketfm/provider/findprovider.dart';
import 'package:dtpocketfm/provider/generalprovider.dart';
import 'package:dtpocketfm/provider/homeprovider.dart';
import 'package:dtpocketfm/provider/paymentprovider.dart';
import 'package:dtpocketfm/provider/playerprovider.dart';
import 'package:dtpocketfm/provider/profileprovider.dart';
import 'package:dtpocketfm/provider/searchprovider.dart';
import 'package:dtpocketfm/provider/sectiondataprovider.dart';
import 'package:dtpocketfm/provider/showdetailsprovider.dart';
import 'package:dtpocketfm/provider/subscriptionprovider.dart';
import 'package:dtpocketfm/provider/videobyidprovider.dart';
import 'package:dtpocketfm/provider/videodetailsprovider.dart';
import 'package:dtpocketfm/provider/watchlistprovider.dart';
import 'package:dtpocketfm/tvpages/webhome.dart';
import 'package:dtpocketfm/utils/color.dart';
import 'package:dtpocketfm/utils/constant.dart';
import 'package:dtpocketfm/utils/musicmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Locales.init([
    'en',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'hi',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);

  if (!kIsWeb) {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    // Initialize OneSignal
    OneSignal.initialize(Constant.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);
    OneSignal.Notifications.addPermissionObserver((state) {
      debugPrint("Has permission ==> $state");
    });
    OneSignal.User.pushSubscription.addObserver((state) {
      debugPrint(
          "pushSubscription state ==> ${state.current.jsonRepresentation()}");
    });
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      /// preventDefault to not display the notification
      event.preventDefault();
      // Do async work
      /// notification.display() to display after preventing default
      event.notification.display();
    });
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => ChannelSectionProvider()),
        ChangeNotifierProvider(create: (_) => EpisodeProvider()),
        ChangeNotifierProvider(create: (_) => FindProvider()),
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SectionDataProvider()),
        ChangeNotifierProvider(create: (_) => ShowDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => VideoByIDProvider()),
        ChangeNotifierProvider(create: (_) => VideoDetailsProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => AudioSectionDataProvider()),
        ChangeNotifierProvider(create: (_) => NovelSectionDataProvider()),
        ChangeNotifierProvider(create: (_) => ThreadProvider()),
        ChangeNotifierProvider(create: (_) => SeeAllProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
      ],
      child: const MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    // if (!kIsWeb) Utils.enableScreenCapture();
    if (!kIsWeb) _getDeviceInfo();
    musicManager = MusicManager(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: LocaleBuilder(
        builder: (locale) => MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          navigatorObservers: [routeObserver],
          theme: ThemeData(
            primaryColor: colorPrimary,
            primaryColorDark: colorPrimaryDark,
            primaryColorLight: primaryLight,
            scaffoldBackgroundColor: appBgColor,
          ).copyWith(
            scrollbarTheme: const ScrollbarThemeData().copyWith(
              thumbColor: WidgetStateProperty.all(white),
              trackVisibility: WidgetStateProperty.all(true),
              trackColor: WidgetStateProperty.all(whiteTransparent),
            ),
          ),
          title: Constant.appName,
          localizationsDelegates: Locales.delegates,
          supportedLocales: Locales.supportedLocales,
          locale: locale,
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
            return locale;
          },
          builder: (context, child) {
            return ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 360, name: MOBILE),
                const Breakpoint(start: 361, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1000, name: DESKTOP),
                const Breakpoint(start: 1001, end: double.infinity, name: '4K'),
              ],
            );
          },
          home: (kIsWeb)
              ? const WebHome(
                  pageName: 'home',
                )
              : const Splash(),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
              PointerDeviceKind.trackpad
            },
          ),
        ),
      ),
    );
  }

  _getDeviceInfo() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Constant.isTV =
          androidInfo.systemFeatures.contains('android.software.leanback');
      debugPrint("isTV =======================> ${Constant.isTV}");
    }
  }
}
