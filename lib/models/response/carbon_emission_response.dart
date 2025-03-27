import 'package:json_annotation/json_annotation.dart';

part 'carbon_emission_response.g.dart';

@JsonSerializable()
class CarbonEmissionResponse {
  @JsonKey(name: 'data')
  final Map<String, dynamic> data;

  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'status')
  final int status;

  CarbonEmissionResponse({
    required this.data,
    required this.success,
    required this.status,
  });

  double get co2eGm => (data['co2e_gm'] as num?)?.toDouble() ?? 0.0;
  double get co2eLb => (data['co2e_lb'] as num?)?.toDouble() ?? 0.0;
  double get co2eKg => (data['co2e_kg'] as num?)?.toDouble() ?? 0.0;
  double get co2eMt => (data['co2e_mt'] as num?)?.toDouble() ?? 0.0;

  factory CarbonEmissionResponse.fromJson(Map<String, dynamic> json) =>
      _$CarbonEmissionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CarbonEmissionResponseToJson(this);
}