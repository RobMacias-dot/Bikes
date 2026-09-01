import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class BikeExpertApp extends StatelessWidget {
  const BikeExpertApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Bike Expert', // Confirmar nombre antes de publicar.
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
