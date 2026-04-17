import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_expenses/core/constants/enums.dart';
import 'package:home_expenses/presentation/blocs/view_mode/view_mode_events.dart';
import 'package:home_expenses/presentation/blocs/view_mode/view_mode_state.dart';

class ViewModeBloc extends Bloc<ViewModeEvent, ViewModeState> {
  ViewModeBloc() : super(const ViewModeState(ViewMode.personal)) {
    on<ToggleViewMode>(_onToggle);
    on<SetViewMode>(_onSet);
  }

  void _onToggle(ToggleViewMode event, Emitter<ViewModeState> emit) {
    final next = state.isPersonal ? ViewMode.household : ViewMode.personal;
    emit(ViewModeState(next));
  }

  void _onSet(SetViewMode event, Emitter<ViewModeState> emit) {
    emit(ViewModeState(event.mode));
  }
}
