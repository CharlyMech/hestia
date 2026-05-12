import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get common_viewAll;

  /// No description provided for @common_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get common_seeAll;

  /// No description provided for @common_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get common_signOut;

  /// No description provided for @nav_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_dashboard;

  /// No description provided for @nav_calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get nav_calendar;

  /// No description provided for @nav_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get nav_shopping;

  /// No description provided for @nav_accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get nav_accounts;

  /// No description provided for @nav_pets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get nav_pets;

  /// No description provided for @nav_cars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get nav_cars;

  /// No description provided for @settings_carsModule.
  ///
  /// In en, this message translates to:
  /// **'Cars tracking'**
  String get settings_carsModule;

  /// No description provided for @settings_carsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get settings_carsTitle;

  /// No description provided for @settings_carsSub.
  ///
  /// In en, this message translates to:
  /// **'Cars and fill-ups'**
  String get settings_carsSub;

  /// No description provided for @settings_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_general;

  /// No description provided for @settings_modules.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get settings_modules;

  /// No description provided for @settings_dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get settings_dataManagement;

  /// No description provided for @settings_categoriesTab.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settings_categoriesTab;

  /// No description provided for @settings_sourcesTab.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get settings_sourcesTab;

  /// No description provided for @settings_dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get settings_dateFormat;

  /// No description provided for @settings_dateFormatMdy.
  ///
  /// In en, this message translates to:
  /// **'MM/DD/YYYY'**
  String get settings_dateFormatMdy;

  /// No description provided for @settings_dateFormatDmy.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get settings_dateFormatDmy;

  /// No description provided for @settings_dateFormatYmd.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get settings_dateFormatYmd;

  /// No description provided for @settings_allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get settings_allowLocation;

  /// No description provided for @settings_allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get settings_allowNotifications;

  /// No description provided for @settings_faceIdUnlock.
  ///
  /// In en, this message translates to:
  /// **'Face ID unlock'**
  String get settings_faceIdUnlock;

  /// No description provided for @settings_viewCarsData.
  ///
  /// In en, this message translates to:
  /// **'View cars data'**
  String get settings_viewCarsData;

  /// No description provided for @profile_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get profile_edit;

  /// No description provided for @notifications_unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notifications_unread;

  /// No description provided for @notifications_read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notifications_read;

  /// No description provided for @notifications_showRead.
  ///
  /// In en, this message translates to:
  /// **'Show read'**
  String get notifications_showRead;

  /// No description provided for @notifications_hideRead.
  ///
  /// In en, this message translates to:
  /// **'Hide read'**
  String get notifications_hideRead;

  /// No description provided for @cars_title.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get cars_title;

  /// No description provided for @cars_analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Car analytics'**
  String get cars_analyticsTitle;

  /// No description provided for @cars_fuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel type'**
  String get cars_fuelType;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settings_appearance;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_themeDark;

  /// No description provided for @settings_themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_themeSystem;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settings_languageEn;

  /// No description provided for @settings_languageEs.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get settings_languageEs;

  /// No description provided for @settings_startDay.
  ///
  /// In en, this message translates to:
  /// **'First day of week'**
  String get settings_startDay;

  /// No description provided for @settings_use24h.
  ///
  /// In en, this message translates to:
  /// **'24-hour clock'**
  String get settings_use24h;

  /// No description provided for @settings_biometric.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get settings_biometric;

  /// No description provided for @dashboard_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboard_overview;

  /// No description provided for @dashboard_greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get dashboard_greetingMorning;

  /// No description provided for @dashboard_greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get dashboard_greetingAfternoon;

  /// No description provided for @dashboard_greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get dashboard_greetingEvening;

  /// No description provided for @dashboard_accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get dashboard_accounts;

  /// No description provided for @dashboard_spending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get dashboard_spending;

  /// No description provided for @dashboard_activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active goals'**
  String get dashboard_activeGoals;

  /// No description provided for @dashboard_recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get dashboard_recent;

  /// No description provided for @dashboard_balanceTrend.
  ///
  /// In en, this message translates to:
  /// **'Balance trend'**
  String get dashboard_balanceTrend;

  /// No description provided for @dashboard_monthlyNet.
  ///
  /// In en, this message translates to:
  /// **'Monthly net'**
  String get dashboard_monthlyNet;

  /// No description provided for @bankAccounts_title.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get bankAccounts_title;

  /// No description provided for @bankAccounts_totalNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Total net worth'**
  String get bankAccounts_totalNetWorth;

  /// No description provided for @bankAccounts_addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get bankAccounts_addCard;

  /// No description provided for @bankAccounts_shared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get bankAccounts_shared;

  /// No description provided for @bankAccounts_personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get bankAccounts_personal;

  /// No description provided for @bankAccounts_noInstitution.
  ///
  /// In en, this message translates to:
  /// **'No institution'**
  String get bankAccounts_noInstitution;

  /// No description provided for @goals_title.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals_title;

  /// No description provided for @goals_addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get goals_addGoal;

  /// No description provided for @goals_global.
  ///
  /// In en, this message translates to:
  /// **'All goals'**
  String get goals_global;

  /// No description provided for @goals_perAccount.
  ///
  /// In en, this message translates to:
  /// **'Goals on this account'**
  String get goals_perAccount;

  /// No description provided for @calendar_title.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar_title;

  /// No description provided for @calendar_newAppointment.
  ///
  /// In en, this message translates to:
  /// **'New appointment'**
  String get calendar_newAppointment;

  /// No description provided for @calendar_appointment.
  ///
  /// In en, this message translates to:
  /// **'Appointment'**
  String get calendar_appointment;

  /// No description provided for @calendar_filterAll.
  ///
  /// In en, this message translates to:
  /// **'Show all members'**
  String get calendar_filterAll;

  /// No description provided for @calendar_filterMine.
  ///
  /// In en, this message translates to:
  /// **'Only mine'**
  String get calendar_filterMine;

  /// No description provided for @calendar_eventos.
  ///
  /// In en, this message translates to:
  /// **'Eventos'**
  String get calendar_eventos;

  /// No description provided for @calendar_movimientos.
  ///
  /// In en, this message translates to:
  /// **'Movimientos'**
  String get calendar_movimientos;

  /// No description provided for @shopping_title.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping_title;

  /// No description provided for @shopping_sessionsTab.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get shopping_sessionsTab;

  /// No description provided for @shopping_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get shopping_active;

  /// No description provided for @shopping_templatesTab.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get shopping_templatesTab;

  /// No description provided for @shopping_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get shopping_history;

  /// No description provided for @shopping_newList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get shopping_newList;

  /// No description provided for @shopping_finishAndPay.
  ///
  /// In en, this message translates to:
  /// **'Finish & Pay'**
  String get shopping_finishAndPay;

  /// No description provided for @shopping_cancelList.
  ///
  /// In en, this message translates to:
  /// **'Cancel list'**
  String get shopping_cancelList;

  /// No description provided for @shopping_cancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this shopping list?'**
  String get shopping_cancelConfirmTitle;

  /// No description provided for @shopping_cancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The list will be archived as cancelled and cannot be edited.'**
  String get shopping_cancelConfirmBody;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifications_markAllRead;

  /// No description provided for @notifications_showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get notifications_showAll;

  /// No description provided for @notifications_empty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifications_empty;

  /// No description provided for @notifications_markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get notifications_markRead;

  /// No description provided for @notifications_markUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get notifications_markUnread;

  /// No description provided for @transaction_new.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get transaction_new;

  /// No description provided for @transactionLocation_mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick location'**
  String get transactionLocation_mapTitle;

  /// No description provided for @transactionLocation_statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Location insights'**
  String get transactionLocation_statsTitle;

  /// No description provided for @transactionLocation_statsCount.
  ///
  /// In en, this message translates to:
  /// **'geo-tagged pins'**
  String get transactionLocation_statsCount;

  /// No description provided for @transactionLocation_empty.
  ///
  /// In en, this message translates to:
  /// **'No transactions with a location yet.'**
  String get transactionLocation_empty;

  /// No description provided for @settings_locationSection.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settings_locationSection;

  /// No description provided for @settings_locationStats.
  ///
  /// In en, this message translates to:
  /// **'Map & pins'**
  String get settings_locationStats;

  /// No description provided for @settings_locationStatsSub.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions saved with GPS'**
  String get settings_locationStatsSub;

  /// No description provided for @settings_locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get settings_locationPermission;

  /// No description provided for @settings_locationRequest.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get settings_locationRequest;

  /// No description provided for @settings_locationOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get settings_locationOpenSettings;

  /// No description provided for @settings_locationPermGranted.
  ///
  /// In en, this message translates to:
  /// **'Allowed while using the app'**
  String get settings_locationPermGranted;

  /// No description provided for @settings_locationPermDenied.
  ///
  /// In en, this message translates to:
  /// **'Denied — tap Request access'**
  String get settings_locationPermDenied;

  /// No description provided for @settings_locationPermForever.
  ///
  /// In en, this message translates to:
  /// **'Blocked — enable in system Settings'**
  String get settings_locationPermForever;

  /// No description provided for @settings_locationPermSvcOff.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off'**
  String get settings_locationPermSvcOff;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
