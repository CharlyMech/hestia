import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/notifications/notifications_bloc.dart';

import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'core/constants/themes.dart';
import 'core/utils/theme_utils.dart';
import 'data/local/drift/app_database.dart';
import 'presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'presentation/blocs/view_mode/view_mode_bloc.dart';

class HestiaApp extends StatelessWidget {
  final AppDatabase database;

  const HestiaApp({
    super.key,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    final deps = AppDependencies.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ViewModeBloc()),
        BlocProvider(
          create: (_) =>
              AuthBloc(deps.authRepository)..add(const AuthCheckSession()),
        ),
        BlocProvider(
          create: (_) => UserPrefsBloc(deps.userPreferencesService)
            ..add(const UserPrefsLoad()),
        ),
        BlocProvider(
          create: (_) => NotificationsBloc(deps.notificationRepository),
        ),
      ],
      child: BlocBuilder<UserPrefsBloc, UserPrefsState>(
        builder: (context, prefs) {
          final systemBrightness = MediaQuery.platformBrightnessOf(context);
          final myTheme = resolveTheme(
            prefs.themeType,
            systemBrightness: systemBrightness,
          );
          final brightness = prefs.themeType == ThemeType.system
              ? systemBrightness
              : (prefs.themeType == ThemeType.light
                  ? Brightness.light
                  : Brightness.dark);
          return InheritedMyTheme(
            theme: myTheme,
            child: FTheme(
              data: buildForuiTheme(myTheme, brightness: brightness),
              child: CupertinoApp.router(
                title: 'Hestia',
                theme: buildCupertinoTheme(myTheme, brightness: brightness),
                routerConfig: appRouter,
                locale: Locale(prefs.languageCode),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const <LocalizationsDelegate<Object>>[
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback: (deviceLocale, supported) {
                  // Honor explicit user pick when set; else fall back to
                  // device locale if supported, else 'en'.
                  if (prefs.languageCode.isNotEmpty &&
                      supported.any((l) => l.languageCode == prefs.languageCode)) {
                    return Locale(prefs.languageCode);
                  }
                  if (deviceLocale != null &&
                      supported.any(
                          (l) => l.languageCode == deviceLocale.languageCode)) {
                    return Locale(deviceLocale.languageCode);
                  }
                  return const Locale('en');
                },
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
