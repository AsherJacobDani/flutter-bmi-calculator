import 'package:flutter_test/flutter_test.dart';

// Simple unit tests for the BMI calculation logic to verify correctness
double calculateBMIValue(double weight, double height) {
  final heightInMeters = height / 100;
  return weight / (heightInMeters * heightInMeters);
}

String getBMICategory(double bmi) {
  if (bmi < 18.5) {
    return "Underweight";
  } else if (bmi < 25) {
    return "Normal";
  } else if (bmi < 30) {
    return "Overweight";
  } else {
    return "Obese";
  }
}

void main() {
  group('BMI Logic Tests', () {
    test('Calculates BMI value correctly', () {
      final bmi = calculateBMIValue(70, 175);
      expect(double.parse(bmi.toStringAsFixed(1)), equals(22.9));
    });

    test('Categorizes BMI correctly', () {
      expect(getBMICategory(17.0), equals('Underweight'));
      expect(getBMICategory(22.0), equals('Normal'));
      expect(getBMICategory(27.0), equals('Overweight'));
      expect(getBMICategory(32.0), equals('Obese'));
    });
  });
}
