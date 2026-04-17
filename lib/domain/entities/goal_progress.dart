/// Projection data for a financial goal.
class GoalProjection {
  final double currentAmount;
  final double? targetAmount;
  final double monthlyAverage;
  final DateTime startDate;
  final DateTime? endDate;

  const GoalProjection({
    required this.currentAmount,
    this.targetAmount,
    required this.monthlyAverage,
    required this.startDate,
    this.endDate,
  });

  /// Months to reach target at current average rate
  int? get monthsToTarget {
    if (targetAmount == null || monthlyAverage <= 0) return null;
    final remaining = targetAmount! - currentAmount;
    if (remaining <= 0) return 0;
    return (remaining / monthlyAverage).ceil();
  }

  /// Projected date of completion
  DateTime? get projectedCompletion {
    final months = monthsToTarget;
    if (months == null) return null;
    return DateTime.now().copyWith(
      month: DateTime.now().month + months,
    );
  }

  /// Is the goal on track to meet its deadline?
  bool? get isOnTrack {
    if (endDate == null || targetAmount == null) return null;
    final monthsLeft = _monthsBetween(DateTime.now(), endDate!);
    if (monthsLeft <= 0) return currentAmount >= targetAmount!;
    final requiredMonthly = (targetAmount! - currentAmount) / monthsLeft;
    return monthlyAverage >= requiredMonthly;
  }

  /// Month-by-month projection table
  List<ProjectionRow> generateTable({int months = 12}) {
    final rows = <ProjectionRow>[];
    var running = currentAmount;

    for (var i = 1; i <= months; i++) {
      running += monthlyAverage;
      final monthDate = DateTime(
        startDate.year,
        startDate.month + i,
      );

      rows.add(ProjectionRow(
        month: monthDate,
        projected: running,
        target: targetAmount,
        monthlyContribution: monthlyAverage,
        surplus: targetAmount != null ? running - targetAmount! : null,
      ));
    }
    return rows;
  }

  static int _monthsBetween(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + (to.month - from.month);
  }
}

class ProjectionRow {
  final DateTime month;
  final double projected;
  final double? target;
  final double monthlyContribution;
  final double? surplus;

  const ProjectionRow({
    required this.month,
    required this.projected,
    this.target,
    required this.monthlyContribution,
    this.surplus,
  });

  bool get isOnTrack => surplus == null || surplus! >= 0;
}
