import 'package:flutter/material.dart';

class Unit {
  final String name;
  final double factor; // conversion factor to base unit

  Unit(this.name, this.factor);
}

class UnitCategory {
  final String name;
  final IconData icon;
  final List<Unit> units;

  UnitCategory(this.name, this.icon, this.units);
}

// Sample data – length, weight, temperature
final lengthUnits = [
  Unit('Meters', 1.0),
  Unit('Kilometers', 1000.0),
  Unit('Centimeters', 0.01),
  Unit('Millimeters', 0.001),
  Unit('Miles', 1609.344),
  Unit('Yards', 0.9144),
  Unit('Feet', 0.3048),
  Unit('Inches', 0.0254),
];

final weightUnits = [
  Unit('Kilograms', 1.0),
  Unit('Grams', 0.001),
  Unit('Pounds', 0.453592),
  Unit('Ounces', 0.0283495),
  Unit('Tons (metric)', 1000.0),
];

// Temperature is special – handle separately
final tempUnits = [
  Unit('Celsius', 1.0),
  Unit('Fahrenheit', 1.0),
  Unit('Kelvin', 1.0),
];

final categories = [
  UnitCategory('Length', Icons.straighten, lengthUnits),
  UnitCategory('Weight', Icons.monitor_weight, weightUnits),
  UnitCategory('Temperature', Icons.thermostat, tempUnits),
];
