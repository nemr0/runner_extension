part of 'get_devices_cubit.dart';

sealed class GetDevicesState extends Equatable {
  const GetDevicesState();
}

final class GetDevicesInitial extends GetDevicesState {
  @override
  List<Object> get props => [];
}
