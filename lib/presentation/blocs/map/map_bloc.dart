import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hestia/core/constants/enums.dart';
import 'package:hestia/core/error/error_handler.dart';
import 'package:hestia/domain/entities/home.dart';
import 'package:hestia/domain/entities/transaction.dart';
import 'package:hestia/domain/entities/transaction_source.dart';
import 'package:hestia/domain/repositories/home_repository.dart';
import 'package:hestia/domain/repositories/household_repository.dart';
import 'package:hestia/domain/repositories/transaction_repository.dart';
import 'package:hestia/domain/repositories/transaction_source_repository.dart';

/// Radius (metres) used to filter "nearby" vendors around the map centre.
const double kVendorNearbyRadiusMeters = 100000; // 100 km

/// Madrid — Plaza Mayor: shared fallback centre when no location is available.
const double kMadridLat = 40.415371;
const double kMadridLng = -3.707364;
const double kMadridZoom = 11.0;

/// How many recent located transactions to load.
const int kMaxTransactions = 100;

// ── Events ─────────────────────────────────────────────────────────────────────

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object?> get props => const [];
}

/// Initial / refresh load of household homes, last [kMaxTransactions] located
/// transactions, and all vendors. Idempotent — safe to dispatch repeatedly.
class MapLoad extends MapEvent {
  final String userId;
  const MapLoad(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// Map camera moved (by the user or programmatically). Persists the camera
/// position so both the dashboard preview and the full map stay in sync, and
/// re-filters nearby vendors around the new centre (network-free).
class MapCameraMoved extends MapEvent {
  final double lat;
  final double lng;
  final double zoom;
  const MapCameraMoved(this.lat, this.lng, this.zoom);
  @override
  List<Object?> get props => [lat, lng, zoom];
}

/// Device location updated (from the realtime GPS stream). Stored so the blue
/// user pin is shared across widgets. Optionally recentres the camera (used the
/// first time a fix arrives, before the user has moved the map).
class MapUserLocationUpdated extends MapEvent {
  final double lat;
  final double lng;
  final bool recenter;
  const MapUserLocationUpdated(this.lat, this.lng, {this.recenter = false});
  @override
  List<Object?> get props => [lat, lng, recenter];
}

// ── State ──────────────────────────────────────────────────────────────────────

abstract class MapState extends Equatable {
  /// Persisted camera — present on every state so widgets can read it even
  /// before/while data is loading.
  double get cameraLat;
  double get cameraLng;
  double get cameraZoom;

  /// Device location, when known (drives the blue user pin).
  double? get userLat;
  double? get userLng;
  bool get hasUserLocation => userLat != null && userLng != null;

  const MapState();
  @override
  List<Object?> get props =>
      [cameraLat, cameraLng, cameraZoom, userLat, userLng];
}

class MapInitial extends MapState {
  @override
  final double cameraLat;
  @override
  final double cameraLng;
  @override
  final double cameraZoom;
  @override
  final double? userLat;
  @override
  final double? userLng;

  const MapInitial({
    this.cameraLat = kMadridLat,
    this.cameraLng = kMadridLng,
    this.cameraZoom = kMadridZoom,
    this.userLat,
    this.userLng,
  });
}

class MapLoading extends MapState {
  @override
  final double cameraLat;
  @override
  final double cameraLng;
  @override
  final double cameraZoom;
  @override
  final double? userLat;
  @override
  final double? userLng;

  const MapLoading({
    required this.cameraLat,
    required this.cameraLng,
    required this.cameraZoom,
    this.userLat,
    this.userLng,
  });
}

class MapLoaded extends MapState {
  /// Located income/expense transactions (located only).
  final List<Transaction> transactions;

  /// All household homes (members' homes).
  final List<Home> homes;

  /// Vendors within [kVendorNearbyRadiusMeters] of the current map centre.
  final List<TransactionSource> nearbyVendors;

  /// All located vendors (kept so re-filtering on map move is network-free).
  final List<TransactionSource> allVendors;

  @override
  final double cameraLat;
  @override
  final double cameraLng;
  @override
  final double cameraZoom;
  @override
  final double? userLat;
  @override
  final double? userLng;

  const MapLoaded({
    required this.transactions,
    required this.homes,
    required this.nearbyVendors,
    required this.allVendors,
    required this.cameraLat,
    required this.cameraLng,
    required this.cameraZoom,
    this.userLat,
    this.userLng,
  });

  MapLoaded copyWith({
    List<Transaction>? transactions,
    List<Home>? homes,
    List<TransactionSource>? nearbyVendors,
    List<TransactionSource>? allVendors,
    double? cameraLat,
    double? cameraLng,
    double? cameraZoom,
    double? userLat,
    double? userLng,
  }) =>
      MapLoaded(
        transactions: transactions ?? this.transactions,
        homes: homes ?? this.homes,
        nearbyVendors: nearbyVendors ?? this.nearbyVendors,
        allVendors: allVendors ?? this.allVendors,
        cameraLat: cameraLat ?? this.cameraLat,
        cameraLng: cameraLng ?? this.cameraLng,
        cameraZoom: cameraZoom ?? this.cameraZoom,
        userLat: userLat ?? this.userLat,
        userLng: userLng ?? this.userLng,
      );

  @override
  List<Object?> get props => [
        transactions,
        homes,
        nearbyVendors,
        allVendors,
        cameraLat,
        cameraLng,
        cameraZoom,
        userLat,
        userLng,
      ];
}

// ── Bloc ───────────────────────────────────────────────────────────────────────

class MapBloc extends Bloc<MapEvent, MapState> {
  final HouseholdRepository _householdRepo;
  final HomeRepository _homeRepo;
  final TransactionRepository _txRepo;
  final TransactionSourceRepository _vendorRepo;

  MapBloc({
    required HouseholdRepository householdRepository,
    required HomeRepository homeRepository,
    required TransactionRepository transactionRepository,
    required TransactionSourceRepository transactionSourceRepository,
  })  : _householdRepo = householdRepository,
        _homeRepo = homeRepository,
        _txRepo = transactionRepository,
        _vendorRepo = transactionSourceRepository,
        super(const MapInitial()) {
    on<MapLoad>(_onLoad);
    on<MapCameraMoved>(_onCameraMoved);
    on<MapUserLocationUpdated>(_onUserLocationUpdated);
  }

  Future<void> _onLoad(MapLoad e, Emitter<MapState> emit) async {
    emit(MapLoading(
      cameraLat: state.cameraLat,
      cameraLng: state.cameraLng,
      cameraZoom: state.cameraZoom,
      userLat: state.userLat,
      userLng: state.userLng,
    ));

    final (household, hhFail) =
        await _householdRepo.getCurrentHousehold(e.userId);
    if (hhFail != null) {
      // Keep camera; expose empty data.
      emit(_emptyLoaded());
      return;
    }
    if (household == null) {
      emit(_emptyLoaded());
      return;
    }

    final results = await Future.wait([
      _txRepo.getTransactions(
        householdId: household.id,
        viewMode: ViewMode.household,
        userId: e.userId,
        limit: kMaxTransactions,
      ),
      _homeRepo.getHomes(household.id),
      _vendorRepo.getAll(householdId: household.id),
    ]);

    final (txList, _) = results[0] as (List<Transaction>, Object?);
    final (homeList, _) = results[1] as (List<Home>, Object?);
    final (vendorList, _) = results[2] as (List<TransactionSource>, Object?);

    final transactions = txList.where((t) => t.hasLocation).toList();
    final homes =
        homeList.where((h) => h.latitude != 0 || h.longitude != 0).toList();
    final allVendors = vendorList
        .where((v) => v.latitude != null && v.longitude != null)
        .toList();

    final nearby = _filterNearby(allVendors, state.cameraLat, state.cameraLng);

    logger.i(
      'MapBloc loaded → homes: ${homes.length}, '
      'transactions(located): ${transactions.length} '
      '(income: ${transactions.where((t) => t.type == TransactionType.income).length}, '
      'expense: ${transactions.where((t) => t.type == TransactionType.expense).length}), '
      'vendors(total located): ${allVendors.length}, '
      'vendors(nearby ≤100km): ${nearby.length}',
    );
    for (final h in homes) {
      logger.d('  home "${h.name}" @ ${h.latitude},${h.longitude}');
    }
    for (final t in transactions) {
      logger.d(
          '  tx ${t.type.name} "${t.note ?? t.categoryName ?? '-'}" @ ${t.latitude},${t.longitude}');
    }
    for (final v in allVendors) {
      logger.d('  vendor "${v.name}" @ ${v.latitude},${v.longitude}');
    }

    emit(MapLoaded(
      transactions: transactions,
      homes: homes,
      nearbyVendors: nearby,
      allVendors: allVendors,
      cameraLat: state.cameraLat,
      cameraLng: state.cameraLng,
      cameraZoom: state.cameraZoom,
      userLat: state.userLat,
      userLng: state.userLng,
    ));
  }

  void _onCameraMoved(MapCameraMoved e, Emitter<MapState> emit) {
    final s = state;
    if (s is MapLoaded) {
      final nearby = _filterNearby(s.allVendors, e.lat, e.lng);
      emit(s.copyWith(
        cameraLat: e.lat,
        cameraLng: e.lng,
        cameraZoom: e.zoom,
        nearbyVendors: nearby,
      ));
    } else {
      emit(MapInitial(
        cameraLat: e.lat,
        cameraLng: e.lng,
        cameraZoom: e.zoom,
        userLat: s.userLat,
        userLng: s.userLng,
      ));
    }
  }

  void _onUserLocationUpdated(
      MapUserLocationUpdated e, Emitter<MapState> emit) {
    final s = state;
    final newCamLat = e.recenter ? e.lat : s.cameraLat;
    final newCamLng = e.recenter ? e.lng : s.cameraLng;
    final newCamZoom = e.recenter ? 14.0 : s.cameraZoom;

    if (s is MapLoaded) {
      emit(s.copyWith(
        userLat: e.lat,
        userLng: e.lng,
        cameraLat: newCamLat,
        cameraLng: newCamLng,
        cameraZoom: newCamZoom,
      ));
    } else {
      emit(MapInitial(
        cameraLat: newCamLat,
        cameraLng: newCamLng,
        cameraZoom: newCamZoom,
        userLat: e.lat,
        userLng: e.lng,
      ));
    }
  }

  MapLoaded _emptyLoaded() => MapLoaded(
        transactions: const [],
        homes: const [],
        nearbyVendors: const [],
        allVendors: const [],
        cameraLat: state.cameraLat,
        cameraLng: state.cameraLng,
        cameraZoom: state.cameraZoom,
        userLat: state.userLat,
        userLng: state.userLng,
      );

  /// Returns vendors within [kVendorNearbyRadiusMeters] of (lat,lng).
  List<TransactionSource> _filterNearby(
    List<TransactionSource> vendors,
    double lat,
    double lng,
  ) {
    return vendors.where((v) {
      final d = Geolocator.distanceBetween(lat, lng, v.latitude!, v.longitude!);
      return d <= kVendorNearbyRadiusMeters;
    }).toList();
  }
}
