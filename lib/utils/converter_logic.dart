import 'package:units_plus/data/unit_data.dart';

class ConverterLogic {
  static double convert(
    double value,
    String fromUnit,
    String toUnit,
    String category,
  ) {
    if (category == 'Temperature') {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    // For linear units: convert to base, then to target
    double baseValue = value * _getFactor(fromUnit, category);
    return baseValue / _getFactor(toUnit, category);
  }

  static double _getFactor(String unitName, String category) {
    final cat = categories.firstWhere((c) => c.name == category);
    return cat.units.firstWhere((u) => u.name == unitName).factor;
  }

  static double _convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'Celsius':
        celsius = value;
        break;
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }

    // Convert from Celsius to target
    switch (to) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return (celsius * 9 / 5) + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }
}
