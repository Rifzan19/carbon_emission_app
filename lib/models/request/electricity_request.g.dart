// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electricity_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricityRequest _$ElectricityRequestFromJson(Map<String, dynamic> json) =>
    ElectricityRequest(
      countryName: json['country_name'] as String,
      electricityValue: (json['electricity_value'] as num).toDouble(),
      electricityUnit: json['electricity_unit'] as String,
    );

Map<String, dynamic> _$ElectricityRequestToJson(ElectricityRequest instance) =>
    <String, dynamic>{
      'country_name': instance.countryName,
      'electricity_value': instance.electricityValue,
      'electricity_unit': instance.electricityUnit,
    };
