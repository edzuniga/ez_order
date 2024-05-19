import 'package:ez_order_ezr/presentation/config/app_colors.dart';
import 'package:ez_order_ezr/presentation/providers/router_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_strategy/url_strategy.dart';

Future<void> main() async {
  //ensure flutter
  WidgetsFlutterBinding.ensureInitialized();
  //Set preferred orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await dotenv.load(fileName: 'assets/dotENV.env');
  //Supabase initialize
  await Supabase.initialize(
    url: dotenv.env['URL'].toString(),
    anonKey: dotenv.env['ANONKEY'].toString(),
  );
  setPathUrlStrategy();
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EZOrder',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: AppColors.kGeneralPrimaryOrange),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
