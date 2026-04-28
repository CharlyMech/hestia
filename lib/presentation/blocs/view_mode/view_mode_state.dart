import 'package:equatable/equatable.dart';
import 'package:hestia/core/constants/enums.dart';

class ViewModeState extends Equatable {
  final ViewMode mode;

  const ViewModeState(this.mode);

  bool get isPersonal => mode == ViewMode.personal;
  bool get isHousehold => mode == ViewMode.household;

  @override
  List<Object> get props => [mode];
}
