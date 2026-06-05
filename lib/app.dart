import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/l10n/generated/app_localizations.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';
import 'package:hestia/presentation/blocs/auth/auth_state.dart';
import 'package:hestia/presentation/blocs/app_update/app_update_cubit.dart';
import 'package:hestia/presentation/blocs/map/map_bloc.dart';
import 'package:hestia/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:hestia/presentation/widgets/common/app_update_dialog.dart';

import 'core/config/crashlytics.dart';
import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'core/constants/themes.dart';
import 'core/utils/theme_utils.dart';
import 'data/local/drift/app_database.dart';
import 'presentation/blocs/user_prefs/user_prefs_bloc.dart';
import 'presentation/blocs/view_mode/view_mode_bloc.dart';

class HestiaApp extends StatefulWidget {
  final AppDatabase database;

  const HestiaApp({super.key, required this.database});

  @override
  State<HestiaApp> createState() => _HestiaAppState();
}

class _HestiaAppState extends State<HestiaApp> {
  @override
  void initState() {
    super.initState();
    // Let the router redirect know whether onboarding was already completed.
    routerOnboardingSeen =
        AppDependencies.instance.userPreferencesService.onboardingSeen;
  }

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
        BlocProvider(
          create: (_) => AppUpdateCubit(deps.appVersionRepository),
        ),
        BlocProvider(
          create: (_) => MapBloc(
            householdRepository: deps.householdRepository,
            homeRepository: deps.homeRepository,
            transactionRepository: deps.transactionRepository,
            transactionSourceRepository: deps.transactionSourceRepository,
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                current is AuthAuthenticated || current is AuthUnauthenticated,
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                authStatusListenable.value = true;
                setCrashlyticsUser(state.profile.id);
                deps.pushNotificationService
                    .initialize(userId: state.profile.id);
                context.read<AppUpdateCubit>().checkForUpdates();
                // Preload map data so the dashboard preview and the full map
                // share the same source from app start.
                context.read<MapBloc>().add(MapLoad(state.profile.id));
              } else if (state is AuthUnauthenticated) {
                authStatusListenable.value = false;
                setCrashlyticsUser(null);
                deps.pushNotificationService.onSignOut();
              }
            },
          ),
          BlocListener<AppUpdateCubit, AppUpdateState>(
            listenWhen: (previous, current) =>
                current.hasUpdate && !current.dialogShown,
            listener: (context, state) {
              final latest = state.latest;
              if (latest == null) return;
              context.read<AppUpdateCubit>().markDialogShown();
              showAppUpdateDialog(context, latest);
            },
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
                    if (prefs.languageCode.isNotEmpty &&
                        supported
                            .any((l) => l.languageCode == prefs.languageCode)) {
                      return Locale(prefs.languageCode);
                    }
                    if (deviceLocale != null &&
                        supported.any((l) =>
                            l.languageCode == deviceLocale.languageCode)) {
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
      ),
    );
  }
}
