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
  String get common_ok => 'OK';

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
  String get profile_setInactive => 'Set inactive';

  @override
  String get profile_setActive => 'Set active';

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
  String get cars_setInactive => 'Set inactive';

  @override
  String get cars_setActive => 'Set active';

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
  String get pets_sectionTitle => 'Pets';

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
  String get calendar_eventos => 'Events';

  @override
  String get calendar_movimientos => 'Transactions';

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
  String get notifications_markRead => 'Mark read';

  @override
  String get notifications_markUnread => 'Mark unread';

  @override
  String get transaction_new => 'New transaction';

  @override
  String get transaction_fallbackTitle => 'Transaction';

  @override
  String get transaction_fallbackAccount => 'Account';

  @override
  String get selectLocation_title => 'Select location';

  @override
  String get selectLocation_setButton => 'Set location';

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

  @override
  String get bankAccount_accountNotFound => 'Account not found';

  @override
  String get bankAccount_account => 'Account';

  @override
  String get bankAccount_period => 'Period';

  @override
  String get bankAccount_periodThisMonth => 'This month';

  @override
  String get bankAccount_periodLast6Months => 'Last 6 months';

  @override
  String get bankAccount_periodLast12Months => 'Last 12 months';

  @override
  String get bankAccount_periodMonth => 'Month';

  @override
  String get bankAccount_period6Months => '6 months';

  @override
  String get bankAccount_period1Year => '1 year';

  @override
  String bankAccount_balancePeriod(String period) {
    return 'Balance · $period';
  }

  @override
  String bankAccount_incomeVsExpense(String period) {
    return 'Income vs expense · $period';
  }

  @override
  String get bankAccount_recurringTransactions => 'Recurring transactions';

  @override
  String get bankAccount_noGoalsYet => 'No goals yet — tap to add one';

  @override
  String get bankAccount_actionLogs => 'Action logs';

  @override
  String get bankAccount_noActivityInWindow => 'No activity in this window';

  @override
  String get bankAccount_income => 'Income';

  @override
  String get bankAccount_expense => 'Expense';

  @override
  String get bankAccount_date => 'Date';

  @override
  String get bankAccount_action => 'Action';

  @override
  String get bankAccount_amount => 'Amount';

  @override
  String get bankAccount_newTransaction => 'New transaction';

  @override
  String get bankAccount_newGoal => 'New goal';

  @override
  String get bankAccount_editGoal => 'Edit goal';

  @override
  String get bankAccount_addGoal => 'Add goal';

  @override
  String get bankAccount_addCard => 'Add card';

  @override
  String get bankAccount_setAsPrimary => 'Set as primary';

  @override
  String get settings_homes => 'Homes';

  @override
  String get settings_homesSub => 'Manage household locations';

  @override
  String get settings_googleCalendar => 'Google Calendar';

  @override
  String get settings_googleCalendarSub =>
      'Connect a Google account to sync events';

  @override
  String get settings_startDayMonday => 'Monday';

  @override
  String get settings_startDaySaturday => 'Saturday';

  @override
  String get settings_startDaySunday => 'Sunday';

  @override
  String settings_permissionAccess(String permission) {
    return '$permission access';
  }

  @override
  String settings_permissionMessage(String permission) {
    return 'Hestia needs $permission access. Tap \"Open Settings\" to enable it.';
  }

  @override
  String get settings_disableLocationMessage =>
      'To disable location access, open Settings → Hestia → Location and turn it off.';

  @override
  String get settings_disableNotificationsMessage =>
      'To disable notifications, open Settings → Hestia → Notifications and turn them off.';

  @override
  String get settings_openSettings => 'Open Settings';

  @override
  String get settings_syncNow => 'Sync now';

  @override
  String get settings_disconnect => 'Disconnect';

  @override
  String get settings_calendarSynced => 'Calendar synced';

  @override
  String get settings_calendarDisconnected => 'Google Calendar disconnected';

  @override
  String get settings_calendarConnected => 'Google Calendar connected';

  @override
  String get healthRecord_addRecord => 'Add Record';

  @override
  String get healthRecord_editRecord => 'Edit Record';

  @override
  String get healthRecord_saveChanges => 'Save Changes';

  @override
  String get healthRecord_couldNotSave => 'Could not save';

  @override
  String get healthRecord_type => 'Type';

  @override
  String get healthRecord_title => 'Title';

  @override
  String get healthRecord_titlePlaceholder => 'e.g. Annual vaccination';

  @override
  String get healthRecord_vetClinic => 'Vet / Clinic';

  @override
  String get healthRecord_optional => 'Optional';

  @override
  String get healthRecord_date => 'Date';

  @override
  String get healthRecord_nextDueDate => 'Next due date';

  @override
  String get healthRecord_costEuro => 'Cost (€)';

  @override
  String get healthRecord_notes => 'Notes';

  @override
  String get healthRecord_notesPlaceholder => 'Optional notes…';

  @override
  String get notifications_inbox => 'Inbox';

  @override
  String get notifications_markAll => 'Mark all';

  @override
  String get notifications_allMarkedRead => 'All marked as read';

  @override
  String get notifications_noNotificationsYet => 'No notifications yet';

  @override
  String get notifications_signInPrompt => 'Sign in to view notifications.';

  @override
  String get notifications_delete => 'Delete';

  @override
  String get notifications_deleteTitle => 'Delete notification';

  @override
  String get notifications_deleteConfirm => 'This action cannot be undone.';

  @override
  String get notifications_deleted => 'Notification deleted';

  @override
  String get notifications_markedRead => 'Marked as read';

  @override
  String get notifications_markedUnread => 'Marked unread';

  @override
  String get notifications_allCaughtUp => 'All caught up';

  @override
  String notifications_unreadCount(int count) {
    return '$count unread';
  }

  @override
  String get notifications_yesterday => 'Yesterday';

  @override
  String notifications_daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get goals_goalTitle => 'Goal';

  @override
  String get goals_saved => 'SAVED';

  @override
  String get goals_remaining => 'Remaining';

  @override
  String get goals_monthlyNeed => 'Monthly need';

  @override
  String get goals_daysLeft => 'Days left';

  @override
  String get goals_linkedSource => 'Linked source';

  @override
  String get goals_contributions => 'Contributions';

  @override
  String get goals_addContribution => 'Add contribution';

  @override
  String get fuelEntry_addFillUp => 'Add fill-up';

  @override
  String get fuelEntry_editFillUp => 'Edit fill-up';

  @override
  String get fuelEntry_filledAt => 'Filled at';

  @override
  String get fuelEntry_odometerKm => 'Odometer (km)';

  @override
  String get fuelEntry_liters => 'Liters';

  @override
  String get fuelEntry_pricePerLiter => 'Price per liter (€)';

  @override
  String get fuelEntry_totalEuro => 'Total (€)';

  @override
  String get fuelEntry_station => 'STATION';

  @override
  String get fuelEntry_fullTank => 'Full tank';

  @override
  String get fuelEntry_alsoCreateTransaction => 'Also create transaction';

  @override
  String get fuelEntry_comingSoon => 'Coming soon';

  @override
  String get fuelEntry_notes => 'NOTES';

  @override
  String get fuelEntry_notesPlaceholder => 'Optional notes';

  @override
  String get fuelEntry_added => 'Fuel entry added';

  @override
  String get fuelEntry_updated => 'Fuel entry updated';

  @override
  String get fuelEntry_done => 'Done';

  @override
  String get car_newCar => 'New car';

  @override
  String get car_editCar => 'Edit car';

  @override
  String get car_name => 'Name';

  @override
  String get car_make => 'Make';

  @override
  String get car_model => 'Model';

  @override
  String get car_year => 'Year';

  @override
  String get car_licensePlate => 'License plate';

  @override
  String get car_gasoline => 'Gasoline';

  @override
  String get car_diesel => 'Diesel';

  @override
  String get car_electric => 'Electric';

  @override
  String get car_hybrid => 'Hybrid';

  @override
  String get car_tankCapacity => 'Tank capacity (L)';

  @override
  String get car_currentOdometer => 'Current odometer (km)';

  @override
  String get car_status => 'Status';

  @override
  String get car_statusActive => 'Active';

  @override
  String get car_statusInactive => 'Inactive';

  @override
  String get car_drivers => 'DRIVERS';

  @override
  String get fuelAnalytics_avgL100km => 'Avg L/100km';

  @override
  String get fuelAnalytics_costPerKm => 'Cost / km';

  @override
  String get fuelAnalytics_last30Days => 'Last 30 days';

  @override
  String get fuelAnalytics_consumption => 'CONSUMPTION (L/100KM)';

  @override
  String get fuelAnalytics_monthlyCost => 'MONTHLY COST';

  @override
  String get fuelAnalytics_noDataYet => 'No data yet';

  @override
  String get fuelAnalytics_needFullTanks => 'Need at least 2 full tanks';

  @override
  String get bankAccountForm_newAccount => 'New account';

  @override
  String get bankAccountForm_editAccount => 'Edit account';

  @override
  String get bankAccountForm_bank => 'BANK';

  @override
  String get bankAccountForm_selectBank => 'Select bank';

  @override
  String get bankAccountForm_accountName => 'ACCOUNT NAME';

  @override
  String get bankAccountForm_accountNamePlaceholder => 'e.g. Main Checking';

  @override
  String get bankAccountForm_ibanOptional => 'IBAN (OPTIONAL)';

  @override
  String get bankAccountForm_type => 'TYPE';

  @override
  String get bankAccountForm_checking => 'Checking';

  @override
  String get bankAccountForm_savings => 'Savings';

  @override
  String get bankAccountForm_credit => 'Credit';

  @override
  String get bankAccountForm_cash => 'Cash';

  @override
  String get bankAccountForm_investment => 'Investment';

  @override
  String get bankAccountForm_ownership => 'OWNERSHIP';

  @override
  String get bankAccountForm_personal => 'Personal';

  @override
  String get bankAccountForm_shared => 'Shared';

  @override
  String get bankAccountForm_initialBalance => 'INITIAL BALANCE';

  @override
  String get bankAccountForm_createAccount => 'Create account';

  @override
  String get bankAccountForm_saveChanges => 'Save changes';

  @override
  String get bankAccountForm_accountCreated => 'Account created';

  @override
  String get bankAccountForm_accountUpdated => 'Account updated';

  @override
  String get bankAccountForm_couldNotSave => 'Could not save';

  @override
  String get bankAccountForm_enterName => 'Enter an account name';

  @override
  String get bankAccountForm_searchBank => 'Search bank…';

  @override
  String get bankAccountForm_noneEnterManually => 'None / enter manually';

  @override
  String get bankAccountForm_selectBankTitle => 'Select bank';

  @override
  String get recurringTransactions_title => 'Recurring';

  @override
  String get recurringTransactions_noTransactionsYet =>
      'No recurring transactions yet';

  @override
  String get recurringTransactions_recurring => 'Recurring';

  @override
  String get homes_title => 'Homes';

  @override
  String get homes_noHomesYet => 'No homes yet';

  @override
  String get homes_addHomeDescription =>
      'Add your home to associate it with transactions.';

  @override
  String get homes_addHomeHint => 'Tap';

  @override
  String get homes_addHomeHintSuffix => 'above to add your first home.';

  @override
  String get homes_addHome => 'Add home';

  @override
  String get homes_editHome => 'Edit home';

  @override
  String get homes_name => 'Name';

  @override
  String get homes_namePlaceholder => 'e.g. Main Apartment';

  @override
  String get homes_address => 'Address';

  @override
  String get homes_addressPlaceholder => 'Full street address';

  @override
  String get homes_nameRequired => 'Name is required';

  @override
  String get homes_addressRequired => 'Address is required';

  @override
  String get homes_saveChanges => 'Save changes';

  @override
  String get homes_deleteLabel => 'Delete';

  @override
  String get homes_editLabel => 'Edit';

  @override
  String get transaction_expense => 'Expense';

  @override
  String get transaction_income => 'Income';

  @override
  String get transaction_transfer => 'Transfer';

  @override
  String get transaction_category => 'Category';

  @override
  String get transaction_selectCategory => 'Select';

  @override
  String get transaction_bankAccount => 'Bank account';

  @override
  String get transaction_fromAccount => 'From account';

  @override
  String get transaction_toAccount => 'To account';

  @override
  String get transaction_card => 'Card';

  @override
  String get transaction_source => 'Source';

  @override
  String get transaction_sourceOptional => 'Optional';

  @override
  String get transaction_sourceSub => 'Merchant, employer, service';

  @override
  String get transaction_date => 'Date';

  @override
  String get transaction_repeat => 'Repeat';

  @override
  String get transaction_oneTime => 'One-time';

  @override
  String get transaction_recurring => 'Recurring';

  @override
  String get transaction_addNote => 'Add a note…';

  @override
  String get transaction_attachLocation => 'Attach location';

  @override
  String get transaction_locationOn => 'On';

  @override
  String get transaction_locationOff => 'Off';

  @override
  String get transaction_useGps => 'Use GPS';

  @override
  String get transaction_map => 'Map';

  @override
  String get transaction_today => 'Today';

  @override
  String get transaction_update => 'Update';

  @override
  String get transaction_saveTransaction => 'Save transaction';

  @override
  String get transaction_expenseSaved => 'Expense saved';

  @override
  String get transaction_incomeSaved => 'Income saved';

  @override
  String get transaction_deleted => 'Transaction deleted';

  @override
  String get transaction_somethingWentWrong => 'Something went wrong';

  @override
  String get transaction_selectCategoryTitle => 'Select category';

  @override
  String get transaction_selectBankAccount => 'Select bank account';

  @override
  String get transaction_selectFromAccount => 'Select from account';

  @override
  String get transaction_selectDestinationAccount =>
      'Select destination account';

  @override
  String get transaction_selectCard => 'Select card';

  @override
  String get transaction_noCard => 'None';

  @override
  String get transaction_noCardSub => 'No card';

  @override
  String get transaction_currency => 'Currency';

  @override
  String get transaction_counterpartySource => 'Counterparty source';

  @override
  String get transaction_selectDate => 'Select date';

  @override
  String get transaction_newSource => 'New source';

  @override
  String get transaction_editSource => 'Edit source';

  @override
  String get card_primary => 'PRIMARY';

  @override
  String get card_virtual => 'VIRTUAL';

  @override
  String get card_expires => 'EXPIRES';

  @override
  String get appointment_duration => 'Duration';

  @override
  String get appointment_pinLocation => 'Pin location on map';

  @override
  String get appointment_signInRequired => 'Sign in required';

  @override
  String get appointment_categoryHealth => 'Health';

  @override
  String get appointment_categoryVehicle => 'Vehicle';

  @override
  String get appointment_categoryBeauty => 'Beauty';

  @override
  String get appointment_categoryWork => 'Work';

  @override
  String get appointment_categoryPersonal => 'Personal';

  @override
  String get appointment_categoryOther => 'Other';

  @override
  String get bankAccount_goalsOnThisAccount => 'Goals on this account';

  @override
  String homes_coordinatesNote(String lat, String lng) {
    return 'Coordinates: $lat, $lng\nTap the map in the full map view to pick a precise location.';
  }

  @override
  String get card_addCard => 'Add Card';

  @override
  String get card_editCard => 'Edit Card';

  @override
  String get card_network => 'Network';

  @override
  String get card_last4Digits => 'Last 4 digits';

  @override
  String get card_cardholderName => 'Cardholder name';

  @override
  String get card_month => 'Month';

  @override
  String get card_year => 'Year';

  @override
  String get card_cardholderOwner => 'Cardholder owner';

  @override
  String get card_primaryCard => 'Primary card';

  @override
  String get card_virtualCard => 'Virtual card';

  @override
  String get card_saveChanges => 'Save Changes';

  @override
  String get card_none => 'None';

  @override
  String get card_last4Error => 'Last 4 digits must be exactly 4 numbers';

  @override
  String get card_cardholderRequired => 'Cardholder name is required';

  @override
  String get card_setAsPrimary => 'Set as primary';

  @override
  String get transaction_relatedTo => 'Related to';

  @override
  String get transaction_createNewSource => 'Create new source';

  @override
  String transaction_amountLabel(String currency) {
    return 'AMOUNT · $currency';
  }

  @override
  String get transaction_relatedToNone => 'None';

  @override
  String appointment_durationMinutes(int n) {
    return '$n min';
  }

  @override
  String appointment_durationHours(int n) {
    return '${n}h';
  }

  @override
  String appointment_durationHoursMinutes(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String get appointment_reminder1Day => '1 day';

  @override
  String appointment_reminderDays(int n) {
    return '$n days';
  }

  @override
  String get maintenance_addRecord => 'Add Maintenance Record';

  @override
  String get maintenance_editRecord => 'Edit Maintenance Record';

  @override
  String get maintenance_saveChanges => 'Save Changes';

  @override
  String get maintenance_couldNotSave => 'Could not save';

  @override
  String get maintenance_title => 'Title';

  @override
  String get maintenance_titlePlaceholder => 'e.g. Oil change';

  @override
  String get maintenance_type => 'Type';

  @override
  String get maintenance_mechanic => 'Mechanic';

  @override
  String get maintenance_itv => 'ITV / Inspection';

  @override
  String get maintenance_tires => 'Tires';

  @override
  String get maintenance_oil => 'Oil Change';

  @override
  String get maintenance_insurance => 'Insurance';

  @override
  String get maintenance_other => 'Other';

  @override
  String get maintenance_workshop => 'Workshop';

  @override
  String get maintenance_workshopPlaceholder => 'Optional';

  @override
  String get maintenance_date => 'Date';

  @override
  String get maintenance_nextDueDate => 'Next due date';

  @override
  String get maintenance_odometerKm => 'Odometer (km)';

  @override
  String get maintenance_cost => 'Cost (€)';

  @override
  String get maintenance_createExpense => 'Create expense transaction';

  @override
  String get maintenance_bankAccount => 'Bank account';

  @override
  String get maintenance_notes => 'Notes';

  @override
  String get maintenance_notesPlaceholder => 'Optional notes…';

  @override
  String get maintenance_records => 'Maintenance records';

  @override
  String get maintenance_noRecordsYet => 'No maintenance records yet';

  @override
  String get maintenance_addFirst => 'Add your first maintenance record';

  @override
  String get maintenance_deleteTitle => 'Delete record';

  @override
  String maintenance_deleteConfirm(String title) {
    return 'Remove \"$title\"? This cannot be undone.';
  }

  @override
  String maintenance_costEuro(String amount) {
    return '$amount €';
  }
}
