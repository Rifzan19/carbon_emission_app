import 'package:carbon_emission_app/data/has_value.dart';

class DistanceUnit implements HasValue {
  @override
  final String value;

  const DistanceUnit._(this.value);

  static const DistanceUnit kilometers = DistanceUnit._("km");
  static const DistanceUnit miles = DistanceUnit._("mi");

  static const List<DistanceUnit> values = [kilometers, miles];
}