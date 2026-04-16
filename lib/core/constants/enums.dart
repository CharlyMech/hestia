/// Transaction type
enum TransactionType {
  income,
  expense;

  String get value => name;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere((e) => e.name == value);
  }
}

/// Money source ownership
enum OwnerType {
  personal,
  shared;

  String get value => name;

  static OwnerType fromString(String value) {
    return OwnerType.values.firstWhere((e) => e.name == value);
  }
}

/// Account type
enum AccountType {
  checking,
  savings,
  credit,
  cash,
  investment;

  String get value => name;

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere((e) => e.name == value);
  }
}

/// Household member role
enum MemberRole {
  owner,
  member;

  String get value => name;

  static MemberRole fromString(String value) {
    return MemberRole.values.firstWhere((e) => e.name == value);
  }
}

/// Financial goal type
enum GoalType {
  saveMonthly,
  reachTarget,
  reduceSpending,
  custom;

  String get value {
    switch (this) {
      case GoalType.saveMonthly:
        return 'save_monthly';
      case GoalType.reachTarget:
        return 'reach_target';
      case GoalType.reduceSpending:
        return 'reduce_spending';
      case GoalType.custom:
        return 'custom';
    }
  }

  static GoalType fromString(String value) {
    switch (value) {
      case 'save_monthly':
        return GoalType.saveMonthly;
      case 'reach_target':
        return GoalType.reachTarget;
      case 'reduce_spending':
        return GoalType.reduceSpending;
      case 'custom':
        return GoalType.custom;
      default:
        throw ArgumentError('Unknown GoalType: $value');
    }
  }
}

/// Goal scope
enum GoalScope {
  personal,
  household;

  String get value => name;

  static GoalScope fromString(String value) {
    return GoalScope.values.firstWhere((e) => e.name == value);
  }
}

/// Notification type
enum NotificationType {
  transaction,
  goal,
  alert,
  system,
  reminder;

  String get value => name;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere((e) => e.name == value);
  }
}

/// View mode for personal vs household data
enum ViewMode {
  personal,
  household,
}

/// Audit action
enum AuditAction {
  create,
  update,
  delete;

  String get value => name.toUpperCase();
}
