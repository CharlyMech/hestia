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
  String get common_ok => 'Aceptar';

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
  String get profile_setInactive => 'Marcar inactivo';

  @override
  String get profile_setActive => 'Marcar activo';

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
  String get cars_setInactive => 'Marcar inactivo';

  @override
  String get cars_setActive => 'Marcar activo';

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
  String get pets_sectionTitle => 'Mascotas';

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
  String get notifications_markRead => 'Marcar leída';

  @override
  String get notifications_markUnread => 'Marcar no leída';

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

  @override
  String get bankAccount_accountNotFound => 'Cuenta no encontrada';

  @override
  String get bankAccount_account => 'Cuenta';

  @override
  String get bankAccount_period => 'Período';

  @override
  String get bankAccount_periodThisMonth => 'Este mes';

  @override
  String get bankAccount_periodLast6Months => 'Últimos 6 meses';

  @override
  String get bankAccount_periodLast12Months => 'Últimos 12 meses';

  @override
  String get bankAccount_periodMonth => 'Mes';

  @override
  String get bankAccount_period6Months => '6 meses';

  @override
  String get bankAccount_period1Year => '1 año';

  @override
  String bankAccount_balancePeriod(String period) {
    return 'Saldo · $period';
  }

  @override
  String bankAccount_incomeVsExpense(String period) {
    return 'Ingresos vs gastos · $period';
  }

  @override
  String get bankAccount_recurringTransactions => 'Transacciones recurrentes';

  @override
  String get bankAccount_noGoalsYet => 'Sin objetivos — toca para añadir uno';

  @override
  String get bankAccount_actionLogs => 'Registro de acciones';

  @override
  String get bankAccount_noActivityInWindow => 'Sin actividad en este período';

  @override
  String get bankAccount_income => 'Ingreso';

  @override
  String get bankAccount_expense => 'Gasto';

  @override
  String get bankAccount_date => 'Fecha';

  @override
  String get bankAccount_action => 'Acción';

  @override
  String get bankAccount_amount => 'Importe';

  @override
  String get bankAccount_newTransaction => 'Nueva transacción';

  @override
  String get bankAccount_newGoal => 'Nuevo objetivo';

  @override
  String get bankAccount_editGoal => 'Editar objetivo';

  @override
  String get bankAccount_addGoal => 'Añadir objetivo';

  @override
  String get bankAccount_addCard => 'Añadir tarjeta';

  @override
  String get bankAccount_setAsPrimary => 'Establecer como principal';

  @override
  String get settings_homes => 'Casas';

  @override
  String get settings_homesSub => 'Gestionar ubicaciones del hogar';

  @override
  String get settings_googleCalendar => 'Google Calendar';

  @override
  String get settings_googleCalendarSub =>
      'Conecta una cuenta de Google para sincronizar eventos';

  @override
  String get settings_startDayMonday => 'Lunes';

  @override
  String get settings_startDaySaturday => 'Sábado';

  @override
  String get settings_startDaySunday => 'Domingo';

  @override
  String settings_permissionAccess(String permission) {
    return 'Acceso a $permission';
  }

  @override
  String settings_permissionMessage(String permission) {
    return 'Hestia necesita acceso a $permission. Toca \"Abrir ajustes\" para habilitarlo.';
  }

  @override
  String get settings_disableLocationMessage =>
      'Para desactivar el acceso a la ubicación, ve a Ajustes → Hestia → Ubicación y desactívalo.';

  @override
  String get settings_disableNotificationsMessage =>
      'Para desactivar las notificaciones, ve a Ajustes → Hestia → Notificaciones y desactívalas.';

  @override
  String get settings_openSettings => 'Abrir ajustes';

  @override
  String get settings_syncNow => 'Sincronizar ahora';

  @override
  String get settings_disconnect => 'Desconectar';

  @override
  String get settings_calendarSynced => 'Calendario sincronizado';

  @override
  String get settings_calendarDisconnected => 'Google Calendar desconectado';

  @override
  String get settings_calendarConnected => 'Google Calendar conectado';

  @override
  String get healthRecord_addRecord => 'Añadir registro';

  @override
  String get healthRecord_editRecord => 'Editar registro';

  @override
  String get healthRecord_saveChanges => 'Guardar cambios';

  @override
  String get healthRecord_couldNotSave => 'No se pudo guardar';

  @override
  String get healthRecord_type => 'Tipo';

  @override
  String get healthRecord_title => 'Título';

  @override
  String get healthRecord_titlePlaceholder => 'p. ej. Vacunación anual';

  @override
  String get healthRecord_vetClinic => 'Veterinario / Clínica';

  @override
  String get healthRecord_optional => 'Opcional';

  @override
  String get healthRecord_date => 'Fecha';

  @override
  String get healthRecord_nextDueDate => 'Próxima fecha';

  @override
  String get healthRecord_costEuro => 'Coste (€)';

  @override
  String get healthRecord_notes => 'Notas';

  @override
  String get healthRecord_notesPlaceholder => 'Notas opcionales…';

  @override
  String get notifications_inbox => 'Bandeja';

  @override
  String get notifications_markAll => 'Marcar todo';

  @override
  String get notifications_allMarkedRead => 'Todo marcado como leído';

  @override
  String get notifications_noNotificationsYet => 'Aún no hay notificaciones';

  @override
  String get notifications_signInPrompt =>
      'Inicia sesión para ver las notificaciones.';

  @override
  String get notifications_delete => 'Eliminar';

  @override
  String get notifications_deleteTitle => 'Eliminar notificación';

  @override
  String get notifications_deleteConfirm => 'Esta acción no se puede deshacer.';

  @override
  String get notifications_deleted => 'Notificación eliminada';

  @override
  String get notifications_markedRead => 'Marcada como leída';

  @override
  String get notifications_markedUnread => 'Marcada como no leída';

  @override
  String get notifications_allCaughtUp => 'Todo al día';

  @override
  String notifications_unreadCount(int count) {
    return '$count sin leer';
  }

  @override
  String get notifications_yesterday => 'Ayer';

  @override
  String notifications_daysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String get goals_goalTitle => 'Objetivo';

  @override
  String get goals_saved => 'AHORRADO';

  @override
  String get goals_remaining => 'Restante';

  @override
  String get goals_monthlyNeed => 'Necesario/mes';

  @override
  String get goals_daysLeft => 'Días restantes';

  @override
  String get goals_linkedSource => 'Cuenta vinculada';

  @override
  String get goals_contributions => 'Aportaciones';

  @override
  String get goals_addContribution => 'Añadir aportación';

  @override
  String get fuelEntry_addFillUp => 'Añadir repostaje';

  @override
  String get fuelEntry_editFillUp => 'Editar repostaje';

  @override
  String get fuelEntry_filledAt => 'Repostado el';

  @override
  String get fuelEntry_odometerKm => 'Odómetro (km)';

  @override
  String get fuelEntry_liters => 'Litros';

  @override
  String get fuelEntry_pricePerLiter => 'Precio por litro (€)';

  @override
  String get fuelEntry_totalEuro => 'Total (€)';

  @override
  String get fuelEntry_station => 'GASOLINERA';

  @override
  String get fuelEntry_fullTank => 'Depósito lleno';

  @override
  String get fuelEntry_alsoCreateTransaction => 'Crear también transacción';

  @override
  String get fuelEntry_comingSoon => 'Próximamente';

  @override
  String get fuelEntry_notes => 'NOTAS';

  @override
  String get fuelEntry_notesPlaceholder => 'Notas opcionales';

  @override
  String get fuelEntry_added => 'Repostaje añadido';

  @override
  String get fuelEntry_updated => 'Repostaje actualizado';

  @override
  String get fuelEntry_done => 'Listo';

  @override
  String get car_newCar => 'Nuevo coche';

  @override
  String get car_editCar => 'Editar coche';

  @override
  String get car_name => 'Nombre';

  @override
  String get car_make => 'Marca';

  @override
  String get car_model => 'Modelo';

  @override
  String get car_year => 'Año';

  @override
  String get car_licensePlate => 'Matrícula';

  @override
  String get car_gasoline => 'Gasolina';

  @override
  String get car_diesel => 'Diésel';

  @override
  String get car_electric => 'Eléctrico';

  @override
  String get car_hybrid => 'Híbrido';

  @override
  String get car_tankCapacity => 'Capacidad del depósito (L)';

  @override
  String get car_currentOdometer => 'Odómetro actual (km)';

  @override
  String get car_status => 'Estado';

  @override
  String get car_statusActive => 'Activo';

  @override
  String get car_statusInactive => 'Inactivo';

  @override
  String get car_drivers => 'CONDUCTORES';

  @override
  String get fuelAnalytics_avgL100km => 'Media L/100km';

  @override
  String get fuelAnalytics_costPerKm => 'Coste / km';

  @override
  String get fuelAnalytics_last30Days => 'Últimos 30 días';

  @override
  String get fuelAnalytics_consumption => 'CONSUMO (L/100KM)';

  @override
  String get fuelAnalytics_monthlyCost => 'COSTE MENSUAL';

  @override
  String get fuelAnalytics_noDataYet => 'Aún no hay datos';

  @override
  String get fuelAnalytics_needFullTanks =>
      'Se necesitan al menos 2 depósitos llenos';

  @override
  String get bankAccountForm_newAccount => 'Nueva cuenta';

  @override
  String get bankAccountForm_editAccount => 'Editar cuenta';

  @override
  String get bankAccountForm_bank => 'BANCO';

  @override
  String get bankAccountForm_selectBank => 'Seleccionar banco';

  @override
  String get bankAccountForm_accountName => 'NOMBRE DE CUENTA';

  @override
  String get bankAccountForm_accountNamePlaceholder =>
      'p. ej. Cuenta corriente principal';

  @override
  String get bankAccountForm_ibanOptional => 'IBAN (OPCIONAL)';

  @override
  String get bankAccountForm_type => 'TIPO';

  @override
  String get bankAccountForm_checking => 'Corriente';

  @override
  String get bankAccountForm_savings => 'Ahorro';

  @override
  String get bankAccountForm_credit => 'Crédito';

  @override
  String get bankAccountForm_cash => 'Efectivo';

  @override
  String get bankAccountForm_investment => 'Inversión';

  @override
  String get bankAccountForm_ownership => 'TITULARIDAD';

  @override
  String get bankAccountForm_personal => 'Personal';

  @override
  String get bankAccountForm_shared => 'Compartida';

  @override
  String get bankAccountForm_initialBalance => 'SALDO INICIAL';

  @override
  String get bankAccountForm_createAccount => 'Crear cuenta';

  @override
  String get bankAccountForm_saveChanges => 'Guardar cambios';

  @override
  String get bankAccountForm_accountCreated => 'Cuenta creada';

  @override
  String get bankAccountForm_accountUpdated => 'Cuenta actualizada';

  @override
  String get bankAccountForm_couldNotSave => 'No se pudo guardar';

  @override
  String get bankAccountForm_enterName => 'Introduce un nombre de cuenta';

  @override
  String get bankAccountForm_searchBank => 'Buscar banco…';

  @override
  String get bankAccountForm_noneEnterManually =>
      'Ninguno / introducir manualmente';

  @override
  String get bankAccountForm_selectBankTitle => 'Seleccionar banco';

  @override
  String get recurringTransactions_title => 'Recurrentes';

  @override
  String get recurringTransactions_noTransactionsYet =>
      'Aún no hay transacciones recurrentes';

  @override
  String get recurringTransactions_recurring => 'Recurrente';

  @override
  String get homes_title => 'Casas';

  @override
  String get homes_noHomesYet => 'Aún no hay casas';

  @override
  String get homes_addHomeDescription =>
      'Añade tu casa para asociarla a transacciones.';

  @override
  String get homes_addHome => 'Añadir casa';

  @override
  String get homes_editHome => 'Editar casa';

  @override
  String get homes_name => 'Nombre';

  @override
  String get homes_namePlaceholder => 'p. ej. Piso principal';

  @override
  String get homes_address => 'Dirección';

  @override
  String get homes_addressPlaceholder => 'Dirección completa';

  @override
  String get homes_saveChanges => 'Guardar cambios';

  @override
  String get homes_deleteLabel => 'Eliminar';

  @override
  String get homes_editLabel => 'Editar';

  @override
  String get transaction_expense => 'Gasto';

  @override
  String get transaction_income => 'Ingreso';

  @override
  String get transaction_transfer => 'Transferencia';

  @override
  String get transaction_category => 'Categoría';

  @override
  String get transaction_selectCategory => 'Seleccionar';

  @override
  String get transaction_bankAccount => 'Cuenta bancaria';

  @override
  String get transaction_fromAccount => 'Cuenta origen';

  @override
  String get transaction_toAccount => 'Cuenta destino';

  @override
  String get transaction_card => 'Tarjeta';

  @override
  String get transaction_source => 'Origen';

  @override
  String get transaction_sourceOptional => 'Opcional';

  @override
  String get transaction_sourceSub => 'Comerciante, empleador, servicio';

  @override
  String get transaction_date => 'Fecha';

  @override
  String get transaction_repeat => 'Repetir';

  @override
  String get transaction_oneTime => 'Una vez';

  @override
  String get transaction_recurring => 'Recurrente';

  @override
  String get transaction_addNote => 'Añadir una nota…';

  @override
  String get transaction_attachLocation => 'Adjuntar ubicación';

  @override
  String get transaction_locationOn => 'Activado';

  @override
  String get transaction_locationOff => 'Desactivado';

  @override
  String get transaction_useGps => 'Usar GPS';

  @override
  String get transaction_map => 'Mapa';

  @override
  String get transaction_today => 'Hoy';

  @override
  String get transaction_update => 'Actualizar';

  @override
  String get transaction_saveTransaction => 'Guardar transacción';

  @override
  String get transaction_expenseSaved => 'Gasto guardado';

  @override
  String get transaction_incomeSaved => 'Ingreso guardado';

  @override
  String get transaction_deleted => 'Transacción eliminada';

  @override
  String get transaction_somethingWentWrong => 'Algo salió mal';

  @override
  String get transaction_selectCategoryTitle => 'Seleccionar categoría';

  @override
  String get transaction_selectBankAccount => 'Seleccionar cuenta bancaria';

  @override
  String get transaction_selectFromAccount => 'Seleccionar cuenta origen';

  @override
  String get transaction_selectDestinationAccount =>
      'Seleccionar cuenta destino';

  @override
  String get transaction_selectCard => 'Seleccionar tarjeta';

  @override
  String get transaction_noCard => 'Ninguna';

  @override
  String get transaction_noCardSub => 'Sin tarjeta';

  @override
  String get transaction_currency => 'Moneda';

  @override
  String get transaction_counterpartySource => 'Origen de la contraparte';

  @override
  String get transaction_selectDate => 'Seleccionar fecha';

  @override
  String get transaction_newSource => 'Nueva fuente';

  @override
  String get transaction_editSource => 'Editar fuente';

  @override
  String get card_primary => 'PRINCIPAL';

  @override
  String get card_virtual => 'VIRTUAL';

  @override
  String get card_expires => 'CADUCA';

  @override
  String get appointment_duration => 'Duración';

  @override
  String get appointment_pinLocation => 'Marcar ubicación en el mapa';

  @override
  String get appointment_signInRequired => 'Se requiere iniciar sesión';

  @override
  String get appointment_categoryHealth => 'Salud';

  @override
  String get appointment_categoryVehicle => 'Vehículo';

  @override
  String get appointment_categoryBeauty => 'Belleza';

  @override
  String get appointment_categoryWork => 'Trabajo';

  @override
  String get appointment_categoryPersonal => 'Personal';

  @override
  String get appointment_categoryOther => 'Otro';

  @override
  String get bankAccount_goalsOnThisAccount => 'Metas de esta cuenta';

  @override
  String homes_coordinatesNote(String lat, String lng) {
    return 'Coordenadas: $lat, $lng\nToca el mapa en la vista completa para elegir una ubicación precisa.';
  }

  @override
  String get card_addCard => 'Añadir tarjeta';

  @override
  String get card_editCard => 'Editar tarjeta';

  @override
  String get card_network => 'Red';

  @override
  String get card_last4Digits => 'Últimos 4 dígitos';

  @override
  String get card_cardholderName => 'Nombre del titular';

  @override
  String get card_month => 'Mes';

  @override
  String get card_year => 'Año';

  @override
  String get card_cardholderOwner => 'Titular de la tarjeta';

  @override
  String get card_primaryCard => 'Tarjeta principal';

  @override
  String get card_virtualCard => 'Tarjeta virtual';

  @override
  String get card_saveChanges => 'Guardar cambios';

  @override
  String get card_none => 'Ninguna';

  @override
  String get card_last4Error =>
      'Los últimos 4 dígitos deben ser exactamente 4 números';

  @override
  String get card_cardholderRequired => 'El nombre del titular es obligatorio';

  @override
  String get card_setAsPrimary => 'Establecer como principal';

  @override
  String get transaction_relatedTo => 'Relacionado con';

  @override
  String get transaction_createNewSource => 'Crear nueva fuente';

  @override
  String transaction_amountLabel(String currency) {
    return 'IMPORTE · $currency';
  }

  @override
  String get transaction_relatedToNone => 'Ninguno';

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
  String get appointment_reminder1Day => '1 día';

  @override
  String appointment_reminderDays(int n) {
    return '$n días';
  }
}
