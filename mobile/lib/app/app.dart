import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_constants.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class BiciFirmeApp extends StatelessWidget {
  const BiciFirmeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: AppConstants.visibleName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: router,
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
}
