// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carbon_emission_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarbonEmissionResponse _$CarbonEmissionResponseFromJson(
  Map<String, dynamic> json,
) => CarbonEmissionResponse(
  data: json['data'] as Map<String, dynamic>,
  success: json['success'] as bool,
  status: (json['status'] as num).toInt(),
);

Map<String, dynamic> _$CarbonEmissionResponseToJson(
  CarbonEmissionResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'success': instance.success,
  'status': instance.status,
};
