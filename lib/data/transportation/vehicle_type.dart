import 'package:carbon_emission_app/data/has_value.dart';

class VehicleType implements HasValue {
  @override
  final String value;

  const VehicleType._(this.value);

  static const VehicleType carSmall = VehicleType._("Car-Size-Small");
  static const VehicleType carMedium = VehicleType._("Car-Size-Medium");
  static const VehicleType carLarge = VehicleType._("Car-Size-Large");
  static const VehicleType bikeSmall = VehicleType._("Motorbike-Size-Small");
  static const VehicleType bikeMedium = VehicleType._("Motorbike-Size-Medium");
  static const VehicleType bikeLarge = VehicleType._("Motorbike-Size-Large");
  static const VehicleType bus = VehicleType._("Bus-LocalAverage");
  static const VehicleType taxi = VehicleType._("Taxi-Local");
  static const VehicleType train = VehicleType._("Train-Local");

  static const List<VehicleType> values = [
    carSmall,
    carMedium,
    carLarge,
    bikeSmall,
    bikeMedium,
    bikeLarge,
    bus,
    taxi,
    train
  ];
}