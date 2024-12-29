import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_devices_state.dart';

class GetDevicesCubit extends Cubit<GetDevicesState> {
  GetDevicesCubit() : super(GetDevicesInitial());
}
