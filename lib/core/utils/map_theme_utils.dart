import 'package:flutter/widgets.dart';
import 'package:hestia/core/utils/theme_utils.dart';

const _kCartoLight =
    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
const _kCartoDark =
    'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}{r}.png';

const _kCartoSubdomains = ['a', 'b', 'c', 'd'];

/// CARTO tile URL matching the current app theme (light → Voyager, dark → Dark Matter).
String mapTileUrl(BuildContext context) =>
    context.myTheme.isDark ? _kCartoDark : _kCartoLight;

/// Same without a [BuildContext], for cases where [isDark] is already known.
String mapTileUrlForDark(bool isDark) =>
    isDark ? _kCartoDark : _kCartoLight;

/// Subdomains for CARTO tile load-balancing.
List<String> get mapTileSubdomains => _kCartoSubdomains;
