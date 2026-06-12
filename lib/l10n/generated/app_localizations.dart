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

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

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

  /// No description provided for @auth_signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed'**
  String get auth_signInFailed;

  /// No description provided for @auth_tagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your household finances together'**
  String get auth_tagline;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get auth_showPassword;

  /// No description provided for @auth_signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_signIn;

  /// No description provided for @auth_or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get auth_or;

  /// No description provided for @auth_signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get auth_signInWithApple;

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

  /// No description provided for @profile_setInactive.
  ///
  /// In en, this message translates to:
  /// **'Set inactive'**
  String get profile_setInactive;

  /// No description provided for @profile_setActive.
  ///
  /// In en, this message translates to:
  /// **'Set active'**
  String get profile_setActive;

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

  /// No description provided for @cars_noVehiclesYet.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet'**
  String get cars_noVehiclesYet;

  /// No description provided for @cars_tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add one'**
  String get cars_tapToAdd;

  /// No description provided for @cars_statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cars_statusActive;

  /// No description provided for @cars_statusSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get cars_statusSold;

  /// No description provided for @cars_statusScrap.
  ///
  /// In en, this message translates to:
  /// **'Scrap'**
  String get cars_statusScrap;

  /// No description provided for @cars_odometerKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String cars_odometerKm(String km);

  /// No description provided for @cars_carTitle.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get cars_carTitle;

  /// No description provided for @cars_notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get cars_notFound;

  /// No description provided for @cars_deleteCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete car'**
  String get cars_deleteCarTitle;

  /// No description provided for @cars_deleteCarConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}? This cannot be undone.'**
  String cars_deleteCarConfirm(String name);

  /// No description provided for @cars_statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get cars_statusInactive;

  /// No description provided for @cars_setInactive.
  ///
  /// In en, this message translates to:
  /// **'Set inactive'**
  String get cars_setInactive;

  /// No description provided for @cars_setActive.
  ///
  /// In en, this message translates to:
  /// **'Set active'**
  String get cars_setActive;

  /// No description provided for @cars_addFillUp.
  ///
  /// In en, this message translates to:
  /// **'Add fill-up'**
  String get cars_addFillUp;

  /// No description provided for @cars_recentFillUps.
  ///
  /// In en, this message translates to:
  /// **'Recent fill-ups'**
  String get cars_recentFillUps;

  /// No description provided for @cars_seeAnalytics.
  ///
  /// In en, this message translates to:
  /// **'See analytics'**
  String get cars_seeAnalytics;

  /// No description provided for @cars_noFillUpsYet.
  ///
  /// In en, this message translates to:
  /// **'No fill-ups yet'**
  String get cars_noFillUpsYet;

  /// No description provided for @cars_fillUpFullSuffix.
  ///
  /// In en, this message translates to:
  /// **' · full'**
  String get cars_fillUpFullSuffix;

  /// No description provided for @cars_fillUpLine.
  ///
  /// In en, this message translates to:
  /// **'{liters} L · {pricePerLiter} €/L{fullSuffix}'**
  String cars_fillUpLine(
      String liters, String pricePerLiter, String fullSuffix);

  /// No description provided for @cars_fillUpMeta.
  ///
  /// In en, this message translates to:
  /// **'{date} · {odometer} km'**
  String cars_fillUpMeta(String date, String odometer);

  /// No description provided for @cars_amountEuro.
  ///
  /// In en, this message translates to:
  /// **'{amount} €'**
  String cars_amountEuro(String amount);

  /// No description provided for @pets_noPetsYet.
  ///
  /// In en, this message translates to:
  /// **'No pets yet'**
  String get pets_noPetsYet;

  /// No description provided for @pets_tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add one'**
  String get pets_tapToAdd;

  /// No description provided for @pets_speciesDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get pets_speciesDog;

  /// No description provided for @pets_speciesCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get pets_speciesCat;

  /// No description provided for @pets_speciesBird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get pets_speciesBird;

  /// No description provided for @pets_speciesRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get pets_speciesRabbit;

  /// No description provided for @pets_speciesFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get pets_speciesFish;

  /// No description provided for @pets_speciesReptile.
  ///
  /// In en, this message translates to:
  /// **'Reptile'**
  String get pets_speciesReptile;

  /// No description provided for @pets_speciesOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pets_speciesOther;

  /// No description provided for @pets_ageYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 yr} other{{count} yrs}}'**
  String pets_ageYears(int count);

  /// No description provided for @pets_genderMale.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get pets_genderMale;

  /// No description provided for @pets_genderFemale.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get pets_genderFemale;

  /// No description provided for @pets_title.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get pets_title;

  /// No description provided for @pets_sectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets_sectionTitle;

  /// No description provided for @pets_notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get pets_notFound;

  /// No description provided for @pets_deletePetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete pet'**
  String get pets_deletePetTitle;

  /// No description provided for @pets_deletePetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}? This cannot be undone.'**
  String pets_deletePetConfirm(String name);

  /// No description provided for @pets_deleteRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get pets_deleteRecordTitle;

  /// No description provided for @pets_deleteRecordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\"?'**
  String pets_deleteRecordConfirm(String title);

  /// No description provided for @pets_setInactive.
  ///
  /// In en, this message translates to:
  /// **'Set inactive'**
  String get pets_setInactive;

  /// No description provided for @pets_setActive.
  ///
  /// In en, this message translates to:
  /// **'Set active'**
  String get pets_setActive;

  /// No description provided for @pets_healthRecords.
  ///
  /// In en, this message translates to:
  /// **'Health records'**
  String get pets_healthRecords;

  /// No description provided for @pets_noHealthRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No health records yet'**
  String get pets_noHealthRecordsYet;

  /// No description provided for @pets_genderMaleFull.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get pets_genderMaleFull;

  /// No description provided for @pets_genderFemaleFull.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get pets_genderFemaleFull;

  /// No description provided for @pets_genderUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get pets_genderUnknown;

  /// No description provided for @pets_weightKg.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String pets_weightKg(String weight);

  /// No description provided for @pets_recordNextDue.
  ///
  /// In en, this message translates to:
  /// **' · Next: '**
  String get pets_recordNextDue;

  /// No description provided for @pets_costEuro.
  ///
  /// In en, this message translates to:
  /// **'€{amount}'**
  String pets_costEuro(String amount);

  /// No description provided for @pets_healthTypeVaccine.
  ///
  /// In en, this message translates to:
  /// **'Vaccine'**
  String get pets_healthTypeVaccine;

  /// No description provided for @pets_healthTypeVet.
  ///
  /// In en, this message translates to:
  /// **'Vet visit'**
  String get pets_healthTypeVet;

  /// No description provided for @pets_healthTypeMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get pets_healthTypeMedication;

  /// No description provided for @pets_healthTypeGrooming.
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get pets_healthTypeGrooming;

  /// No description provided for @pets_healthTypeDeworming.
  ///
  /// In en, this message translates to:
  /// **'Deworming'**
  String get pets_healthTypeDeworming;

  /// No description provided for @pets_healthTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get pets_healthTypeOther;

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

  /// No description provided for @dashboard_noExpensesInWindow.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this window'**
  String get dashboard_noExpensesInWindow;

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

  /// No description provided for @dashboard_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get dashboard_map;

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

  /// No description provided for @dashboard_noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get dashboard_noTransactionsYet;

  /// No description provided for @dashboard_activeShoppingSession.
  ///
  /// In en, this message translates to:
  /// **'Active shopping session'**
  String get dashboard_activeShoppingSession;

  /// No description provided for @dashboard_activeShoppingSessions.
  ///
  /// In en, this message translates to:
  /// **'{count} active sessions'**
  String dashboard_activeShoppingSessions(int count);

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

  /// No description provided for @calendar_allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get calendar_allDay;

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

  /// No description provided for @shopping_startSession.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get shopping_startSession;

  /// No description provided for @shopping_startFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Start from template'**
  String get shopping_startFromTemplate;

  /// No description provided for @shopping_newTemplate.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get shopping_newTemplate;

  /// No description provided for @shopping_noActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'No active sessions — tap play to start'**
  String get shopping_noActiveSessions;

  /// No description provided for @shopping_noFinishedSessions.
  ///
  /// In en, this message translates to:
  /// **'No finished sessions yet'**
  String get shopping_noFinishedSessions;

  /// No description provided for @shopping_sharedCollaboration.
  ///
  /// In en, this message translates to:
  /// **'Shared · anyone in the household can collaborate'**
  String get shopping_sharedCollaboration;

  /// No description provided for @shopping_createTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create new template'**
  String get shopping_createTemplate;

  /// No description provided for @shopping_kindTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get shopping_kindTemplate;

  /// No description provided for @shopping_kindSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get shopping_kindSession;

  /// No description provided for @shopping_statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get shopping_statusPaid;

  /// No description provided for @shopping_statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get shopping_statusCancelled;

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
  /// **'Mark read'**
  String get notifications_markRead;

  /// No description provided for @notifications_markUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get notifications_markUnread;

  /// No description provided for @transaction_new.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get transaction_new;

  /// No description provided for @transaction_fallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction_fallbackTitle;

  /// No description provided for @transaction_fallbackAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get transaction_fallbackAccount;

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

  /// No description provided for @common_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get common_none;

  /// No description provided for @common_notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get common_notSet;

  /// No description provided for @appointments_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get appointments_title;

  /// No description provided for @appointments_titlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Dentist · Gym · Meeting…'**
  String get appointments_titlePlaceholder;

  /// No description provided for @appointments_shareHousehold.
  ///
  /// In en, this message translates to:
  /// **'Share with household'**
  String get appointments_shareHousehold;

  /// No description provided for @appointments_allDay.
  ///
  /// In en, this message translates to:
  /// **'All day'**
  String get appointments_allDay;

  /// No description provided for @appointments_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get appointments_date;

  /// No description provided for @appointments_startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get appointments_startTime;

  /// No description provided for @appointments_endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get appointments_endTime;

  /// No description provided for @appointments_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get appointments_category;

  /// No description provided for @appointments_reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get appointments_reminders;

  /// No description provided for @appointments_color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get appointments_color;

  /// No description provided for @appointments_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get appointments_location;

  /// No description provided for @appointments_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get appointments_notes;

  /// No description provided for @appointments_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get appointments_save;

  /// No description provided for @calendar_noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get calendar_noEvents;

  /// No description provided for @calendar_deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get calendar_deleteEvent;

  /// No description provided for @calendar_deleteEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get calendar_deleteEventConfirm;

  /// No description provided for @bankAccounts_myAccounts.
  ///
  /// In en, this message translates to:
  /// **'My accounts'**
  String get bankAccounts_myAccounts;

  /// No description provided for @bankAccounts_others.
  ///
  /// In en, this message translates to:
  /// **'Other accounts'**
  String get bankAccounts_others;

  /// No description provided for @bankAccounts_showOthers.
  ///
  /// In en, this message translates to:
  /// **'Show other accounts'**
  String get bankAccounts_showOthers;

  /// No description provided for @bankAccounts_hideOthers.
  ///
  /// In en, this message translates to:
  /// **'Hide other accounts'**
  String get bankAccounts_hideOthers;

  /// No description provided for @bankAccounts_signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view accounts'**
  String get bankAccounts_signInPrompt;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view profile'**
  String get profile_signInPrompt;

  /// No description provided for @profile_editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profile_editProfile;

  /// No description provided for @profile_displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get profile_displayName;

  /// No description provided for @profile_preferredCurrency.
  ///
  /// In en, this message translates to:
  /// **'Preferred currency'**
  String get profile_preferredCurrency;

  /// No description provided for @profile_calendarColor.
  ///
  /// In en, this message translates to:
  /// **'Calendar color'**
  String get profile_calendarColor;

  /// No description provided for @profile_birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get profile_birthDate;

  /// No description provided for @profile_deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profile_deleteAccountTitle;

  /// No description provided for @profile_deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will deactivate your account. This cannot be undone.'**
  String get profile_deleteAccountConfirm;

  /// No description provided for @profile_detailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get profile_detailsSection;

  /// No description provided for @profile_memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get profile_memberSince;

  /// No description provided for @profile_lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get profile_lastUpdate;

  /// No description provided for @profile_roleSuperuser.
  ///
  /// In en, this message translates to:
  /// **'SUPERUSER'**
  String get profile_roleSuperuser;

  /// No description provided for @profile_roleMember.
  ///
  /// In en, this message translates to:
  /// **'MEMBER'**
  String get profile_roleMember;

  /// No description provided for @profile_appUpdate.
  ///
  /// In en, this message translates to:
  /// **'App update'**
  String get profile_appUpdate;

  /// No description provided for @profile_updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get profile_updateAvailable;

  /// No description provided for @profile_upToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get profile_upToDate;

  /// No description provided for @update_title.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get update_title;

  /// No description provided for @update_message.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available. Update to get the latest features and fixes.'**
  String update_message(String version);

  /// No description provided for @update_action.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update_action;

  /// No description provided for @update_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get update_later;

  /// No description provided for @map_toggleTransactions.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get map_toggleTransactions;

  /// No description provided for @map_toggleHomes.
  ///
  /// In en, this message translates to:
  /// **'Homes'**
  String get map_toggleHomes;

  /// No description provided for @map_toggleVendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get map_toggleVendors;

  /// No description provided for @bankAccount_accountNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found'**
  String get bankAccount_accountNotFound;

  /// No description provided for @bankAccount_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get bankAccount_account;

  /// No description provided for @bankAccount_period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get bankAccount_period;

  /// No description provided for @bankAccount_periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get bankAccount_periodThisMonth;

  /// No description provided for @bankAccount_periodLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get bankAccount_periodLast6Months;

  /// No description provided for @bankAccount_periodLast12Months.
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get bankAccount_periodLast12Months;

  /// No description provided for @bankAccount_periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get bankAccount_periodMonth;

  /// No description provided for @bankAccount_period6Months.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get bankAccount_period6Months;

  /// No description provided for @bankAccount_period1Year.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get bankAccount_period1Year;

  /// No description provided for @bankAccount_balancePeriod.
  ///
  /// In en, this message translates to:
  /// **'Balance · {period}'**
  String bankAccount_balancePeriod(String period);

  /// No description provided for @bankAccount_incomeVsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income vs expense · {period}'**
  String bankAccount_incomeVsExpense(String period);

  /// No description provided for @bankAccount_recurringTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recurring transactions'**
  String get bankAccount_recurringTransactions;

  /// No description provided for @bankAccount_noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet — tap to add one'**
  String get bankAccount_noGoalsYet;

  /// No description provided for @bankAccount_actionLogs.
  ///
  /// In en, this message translates to:
  /// **'Action logs'**
  String get bankAccount_actionLogs;

  /// No description provided for @bankAccount_noActivityInWindow.
  ///
  /// In en, this message translates to:
  /// **'No activity in this window'**
  String get bankAccount_noActivityInWindow;

  /// No description provided for @bankAccount_income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get bankAccount_income;

  /// No description provided for @bankAccount_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get bankAccount_expense;

  /// No description provided for @bankAccount_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get bankAccount_date;

  /// No description provided for @bankAccount_action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get bankAccount_action;

  /// No description provided for @bankAccount_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get bankAccount_amount;

  /// No description provided for @bankAccount_newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get bankAccount_newTransaction;

  /// No description provided for @bankAccount_newGoal.
  ///
  /// In en, this message translates to:
  /// **'New goal'**
  String get bankAccount_newGoal;

  /// No description provided for @bankAccount_editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit goal'**
  String get bankAccount_editGoal;

  /// No description provided for @bankAccount_addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get bankAccount_addGoal;

  /// No description provided for @bankAccount_addCard.
  ///
  /// In en, this message translates to:
  /// **'Add card'**
  String get bankAccount_addCard;

  /// No description provided for @bankAccount_setAsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set as primary'**
  String get bankAccount_setAsPrimary;

  /// No description provided for @settings_homes.
  ///
  /// In en, this message translates to:
  /// **'Homes'**
  String get settings_homes;

  /// No description provided for @settings_homesSub.
  ///
  /// In en, this message translates to:
  /// **'Manage household locations'**
  String get settings_homesSub;

  /// No description provided for @settings_googleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar'**
  String get settings_googleCalendar;

  /// No description provided for @settings_googleCalendarSub.
  ///
  /// In en, this message translates to:
  /// **'Connect a Google account to sync events'**
  String get settings_googleCalendarSub;

  /// No description provided for @settings_startDayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get settings_startDayMonday;

  /// No description provided for @settings_startDaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get settings_startDaySaturday;

  /// No description provided for @settings_startDaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get settings_startDaySunday;

  /// No description provided for @settings_permissionAccess.
  ///
  /// In en, this message translates to:
  /// **'{permission} access'**
  String settings_permissionAccess(String permission);

  /// No description provided for @settings_permissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Hestia needs {permission} access. Tap \"Open Settings\" to enable it.'**
  String settings_permissionMessage(String permission);

  /// No description provided for @settings_disableLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'To disable location access, open Settings → Hestia → Location and turn it off.'**
  String get settings_disableLocationMessage;

  /// No description provided for @settings_disableNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'To disable notifications, open Settings → Hestia → Notifications and turn them off.'**
  String get settings_disableNotificationsMessage;

  /// No description provided for @settings_openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get settings_openSettings;

  /// No description provided for @settings_syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get settings_syncNow;

  /// No description provided for @settings_disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get settings_disconnect;

  /// No description provided for @settings_calendarSynced.
  ///
  /// In en, this message translates to:
  /// **'Calendar synced'**
  String get settings_calendarSynced;

  /// No description provided for @settings_calendarDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar disconnected'**
  String get settings_calendarDisconnected;

  /// No description provided for @settings_calendarConnected.
  ///
  /// In en, this message translates to:
  /// **'Google Calendar connected'**
  String get settings_calendarConnected;

  /// No description provided for @healthRecord_addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get healthRecord_addRecord;

  /// No description provided for @healthRecord_editRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get healthRecord_editRecord;

  /// No description provided for @healthRecord_saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get healthRecord_saveChanges;

  /// No description provided for @healthRecord_couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save'**
  String get healthRecord_couldNotSave;

  /// No description provided for @healthRecord_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get healthRecord_type;

  /// No description provided for @healthRecord_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get healthRecord_title;

  /// No description provided for @healthRecord_titlePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Annual vaccination'**
  String get healthRecord_titlePlaceholder;

  /// No description provided for @healthRecord_vetClinic.
  ///
  /// In en, this message translates to:
  /// **'Vet / Clinic'**
  String get healthRecord_vetClinic;

  /// No description provided for @healthRecord_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get healthRecord_optional;

  /// No description provided for @healthRecord_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get healthRecord_date;

  /// No description provided for @healthRecord_nextDueDate.
  ///
  /// In en, this message translates to:
  /// **'Next due date'**
  String get healthRecord_nextDueDate;

  /// No description provided for @healthRecord_costEuro.
  ///
  /// In en, this message translates to:
  /// **'Cost (€)'**
  String get healthRecord_costEuro;

  /// No description provided for @healthRecord_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get healthRecord_notes;

  /// No description provided for @healthRecord_notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Optional notes…'**
  String get healthRecord_notesPlaceholder;

  /// No description provided for @notifications_inbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get notifications_inbox;

  /// No description provided for @notifications_markAll.
  ///
  /// In en, this message translates to:
  /// **'Mark all'**
  String get notifications_markAll;

  /// No description provided for @notifications_allMarkedRead.
  ///
  /// In en, this message translates to:
  /// **'All marked as read'**
  String get notifications_allMarkedRead;

  /// No description provided for @notifications_noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifications_noNotificationsYet;

  /// No description provided for @notifications_signInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view notifications.'**
  String get notifications_signInPrompt;

  /// No description provided for @notifications_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get notifications_delete;

  /// No description provided for @notifications_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete notification'**
  String get notifications_deleteTitle;

  /// No description provided for @notifications_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get notifications_deleteConfirm;

  /// No description provided for @notifications_deleted.
  ///
  /// In en, this message translates to:
  /// **'Notification deleted'**
  String get notifications_deleted;

  /// No description provided for @notifications_markedRead.
  ///
  /// In en, this message translates to:
  /// **'Marked as read'**
  String get notifications_markedRead;

  /// No description provided for @notifications_markedUnread.
  ///
  /// In en, this message translates to:
  /// **'Marked unread'**
  String get notifications_markedUnread;

  /// No description provided for @notifications_allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get notifications_allCaughtUp;

  /// No description provided for @notifications_unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notifications_unreadCount(int count);

  /// No description provided for @notifications_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notifications_yesterday;

  /// No description provided for @notifications_daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String notifications_daysAgo(int count);

  /// No description provided for @goals_goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goals_goalTitle;

  /// No description provided for @goals_saved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get goals_saved;

  /// No description provided for @goals_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get goals_remaining;

  /// No description provided for @goals_monthlyNeed.
  ///
  /// In en, this message translates to:
  /// **'Monthly need'**
  String get goals_monthlyNeed;

  /// No description provided for @goals_daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days left'**
  String get goals_daysLeft;

  /// No description provided for @goals_linkedSource.
  ///
  /// In en, this message translates to:
  /// **'Linked source'**
  String get goals_linkedSource;

  /// No description provided for @goals_contributions.
  ///
  /// In en, this message translates to:
  /// **'Contributions'**
  String get goals_contributions;

  /// No description provided for @goals_addContribution.
  ///
  /// In en, this message translates to:
  /// **'Add contribution'**
  String get goals_addContribution;

  /// No description provided for @fuelEntry_addFillUp.
  ///
  /// In en, this message translates to:
  /// **'Add fill-up'**
  String get fuelEntry_addFillUp;

  /// No description provided for @fuelEntry_editFillUp.
  ///
  /// In en, this message translates to:
  /// **'Edit fill-up'**
  String get fuelEntry_editFillUp;

  /// No description provided for @fuelEntry_filledAt.
  ///
  /// In en, this message translates to:
  /// **'Filled at'**
  String get fuelEntry_filledAt;

  /// No description provided for @fuelEntry_odometerKm.
  ///
  /// In en, this message translates to:
  /// **'Odometer (km)'**
  String get fuelEntry_odometerKm;

  /// No description provided for @fuelEntry_liters.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get fuelEntry_liters;

  /// No description provided for @fuelEntry_pricePerLiter.
  ///
  /// In en, this message translates to:
  /// **'Price per liter (€)'**
  String get fuelEntry_pricePerLiter;

  /// No description provided for @fuelEntry_totalEuro.
  ///
  /// In en, this message translates to:
  /// **'Total (€)'**
  String get fuelEntry_totalEuro;

  /// No description provided for @fuelEntry_station.
  ///
  /// In en, this message translates to:
  /// **'STATION'**
  String get fuelEntry_station;

  /// No description provided for @fuelEntry_fullTank.
  ///
  /// In en, this message translates to:
  /// **'Full tank'**
  String get fuelEntry_fullTank;

  /// No description provided for @fuelEntry_alsoCreateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Also create transaction'**
  String get fuelEntry_alsoCreateTransaction;

  /// No description provided for @fuelEntry_comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get fuelEntry_comingSoon;

  /// No description provided for @fuelEntry_notes.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get fuelEntry_notes;

  /// No description provided for @fuelEntry_notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Optional notes'**
  String get fuelEntry_notesPlaceholder;

  /// No description provided for @fuelEntry_added.
  ///
  /// In en, this message translates to:
  /// **'Fuel entry added'**
  String get fuelEntry_added;

  /// No description provided for @fuelEntry_updated.
  ///
  /// In en, this message translates to:
  /// **'Fuel entry updated'**
  String get fuelEntry_updated;

  /// No description provided for @fuelEntry_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get fuelEntry_done;

  /// No description provided for @car_newCar.
  ///
  /// In en, this message translates to:
  /// **'New car'**
  String get car_newCar;

  /// No description provided for @car_editCar.
  ///
  /// In en, this message translates to:
  /// **'Edit car'**
  String get car_editCar;

  /// No description provided for @car_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get car_name;

  /// No description provided for @car_make.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get car_make;

  /// No description provided for @car_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get car_model;

  /// No description provided for @car_year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get car_year;

  /// No description provided for @car_licensePlate.
  ///
  /// In en, this message translates to:
  /// **'License plate'**
  String get car_licensePlate;

  /// No description provided for @car_gasoline.
  ///
  /// In en, this message translates to:
  /// **'Gasoline'**
  String get car_gasoline;

  /// No description provided for @car_diesel.
  ///
  /// In en, this message translates to:
  /// **'Diesel'**
  String get car_diesel;

  /// No description provided for @car_electric.
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get car_electric;

  /// No description provided for @car_hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get car_hybrid;

  /// No description provided for @car_tankCapacity.
  ///
  /// In en, this message translates to:
  /// **'Tank capacity (L)'**
  String get car_tankCapacity;

  /// No description provided for @car_currentOdometer.
  ///
  /// In en, this message translates to:
  /// **'Current odometer (km)'**
  String get car_currentOdometer;

  /// No description provided for @car_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get car_status;

  /// No description provided for @car_statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get car_statusActive;

  /// No description provided for @car_statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get car_statusInactive;

  /// No description provided for @car_drivers.
  ///
  /// In en, this message translates to:
  /// **'DRIVERS'**
  String get car_drivers;

  /// No description provided for @fuelAnalytics_avgL100km.
  ///
  /// In en, this message translates to:
  /// **'Avg L/100km'**
  String get fuelAnalytics_avgL100km;

  /// No description provided for @fuelAnalytics_costPerKm.
  ///
  /// In en, this message translates to:
  /// **'Cost / km'**
  String get fuelAnalytics_costPerKm;

  /// No description provided for @fuelAnalytics_last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get fuelAnalytics_last30Days;

  /// No description provided for @fuelAnalytics_consumption.
  ///
  /// In en, this message translates to:
  /// **'CONSUMPTION (L/100KM)'**
  String get fuelAnalytics_consumption;

  /// No description provided for @fuelAnalytics_monthlyCost.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY COST'**
  String get fuelAnalytics_monthlyCost;

  /// No description provided for @fuelAnalytics_noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get fuelAnalytics_noDataYet;

  /// No description provided for @fuelAnalytics_needFullTanks.
  ///
  /// In en, this message translates to:
  /// **'Need at least 2 full tanks'**
  String get fuelAnalytics_needFullTanks;

  /// No description provided for @bankAccountForm_newAccount.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get bankAccountForm_newAccount;

  /// No description provided for @bankAccountForm_editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get bankAccountForm_editAccount;

  /// No description provided for @bankAccountForm_bank.
  ///
  /// In en, this message translates to:
  /// **'BANK'**
  String get bankAccountForm_bank;

  /// No description provided for @bankAccountForm_selectBank.
  ///
  /// In en, this message translates to:
  /// **'Select bank'**
  String get bankAccountForm_selectBank;

  /// No description provided for @bankAccountForm_accountName.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT NAME'**
  String get bankAccountForm_accountName;

  /// No description provided for @bankAccountForm_accountNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Checking'**
  String get bankAccountForm_accountNamePlaceholder;

  /// No description provided for @bankAccountForm_ibanOptional.
  ///
  /// In en, this message translates to:
  /// **'IBAN (OPTIONAL)'**
  String get bankAccountForm_ibanOptional;

  /// No description provided for @bankAccountForm_type.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get bankAccountForm_type;

  /// No description provided for @bankAccountForm_checking.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get bankAccountForm_checking;

  /// No description provided for @bankAccountForm_savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get bankAccountForm_savings;

  /// No description provided for @bankAccountForm_credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get bankAccountForm_credit;

  /// No description provided for @bankAccountForm_cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get bankAccountForm_cash;

  /// No description provided for @bankAccountForm_investment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get bankAccountForm_investment;

  /// No description provided for @bankAccountForm_ownership.
  ///
  /// In en, this message translates to:
  /// **'OWNERSHIP'**
  String get bankAccountForm_ownership;

  /// No description provided for @bankAccountForm_personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get bankAccountForm_personal;

  /// No description provided for @bankAccountForm_shared.
  ///
  /// In en, this message translates to:
  /// **'Shared'**
  String get bankAccountForm_shared;

  /// No description provided for @bankAccountForm_initialBalance.
  ///
  /// In en, this message translates to:
  /// **'INITIAL BALANCE'**
  String get bankAccountForm_initialBalance;

  /// No description provided for @bankAccountForm_createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get bankAccountForm_createAccount;

  /// No description provided for @bankAccountForm_saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get bankAccountForm_saveChanges;

  /// No description provided for @bankAccountForm_accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get bankAccountForm_accountCreated;

  /// No description provided for @bankAccountForm_accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get bankAccountForm_accountUpdated;

  /// No description provided for @bankAccountForm_couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save'**
  String get bankAccountForm_couldNotSave;

  /// No description provided for @bankAccountForm_enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter an account name'**
  String get bankAccountForm_enterName;

  /// No description provided for @bankAccountForm_searchBank.
  ///
  /// In en, this message translates to:
  /// **'Search bank…'**
  String get bankAccountForm_searchBank;

  /// No description provided for @bankAccountForm_noneEnterManually.
  ///
  /// In en, this message translates to:
  /// **'None / enter manually'**
  String get bankAccountForm_noneEnterManually;

  /// No description provided for @bankAccountForm_selectBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Select bank'**
  String get bankAccountForm_selectBankTitle;

  /// No description provided for @recurringTransactions_title.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringTransactions_title;

  /// No description provided for @recurringTransactions_noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions yet'**
  String get recurringTransactions_noTransactionsYet;

  /// No description provided for @recurringTransactions_recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurringTransactions_recurring;

  /// No description provided for @homes_title.
  ///
  /// In en, this message translates to:
  /// **'Homes'**
  String get homes_title;

  /// No description provided for @homes_noHomesYet.
  ///
  /// In en, this message translates to:
  /// **'No homes yet'**
  String get homes_noHomesYet;

  /// No description provided for @homes_addHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your home to associate it with transactions.'**
  String get homes_addHomeDescription;

  /// No description provided for @homes_addHome.
  ///
  /// In en, this message translates to:
  /// **'Add home'**
  String get homes_addHome;

  /// No description provided for @homes_editHome.
  ///
  /// In en, this message translates to:
  /// **'Edit home'**
  String get homes_editHome;

  /// No description provided for @homes_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get homes_name;

  /// No description provided for @homes_namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Apartment'**
  String get homes_namePlaceholder;

  /// No description provided for @homes_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get homes_address;

  /// No description provided for @homes_addressPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Full street address'**
  String get homes_addressPlaceholder;

  /// No description provided for @homes_saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get homes_saveChanges;

  /// No description provided for @homes_deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homes_deleteLabel;

  /// No description provided for @homes_editLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get homes_editLabel;

  /// No description provided for @transaction_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transaction_expense;

  /// No description provided for @transaction_income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transaction_income;

  /// No description provided for @transaction_transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transaction_transfer;

  /// No description provided for @transaction_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get transaction_category;

  /// No description provided for @transaction_selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get transaction_selectCategory;

  /// No description provided for @transaction_bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get transaction_bankAccount;

  /// No description provided for @transaction_fromAccount.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get transaction_fromAccount;

  /// No description provided for @transaction_toAccount.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get transaction_toAccount;

  /// No description provided for @transaction_card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get transaction_card;

  /// No description provided for @transaction_source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get transaction_source;

  /// No description provided for @transaction_sourceOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get transaction_sourceOptional;

  /// No description provided for @transaction_sourceSub.
  ///
  /// In en, this message translates to:
  /// **'Merchant, employer, service'**
  String get transaction_sourceSub;

  /// No description provided for @transaction_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transaction_date;

  /// No description provided for @transaction_repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get transaction_repeat;

  /// No description provided for @transaction_oneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get transaction_oneTime;

  /// No description provided for @transaction_recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get transaction_recurring;

  /// No description provided for @transaction_addNote.
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get transaction_addNote;

  /// No description provided for @transaction_attachLocation.
  ///
  /// In en, this message translates to:
  /// **'Attach location'**
  String get transaction_attachLocation;

  /// No description provided for @transaction_locationOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get transaction_locationOn;

  /// No description provided for @transaction_locationOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get transaction_locationOff;

  /// No description provided for @transaction_useGps.
  ///
  /// In en, this message translates to:
  /// **'Use GPS'**
  String get transaction_useGps;

  /// No description provided for @transaction_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get transaction_map;

  /// No description provided for @transaction_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get transaction_today;

  /// No description provided for @transaction_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get transaction_update;

  /// No description provided for @transaction_saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get transaction_saveTransaction;

  /// No description provided for @transaction_expenseSaved.
  ///
  /// In en, this message translates to:
  /// **'Expense saved'**
  String get transaction_expenseSaved;

  /// No description provided for @transaction_incomeSaved.
  ///
  /// In en, this message translates to:
  /// **'Income saved'**
  String get transaction_incomeSaved;

  /// No description provided for @transaction_deleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transaction_deleted;

  /// No description provided for @transaction_somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get transaction_somethingWentWrong;

  /// No description provided for @transaction_selectCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get transaction_selectCategoryTitle;

  /// No description provided for @transaction_selectBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Select bank account'**
  String get transaction_selectBankAccount;

  /// No description provided for @transaction_selectFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Select from account'**
  String get transaction_selectFromAccount;

  /// No description provided for @transaction_selectDestinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Select destination account'**
  String get transaction_selectDestinationAccount;

  /// No description provided for @transaction_selectCard.
  ///
  /// In en, this message translates to:
  /// **'Select card'**
  String get transaction_selectCard;

  /// No description provided for @transaction_noCard.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get transaction_noCard;

  /// No description provided for @transaction_noCardSub.
  ///
  /// In en, this message translates to:
  /// **'No card'**
  String get transaction_noCardSub;

  /// No description provided for @transaction_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get transaction_currency;

  /// No description provided for @transaction_counterpartySource.
  ///
  /// In en, this message translates to:
  /// **'Counterparty source'**
  String get transaction_counterpartySource;

  /// No description provided for @transaction_selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get transaction_selectDate;

  /// No description provided for @transaction_newSource.
  ///
  /// In en, this message translates to:
  /// **'New source'**
  String get transaction_newSource;

  /// No description provided for @transaction_editSource.
  ///
  /// In en, this message translates to:
  /// **'Edit source'**
  String get transaction_editSource;

  /// No description provided for @card_primary.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY'**
  String get card_primary;

  /// No description provided for @card_virtual.
  ///
  /// In en, this message translates to:
  /// **'VIRTUAL'**
  String get card_virtual;

  /// No description provided for @card_expires.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES'**
  String get card_expires;

  /// No description provided for @appointment_duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get appointment_duration;

  /// No description provided for @appointment_pinLocation.
  ///
  /// In en, this message translates to:
  /// **'Pin location on map'**
  String get appointment_pinLocation;

  /// No description provided for @appointment_signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get appointment_signInRequired;

  /// No description provided for @appointment_categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get appointment_categoryHealth;

  /// No description provided for @appointment_categoryVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get appointment_categoryVehicle;

  /// No description provided for @appointment_categoryBeauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get appointment_categoryBeauty;

  /// No description provided for @appointment_categoryWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get appointment_categoryWork;

  /// No description provided for @appointment_categoryPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get appointment_categoryPersonal;

  /// No description provided for @appointment_categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get appointment_categoryOther;

  /// No description provided for @bankAccount_goalsOnThisAccount.
  ///
  /// In en, this message translates to:
  /// **'Goals on this account'**
  String get bankAccount_goalsOnThisAccount;

  /// No description provided for @homes_coordinatesNote.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {lat}, {lng}\nTap the map in the full map view to pick a precise location.'**
  String homes_coordinatesNote(String lat, String lng);

  /// No description provided for @card_addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get card_addCard;

  /// No description provided for @card_editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get card_editCard;

  /// No description provided for @card_network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get card_network;

  /// No description provided for @card_last4Digits.
  ///
  /// In en, this message translates to:
  /// **'Last 4 digits'**
  String get card_last4Digits;

  /// No description provided for @card_cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name'**
  String get card_cardholderName;

  /// No description provided for @card_month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get card_month;

  /// No description provided for @card_year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get card_year;

  /// No description provided for @card_cardholderOwner.
  ///
  /// In en, this message translates to:
  /// **'Cardholder owner'**
  String get card_cardholderOwner;

  /// No description provided for @card_primaryCard.
  ///
  /// In en, this message translates to:
  /// **'Primary card'**
  String get card_primaryCard;

  /// No description provided for @card_virtualCard.
  ///
  /// In en, this message translates to:
  /// **'Virtual card'**
  String get card_virtualCard;

  /// No description provided for @card_saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get card_saveChanges;

  /// No description provided for @card_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get card_none;

  /// No description provided for @card_last4Error.
  ///
  /// In en, this message translates to:
  /// **'Last 4 digits must be exactly 4 numbers'**
  String get card_last4Error;

  /// No description provided for @card_cardholderRequired.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name is required'**
  String get card_cardholderRequired;

  /// No description provided for @card_setAsPrimary.
  ///
  /// In en, this message translates to:
  /// **'Set as primary'**
  String get card_setAsPrimary;

  /// No description provided for @transaction_relatedTo.
  ///
  /// In en, this message translates to:
  /// **'Related to'**
  String get transaction_relatedTo;

  /// No description provided for @transaction_createNewSource.
  ///
  /// In en, this message translates to:
  /// **'Create new source'**
  String get transaction_createNewSource;

  /// No description provided for @transaction_amountLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT · {currency}'**
  String transaction_amountLabel(String currency);

  /// No description provided for @transaction_relatedToNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get transaction_relatedToNone;

  /// No description provided for @appointment_durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String appointment_durationMinutes(int n);

  /// No description provided for @appointment_durationHours.
  ///
  /// In en, this message translates to:
  /// **'{n}h'**
  String appointment_durationHours(int n);

  /// No description provided for @appointment_durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String appointment_durationHoursMinutes(int h, int m);

  /// No description provided for @appointment_reminder1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get appointment_reminder1Day;

  /// No description provided for @appointment_reminderDays.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String appointment_reminderDays(int n);
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
