import 'package:carbon_emission_app/data/has_value.dart';

class FuelType implements HasValue {
  @override
  final String value;

  const FuelType._(this.value);

  static const FuelType petrol = FuelType._("Petrol");
  static const FuelType diesel = FuelType._("Diesel");
  static const FuelType unknown = FuelType._("Unknown");

  static const List<FuelType> values = [petrol, diesel, unknown];
}