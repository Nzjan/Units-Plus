import 'package:flutter/material.dart';
import '../data/unit_data.dart';
import '../utils/converter_logic.dart';

class ConverterScreen extends StatefulWidget {
  final UnitCategory category;
  const ConverterScreen({super.key, required this.category});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  String? _fromUnit;
  String? _toUnit;
  double? _result;

  @override
  void initState() {
    super.initState();
    _fromUnit = widget.category.units.first.name;
    _toUnit = widget.category.units[1].name;
  }

  void _convert() {
    final value = double.tryParse(_inputController.text);
    if (value == null) return;
    setState(() {
      _result = ConverterLogic.convert(
        value,
        _fromUnit!,
        _toUnit!,
        widget.category.name,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Input field
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    setState(() => _result = null);
                  },
                ),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 24),

            // From/To dropdowns
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromUnit,
                    decoration: const InputDecoration(labelText: 'From'),
                    items: widget.category.units
                        .map(
                          (u) => DropdownMenuItem(
                            value: u.name,
                            child: Text(u.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _fromUnit = value;
                        _convert();
                      });
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.swap_horiz, size: 32),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toUnit,
                    decoration: const InputDecoration(labelText: 'To'),
                    items: widget.category.units
                        .map(
                          (u) => DropdownMenuItem(
                            value: u.name,
                            child: Text(u.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _toUnit = value;
                        _convert();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Result card
            if (_result != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_result',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$_fromUnit → $_toUnit',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      onPressed: () {
                        // Use Clipboard.setData
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
