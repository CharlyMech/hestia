import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:hestia/core/config/dependencies.dart';
import 'package:hestia/presentation/blocs/auth/auth_bloc.dart';
import 'package:hestia/presentation/blocs/auth/auth_events.dart';

import 'core/config/router.dart';
import 'core/config/theme.dart';
import 'core/constants/themes.dart';
import 'core/utils/theme_utils.dart';
import 'data/local/drift/app_database.dart';
import 'presentation/blocs/view_mode/view_mode_bloc.dart';

class HestiaApp extends StatelessWidget {
  final AppDatabase database;

  const HestiaApp({
    super.key,
    required this.database,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: drive ThemeType from a ThemeBloc/user preference
    const themeType = ThemeType.dark;
    const brightness = Brightness.dark;
    final myTheme = themes[themeType]!;

    final deps = AppDependencies.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ViewModeBloc()),
        BlocProvider(
          create: (_) =>
              AuthBloc(deps.authRepository)..add(const AuthCheckSession()),
        ),
        // Add other global blocs here as you build them:
        // BlocProvider(create: (_) => AuthBloc(...)),
        // BlocProvider(create: (_) => NotificationsBloc(...)),
      ],
      child: InheritedMyTheme(
        theme: myTheme,
        child: FTheme(
          data: buildForuiTheme(myTheme, brightness: brightness),
          child: CupertinoApp.router(
            title: 'Hestia',
            theme: buildCupertinoTheme(myTheme, brightness: brightness),
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
