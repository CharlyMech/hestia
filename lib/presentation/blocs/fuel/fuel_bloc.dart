import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hestia/domain/entities/fuel_entry.dart';
import 'package:hestia/domain/repositories/fuel_entry_repository.dart';

abstract class FuelEvent extends Equatable {
  const FuelEvent();
  @override
  List<Object?> get props => const [];
}

class FuelLoad extends FuelEvent {
  final String carId;
  const FuelLoad(this.carId);
  @override
  List<Object?> get props => [carId];
}

class FuelCreate extends FuelEvent {
  final FuelEntry entry;
  final bool createTransaction;
  const FuelCreate(this.entry, {this.createTransaction = false});
  @override
  List<Object?> get props => [entry, createTransaction];
}

class FuelUpdate extends FuelEvent {
  final FuelEntry entry;
  const FuelUpdate(this.entry);
  @override
  List<Object?> get props => [entry];
}

class FuelDelete extends FuelEvent {
  final String id;
  const FuelDelete(this.id);
  @override
  List<Object?> get props => [id];
}

abstract class FuelState extends Equatable {
  const FuelState();
  @override
  List<Object?> get props => const [];
}

class FuelInitial extends FuelState {
  const FuelInitial();
}

class FuelLoading extends FuelState {
  const FuelLoading();
}

class FuelError extends FuelState {
  final String message;
  const FuelError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Aggregated analytics derived from a sorted-asc set of [FuelEntry].
class FuelAnalytics extends Equatable {
  /// Average L/100km across the last [windowSize] consumption windows
  /// (between consecutive full tanks). Null if not enough full tanks.
  final double? avgLPer100Km;

  /// Cost per km across the whole history. Null if odometer span is zero.
  final double? costPerKm;

  /// Total spent in the last 30 days.
  final double last30dTotal;

  /// Per-window consumption points: (filledAt of the second full tank, L/100km).
  final List<({DateTime at, double lPer100km})> consumptionPoints;

  /// Monthly cost totals for the last 6 calendar months (oldest → newest).
  final List<({DateTime month, double total})> monthlyCost;

  const FuelAnalytics({
    required this.avgLPer100Km,
    required this.costPerKm,
    required this.last30dTotal,
    required this.consumptionPoints,
    required this.monthlyCost,
  });

  @override
  List<Object?> get props =>
      [avgLPer100Km, costPerKm, last30dTotal, consumptionPoints, monthlyCost];
}

class FuelLoaded extends FuelState {
  /// Newest-first (matches list display).
  final List<FuelEntry> entries;
  const FuelLoaded(this.entries);

  @override
  List<Object?> get props => [entries];

  /// Compute analytics on demand. Cheap given typical entry counts.
  FuelAnalytics get analytics {
    final asc = [...entries]..sort((a, b) => a.filledAt.compareTo(b.filledAt));

    // Consumption between consecutive full tanks.
    final points = <({DateTime at, double lPer100km})>[];
    FuelEntry? prevFull;
    for (final e in asc) {
      if (!e.isFullTank) continue;
      if (prevFull != null) {
        final dKm = e.odometerKm - prevFull.odometerKm;
        if (dKm > 0) {
          points.add((at: e.filledAt, lPer100km: e.liters / dKm * 100));
        }
      }
      prevFull = e;
    }

    final lastN =
        points.length > 10 ? points.sublist(points.length - 10) : points;
    final avg = lastN.isEmpty
        ? null
        : lastN.fold<double>(0, (s, p) => s + p.lPer100km) / lastN.length;

    double? costPerKm;
    if (asc.length >= 2) {
      final span = asc.last.odometerKm - asc.first.odometerKm;
      if (span > 0) {
        final total = asc.fold<double>(0, (s, e) => s + e.totalAmount);
        costPerKm = total / span;
      }
    }

    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 30));
    final last30d = asc
        .where((e) => e.filledAt.isAfter(cutoff))
        .fold<double>(0, (s, e) => s + e.totalAmount);

    // Monthly totals last 6 months including current.
    final monthly = <({DateTime month, double total})>[];
    for (var i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final next = DateTime(m.year, m.month + 1, 1);
      final total = asc
          .where((e) => !e.filledAt.isBefore(m) && e.filledAt.isBefore(next))
          .fold<double>(0, (s, e) => s + e.totalAmount);
      monthly.add((month: m, total: total));
    }

    return FuelAnalytics(
      avgLPer100Km: avg,
      costPerKm: costPerKm,
      last30dTotal: last30d,
      consumptionPoints: points,
      monthlyCost: monthly,
    );
  }
}

class FuelBloc extends Bloc<FuelEvent, FuelState> {
  final FuelEntryRepository _repo;
  String? _carId;

  FuelBloc(this._repo) : super(const FuelInitial()) {
    on<FuelLoad>(_onLoad);
    on<FuelCreate>(_onCreate);
    on<FuelUpdate>(_onUpdate);
    on<FuelDelete>(_onDelete);
  }

  Future<void> _onLoad(FuelLoad e, Emitter<FuelState> emit) async {
    _carId = e.carId;
    emit(const FuelLoading());
    await _fetch(emit);
  }

  Future<void> _onCreate(FuelCreate e, Emitter<FuelState> emit) async {
    // TODO: link to transaction repo — when [createTransaction] is true,
    // create a paired transaction atomically (out of scope for mock-only PR).
    final (_, failure) = await _repo.create(e.entry);
    if (failure != null) {
      emit(FuelError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onUpdate(FuelUpdate e, Emitter<FuelState> emit) async {
    final failure = await _repo.update(e.entry);
    if (failure != null) {
      emit(FuelError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _onDelete(FuelDelete e, Emitter<FuelState> emit) async {
    final failure = await _repo.delete(e.id);
    if (failure != null) {
      emit(FuelError(failure.message));
      return;
    }
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<FuelState> emit) async {
    if (_carId == null) return;
    final (entries, failure) = await _repo.getEntries(carId: _carId!);
    if (failure != null) {
      emit(FuelError(failure.message));
      return;
    }
    emit(FuelLoaded(entries));
  }
}
