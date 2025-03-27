// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transportation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransportationRequest _$TransportationRequestFromJson(
  Map<String, dynamic> json,
) => TransportationRequest(
  distanceValue: (json['distance_value'] as num).toDouble(),
  distanceUnit: json['distance_unit'] as String,
  vehicleType: json['vehicle_type'] as String,
  fuelType: json['fuel_type'] as String,
);

Map<String, dynamic> _$TransportationRequestToJson(
  TransportationRequest instance,
) => <String, dynamic>{
  'distance_value': instance.distanceValue,
  'distance_unit': instance.distanceUnit,
  'vehicle_type': instance.vehicleType,
  'fuel_type': instance.fuelType,
};
