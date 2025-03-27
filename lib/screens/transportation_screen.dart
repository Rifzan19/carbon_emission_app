import 'package:carbon_emission_app/config/theme.dart';
import 'package:carbon_emission_app/data/transportation/distance_unit.dart';
import 'package:carbon_emission_app/data/transportation/fuel_type.dart';
import 'package:carbon_emission_app/data/transportation/vehicle_type.dart';
import 'package:carbon_emission_app/models/history_item.dart';
import 'package:carbon_emission_app/models/request/transportation_request.dart';
import 'package:carbon_emission_app/services/api_service.dart';
import 'package:carbon_emission_app/services/firebase_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

class TransportationScreen extends ConsumerStatefulWidget {
  const TransportationScreen({super.key});

  @override
  ConsumerState<TransportationScreen> createState() => _TransportationScreenState();
}

class _TransportationScreenState extends ConsumerState<TransportationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  DistanceUnit? selectedDistanceUnit;
  VehicleType? selectedVehicleType;
  FuelType? selectedFuelType;
  bool _isLoading = false;

  // Emission values
  double co2Gm = 0.0;
  double co2Lb = 0.0;
  double co2Kg = 0.0;
  double co2Mt = 0.0;

  // API Service
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    _apiService = ApiService(dio);
  }

  @override
  void dispose() {
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _calculateEmissions() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = TransportationRequest(
          distanceValue: double.parse(_distanceController.text),
          distanceUnit: selectedDistanceUnit!.value,
          vehicleType: selectedVehicleType!.value,
          fuelType: selectedFuelType!.value,
        );

        final response = await _apiService.estimateVehicleEmission(
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
            type: 'transportation',
            value: double.parse(_distanceController.text),
            unit: selectedDistanceUnit!.value,
            country: selectedVehicleType!.value,
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
          "Transportation Emissions",
          style: TextStyle(
            color: white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      Icon(
                        CupertinoIcons.car_fill,
                        size: 48,
                        color: primaryBlue,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        co2Gm.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: black,
                        ),
                      ),
                      const Text(
                        "CO2e/gm",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: black,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _distanceController,
                        decoration: InputDecoration(
                          labelText: 'Distance Traveled',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
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
                            return 'Please enter a distance';
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
                      child: DropdownButtonFormField<DistanceUnit>(
                        value: selectedDistanceUnit,
                        decoration: InputDecoration(
                          labelText: 'Distance Unit',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: DistanceUnit.values
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit.value,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: black,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDistanceUnit = value;
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
                DropdownButtonFormField<VehicleType>(
                  value: selectedVehicleType,
                  decoration: InputDecoration(
                    labelText: 'Vehicle Type',
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: VehicleType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              _getVehicleDisplayName(type.value),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: black,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedVehicleType = value;
                      // Reset fuel type when vehicle type changes
                      selectedFuelType = null;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a vehicle type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FuelType>(
                  value: selectedFuelType,
                  decoration: InputDecoration(
                    labelText: 'Fuel Type',
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: FuelType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: black,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedFuelType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a fuel type';
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
                      backgroundColor: primaryBlue,
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getVehicleDisplayName(String value) {
    switch (value) {
      case 'Car-Size-Small':
        return 'Small Car';
      case 'Car-Size-Medium':
        return 'Medium Car';
      case 'Car-Size-Large':
        return 'Large Car';
      case 'Motorbike-Size-Small':
        return 'Small Motorbike';
      case 'Motorbike-Size-Medium':
        return 'Medium Motorbike';
      case 'Motorbike-Size-Large':
        return 'Large Motorbike';
      case 'Bus-LocalAverage':
        return 'Bus';
      case 'Taxi-Local':
        return 'Taxi';
      case 'Train-Local':
        return 'Train';
      default:
        return value;
    }
  }

  Widget _buildEmissionValue(double value, String label) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: black,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
