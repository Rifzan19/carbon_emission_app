import 'package:json_annotation/json_annotation.dart';

part 'electricity_request.g.dart';

@JsonSerializable()
class ElectricityRequest {
  @JsonKey(name: 'country_name')
  final String countryName;

  @JsonKey(name: 'electricity_value')
  final double electricityValue;

  @JsonKey(name: 'electricity_unit')
  final String electricityUnit;

  ElectricityRequest({
    required this.countryName,
    required this.electricityValue,
    required this.electricityUnit,
  });

  factory ElectricityRequest.fromJson(Map<String, dynamic> json) =>
      _$ElectricityRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ElectricityRequestToJson(this);
} 