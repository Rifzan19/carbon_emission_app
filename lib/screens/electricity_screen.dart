import 'package:carbon_emission_app/config/theme.dart';
import 'package:carbon_emission_app/models/history_item.dart';
import 'package:carbon_emission_app/models/request/electricity_request.dart';
import 'package:carbon_emission_app/services/api_service.dart';
import 'package:carbon_emission_app/services/firebase_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

class ElectricityScreen extends ConsumerStatefulWidget {
  const ElectricityScreen({super.key});

  @override
  ConsumerState<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends ConsumerState<ElectricityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  String? selectedUnit;
  String? selectedCountry;
  bool _isLoading = false;
  
  // Emission values
  double co2Gm = 0.0;
  double co2Lb = 0.0;
  double co2Kg = 0.0;
  double co2Mt = 0.0;

  // API Service
  late final ApiService _apiService;

  // Available units
  final List<String> units = ['kWh', 'MWh', 'GWh'];

  // Available countries - only supported by the API
  final List<String> countries = [
    'Australia',
    'Austria',
    'Bangladesh',
    'Belgium',
    'Bhutan',
    'Brunei',
    'Bulgaria',
    'Cambodia',
    'Canada',
    'China',
    'Croatia',
    'Cyprus',
    'Czechia',
    'Denmark',
    'Estonia',
    'EU-27',
    'Finland',
    'France',
    'Germany',
    'Greece',
    'Hong Kong',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Ireland',
    'Italy',
    'Japan',
    'Laos',
    'Latvia',
    'Lithuania',
    'Luxembourg',
    'Macao',
    'Malaysia',
    'Maldives',
    'Malta',
    'Mongolia',
    'Myanmar',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'North Korea',
    'Norway',
    'Pakistan',
    'Papua New Guinea',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'South Korea',
    'Spain',
    'Sri Lanka',
    'Sweden',
    'Taiwan',
    'Thailand',
    'Turkey',
    'UK',
    'USA',
    'Vietnam'
  ];

  // Text styles
  static const titleStyle = TextStyle(
    color: white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const valueStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: black,
  );

  static const labelStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const normalStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: black,
  );

  static const buttonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
  );

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    _apiService = ApiService(dio);
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _calculateEmissions() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = ElectricityRequest(
          countryName: selectedCountry!,
          electricityValue: double.parse(_valueController.text),
          electricityUnit: selectedUnit!,
        );

        final response = await _apiService.estimateElectricityEmission(
          request,
          dotenv.env['AUTH_BEARER_TOKEN'] ?? '',
          dotenv.env['RAPIDAPI_HOST'] ?? '',
          dotenv.env['RAPIDAPI_KEY'] ?? '',
        );

        if (response.success) {
          setState(() {
            co2Gm = response.co2eGm;
            co2Lb = response.co2eLb;
            co2Kg = response.co2eKg;
            co2Mt = response.co2eMt;
            _isLoading = false;
          });

          // Save to Firebase
          final firebaseService = ref.read(firebaseServiceProvider);
          final historyItem = HistoryItem(
            id: '', // Firebase will generate this
            type: 'electricity',
            value: double.parse(_valueController.text),
            unit: selectedUnit!,
            country: selectedCountry!,
            co2eGm: response.co2eGm,
            co2eLb: response.co2eLb,
            co2eKg: response.co2eKg,
            co2eMt: response.co2eMt,
            timestamp: DateTime.now(),
          );
          await firebaseService.addHistoryItem(historyItem);
        } else {
          throw Exception('API request failed with status: ${response.status}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating emissions: ${e.toString()}'),
            backgroundColor: error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Electricity Emissions",
          style: titleStyle,
        ),
        backgroundColor: primaryYellow,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.bolt,
                            size: 48,
                            color: primaryYellow,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            co2Gm.toStringAsFixed(1),
                            style: valueStyle,
                          ),
                          const Text(
                            "CO2e/gm",
                            style: labelStyle,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildEmissionValue(co2Lb, "CO2e/lb"),
                              _buildEmissionValue(co2Kg, "CO2e/kg"),
                              _buildEmissionValue(co2Mt, "CO2e/mt"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Please enter your data:",
                      style: normalStyle,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _valueController,
                            decoration: InputDecoration(
                              labelText: 'Electricity Value',
                              labelStyle: labelStyle,
                              filled: true,
                              fillColor: white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: InputDecoration(
                              labelText: 'Unit',
                              labelStyle: labelStyle,
                              filled: true,
                              fillColor: white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: units
                                .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit, style: normalStyle),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUnit = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a unit';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCountry,
                      decoration: InputDecoration(
                        labelText: 'Country',
                        labelStyle: labelStyle,
                        filled: true,
                        fillColor: white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: countries
                          .map((country) => DropdownMenuItem(
                                value: country,
                                child: Text(country, style: normalStyle),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _calculateEmissions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(white),
                                ),
                              )
                            : const Text(
                                'Calculate',
                                style: buttonStyle,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmissionValue(double value, String label) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: normalStyle,
        ),
        Text(
          label,
          style: labelStyle,
        ),
      ],
    );
  }
}