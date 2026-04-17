import 'package:equatable/equatable.dart';
import 'package:home_expenses/core/constants/enums.dart';

sealed class ViewModeEvent extends Equatable {
  const ViewModeEvent();

  @override
  List<Object> get props => [];
}

class ToggleViewMode extends ViewModeEvent {
  const ToggleViewMode();
}

class SetViewMode extends ViewModeEvent {
  final ViewMode mode;
  const SetViewMode(this.mode);

  @override
  List<Object> get props => [mode];
}
