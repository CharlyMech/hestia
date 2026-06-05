// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get common_save => 'Guardar';

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_done => 'Hecho';

  @override
  String get common_delete => 'Eliminar';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_add => 'Añadir';

  @override
  String get common_close => 'Cerrar';

  @override
  String get common_today => 'Hoy';

  @override
  String get common_viewAll => 'Ver todo';

  @override
  String get common_seeAll => 'Ver todo';

  @override
  String get common_signOut => 'Cerrar sesión';

  @override
  String get auth_signInFailed => 'Error al iniciar sesión';

  @override
  String get auth_tagline => 'Gestiona las finanzas del hogar en familia';

  @override
  String get auth_email => 'Correo electrónico';

  @override
  String get auth_password => 'Contraseña';

  @override
  String get auth_showPassword => 'Mostrar contraseña';

  @override
  String get auth_signIn => 'Iniciar sesión';

  @override
  String get auth_or => 'o';

  @override
  String get auth_signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get nav_dashboard => 'Inicio';

  @override
  String get nav_calendar => 'Calendario';

  @override
  String get nav_shopping => 'Compras';

  @override
  String get nav_accounts => 'Cuentas';

  @override
  String get nav_pets => 'Mascotas';

  @override
  String get nav_cars => 'Coches';

  @override
  String get settings_carsModule => 'Seguimiento de coches';

  @override
  String get settings_carsTitle => 'Coches';

  @override
  String get settings_carsSub => 'Coches y repostajes';

  @override
  String get settings_general => 'General';

  @override
  String get settings_modules => 'Módulos';

  @override
  String get settings_dataManagement => 'Gestión de datos';

  @override
  String get settings_categoriesTab => 'Categorías';

  @override
  String get settings_sourcesTab => 'Fuentes';

  @override
  String get settings_dateFormat => 'Formato de fecha';

  @override
  String get settings_dateFormatMdy => 'MM/DD/AAAA';

  @override
  String get settings_dateFormatDmy => 'DD/MM/AAAA';

  @override
  String get settings_dateFormatYmd => 'AAAA-MM-DD';

  @override
  String get settings_allowLocation => 'Permitir ubicación';

  @override
  String get settings_allowNotifications => 'Permitir notificaciones';

  @override
  String get settings_faceIdUnlock => 'Desbloqueo con Face ID';

  @override
  String get settings_viewCarsData => 'Ver datos de coches';

  @override
  String get profile_edit => 'Editar';

  @override
  String get notifications_unread => 'No leídas';

  @override
  String get notifications_read => 'Leídas';

  @override
  String get notifications_showRead => 'Mostrar leídas';

  @override
  String get notifications_hideRead => 'Ocultar leídas';

  @override
  String get cars_title => 'Coches';

  @override
  String get cars_analyticsTitle => 'Análisis del coche';

  @override
  String get cars_fuelType => 'Tipo de combustible';

  @override
  String get cars_noVehiclesYet => 'Aún no hay vehículos';

  @override
  String get cars_tapToAdd => 'Toca + para añadir uno';

  @override
  String get cars_statusActive => 'Activo';

  @override
  String get cars_statusSold => 'Vendido';

  @override
  String get cars_statusScrap => 'Desguace';

  @override
  String cars_odometerKm(String km) {
    return '$km km';
  }

  @override
  String get cars_carTitle => 'Coche';

  @override
  String get cars_notFound => 'No encontrado';

  @override
  String get cars_deleteCarTitle => 'Eliminar coche';

  @override
  String cars_deleteCarConfirm(String name) {
    return '¿Eliminar $name? Esta acción no se puede deshacer.';
  }

  @override
  String get cars_statusInactive => 'Inactivo';

  @override
  String get cars_addFillUp => 'Añadir repostaje';

  @override
  String get cars_recentFillUps => 'Repostajes recientes';

  @override
  String get cars_seeAnalytics => 'Ver análisis';

  @override
  String get cars_noFillUpsYet => 'Aún no hay repostajes';

  @override
  String get cars_fillUpFullSuffix => ' · lleno';

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
  String get pets_noPetsYet => 'Aún no hay mascotas';

  @override
  String get pets_tapToAdd => 'Toca + para añadir una';

  @override
  String get pets_speciesDog => 'Perro';

  @override
  String get pets_speciesCat => 'Gato';

  @override
  String get pets_speciesBird => 'Pájaro';

  @override
  String get pets_speciesRabbit => 'Conejo';

  @override
  String get pets_speciesFish => 'Pez';

  @override
  String get pets_speciesReptile => 'Reptil';

  @override
  String get pets_speciesOther => 'Otro';

  @override
  String pets_ageYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String get pets_genderMale => 'M';

  @override
  String get pets_genderFemale => 'F';

  @override
  String get pets_title => 'Mascota';

  @override
  String get pets_notFound => 'No encontrado';

  @override
  String get pets_deletePetTitle => 'Eliminar mascota';

  @override
  String pets_deletePetConfirm(String name) {
    return '¿Eliminar $name? Esta acción no se puede deshacer.';
  }

  @override
  String get pets_deleteRecordTitle => 'Eliminar registro';

  @override
  String pets_deleteRecordConfirm(String title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String get pets_setInactive => 'Marcar inactiva';

  @override
  String get pets_setActive => 'Marcar activa';

  @override
  String get pets_healthRecords => 'Registros de salud';

  @override
  String get pets_noHealthRecordsYet => 'Aún no hay registros de salud';

  @override
  String get pets_genderMaleFull => 'Macho';

  @override
  String get pets_genderFemaleFull => 'Hembra';

  @override
  String get pets_genderUnknown => 'Desconocido';

  @override
  String pets_weightKg(String weight) {
    return '$weight kg';
  }

  @override
  String get pets_recordNextDue => ' · Próximo: ';

  @override
  String pets_costEuro(String amount) {
    return '€$amount';
  }

  @override
  String get pets_healthTypeVaccine => 'Vacuna';

  @override
  String get pets_healthTypeVet => 'Visita veterinaria';

  @override
  String get pets_healthTypeMedication => 'Medicación';

  @override
  String get pets_healthTypeGrooming => 'Peluquería';

  @override
  String get pets_healthTypeDeworming => 'Desparasitación';

  @override
  String get pets_healthTypeOther => 'Otro';

  @override
  String get settings_title => 'Ajustes';

  @override
  String get settings_appearance => 'Apariencia';

  @override
  String get settings_theme => 'Tema';

  @override
  String get settings_themeLight => 'Claro';

  @override
  String get settings_themeDark => 'Oscuro';

  @override
  String get settings_themeSystem => 'Sistema';

  @override
  String get settings_language => 'Idioma';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_languageEs => 'Español';

  @override
  String get settings_startDay => 'Primer día de la semana';

  @override
  String get settings_use24h => 'Reloj 24 horas';

  @override
  String get settings_biometric => 'Face ID';

  @override
  String get dashboard_overview => 'Resumen';

  @override
  String get dashboard_greetingMorning => 'Buenos días';

  @override
  String get dashboard_greetingAfternoon => 'Buenas tardes';

  @override
  String get dashboard_greetingEvening => 'Buenas noches';

  @override
  String get dashboard_accounts => 'Cuentas';

  @override
  String get dashboard_spending => 'Gastos';

  @override
  String get dashboard_noExpensesInWindow => 'Sin gastos en este periodo';

  @override
  String get dashboard_activeGoals => 'Objetivos activos';

  @override
  String get dashboard_recent => 'Reciente';

  @override
  String get dashboard_map => 'Mapa';

  @override
  String get dashboard_balanceTrend => 'Evolución del saldo';

  @override
  String get dashboard_monthlyNet => 'Neto mensual';

  @override
  String get dashboard_noTransactionsYet => 'Aún no hay transacciones';

  @override
  String get dashboard_activeShoppingSession => 'Sesión de compras activa';

  @override
  String dashboard_activeShoppingSessions(int count) {
    return '$count sesiones activas';
  }

  @override
  String get bankAccounts_title => 'Cuentas';

  @override
  String get bankAccounts_totalNetWorth => 'Patrimonio total';

  @override
  String get bankAccounts_addCard => 'Añadir cuenta';

  @override
  String get bankAccounts_shared => 'Compartida';

  @override
  String get bankAccounts_personal => 'Personal';

  @override
  String get bankAccounts_noInstitution => 'Sin entidad';

  @override
  String get goals_title => 'Objetivos';

  @override
  String get goals_addGoal => 'Añadir objetivo';

  @override
  String get goals_global => 'Todos los objetivos';

  @override
  String get goals_perAccount => 'Objetivos de esta cuenta';

  @override
  String get calendar_title => 'Calendario';

  @override
  String get calendar_newAppointment => 'Nueva cita';

  @override
  String get calendar_appointment => 'Cita';

  @override
  String get calendar_allDay => 'Todo el día';

  @override
  String get calendar_filterAll => 'Ver de todos';

  @override
  String get calendar_filterMine => 'Solo míos';

  @override
  String get calendar_eventos => 'Eventos';

  @override
  String get calendar_movimientos => 'Movimientos';

  @override
  String get shopping_title => 'Compras';

  @override
  String get shopping_sessionsTab => 'Sesiones';

  @override
  String get shopping_active => 'Activa';

  @override
  String get shopping_templatesTab => 'Plantillas';

  @override
  String get shopping_history => 'Historial';

  @override
  String get shopping_newList => 'Nueva lista';

  @override
  String get shopping_finishAndPay => 'Finalizar y pagar';

  @override
  String get shopping_cancelList => 'Cancelar lista';

  @override
  String get shopping_cancelConfirmTitle => '¿Cancelar esta lista de compras?';

  @override
  String get shopping_cancelConfirmBody =>
      'La lista se archivará como cancelada y no podrá editarse.';

  @override
  String get shopping_startSession => 'Empezar compra';

  @override
  String get shopping_startFromTemplate => 'Empezar desde plantilla';

  @override
  String get shopping_newTemplate => 'Nueva plantilla';

  @override
  String get shopping_noActiveSessions =>
      'Sin sesiones activas — pulsa play para empezar';

  @override
  String get shopping_noFinishedSessions => 'Aún no hay sesiones finalizadas';

  @override
  String get shopping_sharedCollaboration =>
      'Compartida · cualquiera del hogar puede colaborar';

  @override
  String get shopping_createTemplate => 'Crear nueva plantilla';

  @override
  String get shopping_kindTemplate => 'Plantilla';

  @override
  String get shopping_kindSession => 'Sesión';

  @override
  String get shopping_statusPaid => 'Pagada';

  @override
  String get shopping_statusCancelled => 'Cancelada';

  @override
  String get notifications_title => 'Notificaciones';

  @override
  String get notifications_markAllRead => 'Marcar todo como leído';

  @override
  String get notifications_showAll => 'Ver todas';

  @override
  String get notifications_empty => 'Sin notificaciones';

  @override
  String get notifications_markRead => 'Marcar como leída';

  @override
  String get notifications_markUnread => 'Marcar como no leída';

  @override
  String get transaction_new => 'Nueva transacción';

  @override
  String get transaction_fallbackTitle => 'Transacción';

  @override
  String get transaction_fallbackAccount => 'Cuenta';

  @override
  String get transactionLocation_mapTitle => 'Elegir ubicación';

  @override
  String get transactionLocation_statsTitle => 'Resumen de ubicaciones';

  @override
  String get transactionLocation_statsCount => 'marcadores geolocalizados';

  @override
  String get transactionLocation_empty =>
      'Aún no hay transacciones con ubicación.';

  @override
  String get settings_locationSection => 'Ubicación';

  @override
  String get settings_locationStats => 'Mapa y marcadores';

  @override
  String get settings_locationStatsSub =>
      'Transacciones recientes guardadas con GPS';

  @override
  String get settings_locationPermission => 'Permiso';

  @override
  String get settings_locationRequest => 'Solicitar acceso';

  @override
  String get settings_locationOpenSettings => 'Abrir ajustes del sistema';

  @override
  String get settings_locationPermGranted => 'Permitido mientras usas la app';

  @override
  String get settings_locationPermDenied => 'Denegado — pulsa Solicitar acceso';

  @override
  String get settings_locationPermForever =>
      'Bloqueado — actívalo en Ajustes del sistema';

  @override
  String get settings_locationPermSvcOff =>
      'Los servicios de ubicación están desactivados';

  @override
  String get common_none => 'Ninguno';

  @override
  String get common_notSet => 'Sin definir';

  @override
  String get appointments_title => 'Título';

  @override
  String get appointments_titlePlaceholder => 'Dentista · Gym · Reunión…';

  @override
  String get appointments_shareHousehold => 'Compartir con el hogar';

  @override
  String get appointments_allDay => 'Todo el día';

  @override
  String get appointments_date => 'Fecha';

  @override
  String get appointments_startTime => 'Hora de inicio';

  @override
  String get appointments_endTime => 'Hora de fin';

  @override
  String get appointments_category => 'Categoría';

  @override
  String get appointments_reminders => 'Recordatorios';

  @override
  String get appointments_color => 'Color';

  @override
  String get appointments_location => 'Ubicación';

  @override
  String get appointments_notes => 'Notas';

  @override
  String get appointments_save => 'Guardar';

  @override
  String get calendar_noEvents => 'Sin eventos';

  @override
  String get calendar_deleteEvent => 'Eliminar evento';

  @override
  String get calendar_deleteEventConfirm => 'Esta acción no se puede deshacer.';

  @override
  String get bankAccounts_myAccounts => 'Mis cuentas';

  @override
  String get bankAccounts_others => 'Otras cuentas';

  @override
  String get bankAccounts_showOthers => 'Ver otras cuentas';

  @override
  String get bankAccounts_hideOthers => 'Ocultar otras cuentas';

  @override
  String get bankAccounts_signInPrompt => 'Inicia sesión para ver las cuentas';

  @override
  String get profile_title => 'Perfil';

  @override
  String get profile_signInPrompt => 'Inicia sesión para ver el perfil';

  @override
  String get profile_editProfile => 'Editar perfil';

  @override
  String get profile_displayName => 'Nombre de usuario';

  @override
  String get profile_preferredCurrency => 'Moneda preferida';

  @override
  String get profile_calendarColor => 'Color de calendario';

  @override
  String get profile_birthDate => 'Fecha de nacimiento';

  @override
  String get profile_deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get profile_deleteAccountConfirm =>
      'Esto desactivará tu cuenta. Esta acción no se puede deshacer.';

  @override
  String get profile_detailsSection => 'Detalles';

  @override
  String get profile_memberSince => 'Miembro desde';

  @override
  String get profile_lastUpdate => 'Última actualización';

  @override
  String get profile_roleSuperuser => 'SUPERUSUARIO';

  @override
  String get profile_roleMember => 'MIEMBRO';

  @override
  String get profile_appUpdate => 'Actualización';

  @override
  String get profile_updateAvailable => 'Actualización disponible';

  @override
  String get profile_upToDate => 'Estás al día';

  @override
  String get update_title => 'Actualización disponible';

  @override
  String update_message(String version) {
    return 'La versión $version está disponible. Actualiza para obtener las últimas funciones y correcciones.';
  }

  @override
  String get update_action => 'Actualizar';

  @override
  String get update_later => 'Más tarde';

  @override
  String get map_toggleTransactions => 'Gastos';

  @override
  String get map_toggleHomes => 'Casas';

  @override
  String get map_toggleVendors => 'Locales';
}
