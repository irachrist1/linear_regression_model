import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PredictionResult {
  final double predictedAvgScore;
  final String performanceBand;
  final String modelName;
  final Map<String, dynamic> engineeredFeatures;

  PredictionResult({
    required this.predictedAvgScore,
    required this.performanceBand,
    required this.modelName,
    required this.engineeredFeatures,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      predictedAvgScore: (json['predicted_avg_score'] as num).toDouble(),
      performanceBand: json['performance_band'] as String,
      modelName: json['model_name'] as String,
      engineeredFeatures:
          Map<String, dynamic>.from(json['engineered_features'] as Map),
    );
  }
}

class PredictionService {
  static String get _baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    return 'https://linear-regression-model-83q9.onrender.com';
  }

  static String get baseUrl => _baseUrl;

  Future<PredictionResult> predict({
    required String gender,
    required String region,
    required String highestEducation,
    required String imdBand,
    required String ageBand,
    required int numOfPrevAttempts,
    required int studiedCredits,
    required String disability,
    required double dateRegistration,
    required double totalClicks,
  }) async {
    final body = jsonEncode({
      'gender': gender,
      'region': region,
      'highest_education': highestEducation,
      'imd_band': imdBand,
      'age_band': ageBand,
      'num_of_prev_attempts': numOfPrevAttempts,
      'studied_credits': studiedCredits,
      'disability': disability,
      'date_registration': dateRegistration,
      'total_clicks': totalClicks,
    });

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 65));
    } on TimeoutException {
      throw Exception(
        'The server is taking longer than expected to respond. '
        'It may be waking up from sleep — please try again in a moment.',
      );
    } catch (error) {
      final message = error.toString();
      if (message.contains('Connection refused') ||
          message.contains('Failed host lookup') ||
          message.contains('SocketException')) {
        throw Exception(
          'Could not reach the prediction server. '
          'Please check your internet connection and try again.',
        );
      }
      rethrow;
    }

    if (response.statusCode == 200) {
      return PredictionResult.fromJson(jsonDecode(response.body));
    } else {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = decoded['detail'] ?? 'Request failed';
      throw Exception('Prediction failed: $detail');
    }
  }
}
