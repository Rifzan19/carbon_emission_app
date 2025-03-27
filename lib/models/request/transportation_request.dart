import 'package:json_annotation/json_annotation.dart';

part 'transportation_request.g.dart';

@JsonSerializable()
class TransportationRequest {
  @JsonKey(name: 'distance_value')
  final double distanceValue;

  @JsonKey(name: 'distance_unit')
  final String distanceUnit;

  @JsonKey(name: 'vehicle_type')
  final String vehicleType;

  @JsonKey(name: 'fuel_type')
  final String fuelType;

  TransportationRequest({
    required this.distanceValue,
    required this.distanceUnit,
    required this.vehicleType,
    required this.fuelType,
  });

  factory TransportationRequest.fromJson(Map<String, dynamic> json) =>
      _$TransportationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransportationRequestToJson(this);
}
