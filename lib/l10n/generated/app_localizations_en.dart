// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_done => 'Done';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_add => 'Add';

  @override
  String get common_close => 'Close';

  @override
  String get common_today => 'Today';

  @override
  String get common_viewAll => 'View all';

  @override
  String get common_seeAll => 'See all';

  @override
  String get common_signOut => 'Sign out';

  @override
  String get auth_signInFailed => 'Sign-in failed';

  @override
  String get auth_tagline => 'Manage your household finances together';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_showPassword => 'Show password';

  @override
  String get auth_signIn => 'Sign in';

  @override
  String get auth_or => 'or';

  @override
  String get auth_signInWithApple => 'Sign in with Apple';

  @override
  String get nav_dashboard => 'Home';

  @override
  String get nav_calendar => 'Calendar';

  @override
  String get nav_shopping => 'Shopping';

  @override
  String get nav_accounts => 'Accounts';

  @override
  String get nav_pets => 'Pets';

  @override
  String get nav_cars => 'Cars';

  @override
  String get settings_carsModule => 'Cars tracking';

  @override
  String get settings_carsTitle => 'Cars';

  @override
  String get settings_carsSub => 'Cars and fill-ups';

  @override
  String get settings_general => 'General';

  @override
  String get settings_modules => 'Modules';

  @override
  String get settings_dataManagement => 'Data management';

  @override
  String get settings_categoriesTab => 'Categories';

  @override
  String get settings_sourcesTab => 'Sources';

  @override
  String get settings_dateFormat => 'Date format';

  @override
  String get settings_dateFormatMdy => 'MM/DD/YYYY';

  @override
  String get settings_dateFormatDmy => 'DD/MM/YYYY';

  @override
  String get settings_dateFormatYmd => 'YYYY-MM-DD';

  @override
  String get settings_allowLocation => 'Allow location';

  @override
  String get settings_allowNotifications => 'Allow notifications';

  @override
  String get settings_faceIdUnlock => 'Face ID unlock';

  @override
  String get settings_viewCarsData => 'View cars data';

  @override
  String get profile_edit => 'Edit';

  @override
  String get notifications_unread => 'Unread';

  @override
  String get notifications_read => 'Read';

  @override
  String get notifications_showRead => 'Show read';

  @override
  String get notifications_hideRead => 'Hide read';

  @override
  String get cars_title => 'Cars';

  @override
  String get cars_analyticsTitle => 'Car analytics';

  @override
  String get cars_fuelType => 'Fuel type';

  @override
  String get cars_noVehiclesYet => 'No vehicles yet';

  @override
  String get cars_tapToAdd => 'Tap + to add one';

  @override
  String get cars_statusActive => 'Active';

  @override
  String get cars_statusSold => 'Sold';

  @override
  String get cars_statusScrap => 'Scrap';

  @override
  String cars_odometerKm(String km) {
    return '$km km';
  }

  @override
  String get cars_carTitle => 'Car';

  @override
  String get cars_notFound => 'Not found';

  @override
  String get cars_deleteCarTitle => 'Delete car';

  @override
  String cars_deleteCarConfirm(String name) {
    return 'Remove $name? This cannot be undone.';
  }

  @override
  String get cars_statusInactive => 'Inactive';

  @override
  String get cars_addFillUp => 'Add fill-up';

  @override
  String get cars_recentFillUps => 'Recent fill-ups';

  @override
  String get cars_seeAnalytics => 'See analytics';

  @override
  String get cars_noFillUpsYet => 'No fill-ups yet';

  @override
  String get cars_fillUpFullSuffix => ' · full';

  @override
  String cars_fillUpLine(
      String liters, String pricePerLiter, String fullSuffix) {
    return '$liters L · $pricePerLiter €/L$fullSuffix';
  }

  @override
  String cars_fillUpMeta(String date, String odometer) {
    return '$date · $odometer km';
  }

  @override
  String cars_amountEuro(String amount) {
    return '$amount €';
  }

  @override
  String get pets_noPetsYet => 'No pets yet';

  @override
  String get pets_tapToAdd => 'Tap + to add one';

  @override
  String get pets_speciesDog => 'Dog';

  @override
  String get pets_speciesCat => 'Cat';

  @override
  String get pets_speciesBird => 'Bird';

  @override
  String get pets_speciesRabbit => 'Rabbit';

  @override
  String get pets_speciesFish => 'Fish';

  @override
  String get pets_speciesReptile => 'Reptile';

  @override
  String get pets_speciesOther => 'Other';

  @override
  String pets_ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yrs',
      one: '1 yr',
    );
    return '$_temp0';
  }

  @override
  String get pets_genderMale => 'M';

  @override
  String get pets_genderFemale => 'F';

  @override
  String get pets_title => 'Pet';

  @override
  String get pets_notFound => 'Not found';

  @override
  String get pets_deletePetTitle => 'Delete pet';

  @override
  String pets_deletePetConfirm(String name) {
    return 'Remove $name? This cannot be undone.';
  }

  @override
  String get pets_deleteRecordTitle => 'Delete record';

  @override
  String pets_deleteRecordConfirm(String title) {
    return 'Remove \"$title\"?';
  }

  @override
  String get pets_setInactive => 'Set inactive';

  @override
  String get pets_setActive => 'Set active';

  @override
  String get pets_healthRecords => 'Health records';

  @override
  String get pets_noHealthRecordsYet => 'No health records yet';

  @override
  String get pets_genderMaleFull => 'Male';

  @override
  String get pets_genderFemaleFull => 'Female';

  @override
  String get pets_genderUnknown => 'Unknown';

  @override
  String pets_weightKg(String weight) {
    return '$weight kg';
  }

  @override
  String get pets_recordNextDue => ' · Next: ';

  @override
  String pets_costEuro(String amount) {
    return '€$amount';
  }

  @override
  String get pets_healthTypeVaccine => 'Vaccine';

  @override
  String get pets_healthTypeVet => 'Vet visit';

  @override
  String get pets_healthTypeMedication => 'Medication';

  @override
  String get pets_healthTypeGrooming => 'Grooming';

  @override
  String get pets_healthTypeDeworming => 'Deworming';

  @override
  String get pets_healthTypeOther => 'Other';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_appearance => 'Appearance';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_languageEs => 'Español';

  @override
  String get settings_startDay => 'First day of week';

  @override
  String get settings_use24h => '24-hour clock';

  @override
  String get settings_biometric => 'Face ID';

  @override
  String get dashboard_overview => 'Overview';

  @override
  String get dashboard_greetingMorning => 'Good morning';

  @override
  String get dashboard_greetingAfternoon => 'Good afternoon';

  @override
  String get dashboard_greetingEvening => 'Good evening';

  @override
  String get dashboard_accounts => 'Accounts';

  @override
  String get dashboard_spending => 'Spending';

  @override
  String get dashboard_noExpensesInWindow => 'No expenses in this window';

  @override
  String get dashboard_activeGoals => 'Active goals';

  @override
  String get dashboard_recent => 'Recent';

  @override
  String get dashboard_map => 'Map';

  @override
  String get dashboard_balanceTrend => 'Balance trend';

  @override
  String get dashboard_monthlyNet => 'Monthly net';

  @override
  String get dashboard_noTransactionsYet => 'No transactions yet';

  @override
  String get dashboard_activeShoppingSession => 'Active shopping session';

  @override
  String dashboard_activeShoppingSessions(int count) {
    return '$count active sessions';
  }

  @override
  String get bankAccounts_title => 'Sources';

  @override
  String get bankAccounts_totalNetWorth => 'Total net worth';

  @override
  String get bankAccounts_addCard => 'Add card';

  @override
  String get bankAccounts_shared => 'Shared';

  @override
  String get bankAccounts_personal => 'Personal';

  @override
  String get bankAccounts_noInstitution => 'No institution';

  @override
  String get goals_title => 'Goals';

  @override
  String get goals_addGoal => 'Add goal';

  @override
  String get goals_global => 'All goals';

  @override
  String get goals_perAccount => 'Goals on this account';

  @override
  String get calendar_title => 'Calendar';

  @override
  String get calendar_newAppointment => 'New appointment';

  @override
  String get calendar_appointment => 'Appointment';

  @override
  String get calendar_allDay => 'All day';

  @override
  String get calendar_filterAll => 'Show all members';

  @override
  String get calendar_filterMine => 'Only mine';

  @override
  String get calendar_eventos => 'Eventos';

  @override
  String get calendar_movimientos => 'Movimientos';

  @override
  String get shopping_title => 'Shopping';

  @override
  String get shopping_sessionsTab => 'Sessions';

  @override
  String get shopping_active => 'Active';

  @override
  String get shopping_templatesTab => 'Templates';

  @override
  String get shopping_history => 'History';

  @override
  String get shopping_newList => 'New list';

  @override
  String get shopping_finishAndPay => 'Finish & Pay';

  @override
  String get shopping_cancelList => 'Cancel list';

  @override
  String get shopping_cancelConfirmTitle => 'Cancel this shopping list?';

  @override
  String get shopping_cancelConfirmBody =>
      'The list will be archived as cancelled and cannot be edited.';

  @override
  String get shopping_startSession => 'Start shopping';

  @override
  String get shopping_startFromTemplate => 'Start from template';

  @override
  String get shopping_newTemplate => 'New template';

  @override
  String get shopping_noActiveSessions =>
      'No active sessions — tap play to start';

  @override
  String get shopping_noFinishedSessions => 'No finished sessions yet';

  @override
  String get shopping_sharedCollaboration =>
      'Shared · anyone in the household can collaborate';

  @override
  String get shopping_createTemplate => 'Create new template';

  @override
  String get shopping_kindTemplate => 'Template';

  @override
  String get shopping_kindSession => 'Session';

  @override
  String get shopping_statusPaid => 'Paid';

  @override
  String get shopping_statusCancelled => 'Cancelled';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_markAllRead => 'Mark all as read';

  @override
  String get notifications_showAll => 'Show all';

  @override
  String get notifications_empty => 'No notifications';

  @override
  String get notifications_markRead => 'Mark as read';

  @override
  String get notifications_markUnread => 'Mark as unread';

  @override
  String get transaction_new => 'New transaction';

  @override
  String get transaction_fallbackTitle => 'Transaction';

  @override
  String get transaction_fallbackAccount => 'Account';

  @override
  String get transactionLocation_mapTitle => 'Pick location';

  @override
  String get transactionLocation_statsTitle => 'Location insights';

  @override
  String get transactionLocation_statsCount => 'geo-tagged pins';

  @override
  String get transactionLocation_empty =>
      'No transactions with a location yet.';

  @override
  String get settings_locationSection => 'Location';

  @override
  String get settings_locationStats => 'Map & pins';

  @override
  String get settings_locationStatsSub => 'Recent transactions saved with GPS';

  @override
  String get settings_locationPermission => 'Permission';

  @override
  String get settings_locationRequest => 'Request access';

  @override
  String get settings_locationOpenSettings => 'Open system settings';

  @override
  String get settings_locationPermGranted => 'Allowed while using the app';

  @override
  String get settings_locationPermDenied => 'Denied — tap Request access';

  @override
  String get settings_locationPermForever =>
      'Blocked — enable in system Settings';

  @override
  String get settings_locationPermSvcOff => 'Location services are turned off';

  @override
  String get common_none => 'None';

  @override
  String get common_notSet => 'Not set';

  @override
  String get appointments_title => 'Title';

  @override
  String get appointments_titlePlaceholder => 'Dentist · Gym · Meeting…';

  @override
  String get appointments_shareHousehold => 'Share with household';

  @override
  String get appointments_allDay => 'All day';

  @override
  String get appointments_date => 'Date';

  @override
  String get appointments_startTime => 'Start time';

  @override
  String get appointments_endTime => 'End time';

  @override
  String get appointments_category => 'Category';

  @override
  String get appointments_reminders => 'Reminders';

  @override
  String get appointments_color => 'Color';

  @override
  String get appointments_location => 'Location';

  @override
  String get appointments_notes => 'Notes';

  @override
  String get appointments_save => 'Save';

  @override
  String get calendar_noEvents => 'No events';

  @override
  String get calendar_deleteEvent => 'Delete event';

  @override
  String get calendar_deleteEventConfirm => 'This action cannot be undone.';

  @override
  String get bankAccounts_myAccounts => 'My accounts';

  @override
  String get bankAccounts_others => 'Other accounts';

  @override
  String get bankAccounts_showOthers => 'Show other accounts';

  @override
  String get bankAccounts_hideOthers => 'Hide other accounts';

  @override
  String get bankAccounts_signInPrompt => 'Sign in to view accounts';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_signInPrompt => 'Sign in to view profile';

  @override
  String get profile_editProfile => 'Edit profile';

  @override
  String get profile_displayName => 'Display name';

  @override
  String get profile_preferredCurrency => 'Preferred currency';

  @override
  String get profile_calendarColor => 'Calendar color';

  @override
  String get profile_birthDate => 'Birth date';

  @override
  String get profile_deleteAccountTitle => 'Delete account';

  @override
  String get profile_deleteAccountConfirm =>
      'This will deactivate your account. This cannot be undone.';

  @override
  String get profile_detailsSection => 'Details';

  @override
  String get profile_memberSince => 'Member since';

  @override
  String get profile_lastUpdate => 'Last update';

  @override
  String get profile_roleSuperuser => 'SUPERUSER';

  @override
  String get profile_roleMember => 'MEMBER';

  @override
  String get profile_appUpdate => 'App update';

  @override
  String get profile_updateAvailable => 'Update available';

  @override
  String get profile_upToDate => 'You\'re up to date';

  @override
  String get update_title => 'Update available';

  @override
  String update_message(String version) {
    return 'Version $version is available. Update to get the latest features and fixes.';
  }

  @override
  String get update_action => 'Update';

  @override
  String get update_later => 'Later';

  @override
  String get map_toggleTransactions => 'Expenses';

  @override
  String get map_toggleHomes => 'Homes';

  @override
  String get map_toggleVendors => 'Vendors';
}
