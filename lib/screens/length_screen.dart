// ---------------- LENGTH SCREEN (FEET-INCH SUPPORT) ----------------
import 'package:flutter/material.dart';

class LengthScreen extends StatefulWidget {
  const LengthScreen({super.key});

  @override
  State<LengthScreen> createState() => _LengthScreenState();
}

class _LengthScreenState extends State<LengthScreen> {
  // Data for Length Units
  final List<Map<String, dynamic>> units = [
    {'name': 'Mile', 'symbol': 'mi', 'factor': 1609.344},
    {'name': 'Yard', 'symbol': 'yd', 'factor': 0.9144},
    {'name': 'Kilometer', 'symbol': 'km', 'factor': 1000.0},
    {'name': 'Meter', 'symbol': 'm', 'factor': 1.0},
    {'name': 'Feet', 'symbol': 'ft', 'factor': 0.3048},

    {'name': 'Inch', 'symbol': 'in', 'factor': 0.0254},
    {
      'name': 'Feet-Inch',
      'symbol': 'ft-in',
      'factor': {'feet': 0.3048, 'inch': 0.0254}, // Special composite unit
    },
    {'name': 'Decimeter', 'symbol': 'dm', 'factor': 0.1},
    {'name': 'Nautical Mile', 'symbol': 'nmi', 'factor': 1852.0},
    {'name': 'Centimeter', 'symbol': 'cm', 'factor': 0.01},
  ];

  // State
  String inputValue = "100";
  String feetValue = "0";
  String inchValue = "0";

  int fromIndex = 0; // Mile
  int toIndex = 2; // Kilometer

  // Track which field is active on numpad
  String _activeField = "feet";

  // Scroll controllers
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();

  // Fixed height per tile
  static const double _tileHeight = 55.0;
  static const double _listHeight = 275.0;
  static const double _paddingSize = _tileHeight * 2;

  // ✅ REAL CONVERSION LOGIC
  String get resultValue {
    // Check if FROM is Feet-Inch
    bool fromIsFeetInch = units[fromIndex]['name'] == 'Feet-Inch';
    bool toIsFeetInch = units[toIndex]['name'] == 'Feet-Inch';

    // Helper to format decimals nicely
    String formatNumber(double num) {
      if (num == num.roundToDouble()) return num.toInt().toString();
      return num.toStringAsFixed(
        4,
      ).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }

    if (fromIsFeetInch) {
      // Convert Feet-Inch to meters
      double feet = double.tryParse(feetValue) ?? 0;
      double inches = double.tryParse(inchValue) ?? 0;
      double totalMeters = (feet * 0.3048) + (inches * 0.0254);

      if (toIsFeetInch) return "0ft-0in"; // Same unit, result is 0

      double toFactor = units[toIndex]['factor'] as double;
      double result = totalMeters / toFactor;

      return formatNumber(result);
    } else if (toIsFeetInch) {
      // Convert regular unit to Feet-Inch (split into feet and inches)
      double input = double.tryParse(inputValue) ?? 0;
      double fromFactor = units[fromIndex]['factor'] as double;
      double totalMeters = input * fromFactor;

      // Convert to total inches
      double totalInches = totalMeters / 0.0254;

      // Split into feet and inches
      int feet = totalInches ~/ 12; // Integer division
      double remainingInches = totalInches % 12;

      return "${feet}ft-${formatNumber(remainingInches)}in";
    } else {
      // Regular to Regular
      double input = double.tryParse(inputValue) ?? 0;
      double fromFactor = units[fromIndex]['factor'] as double;
      double toFactor = units[toIndex]['factor'] as double;
      double result = (input * fromFactor) / toFactor;

      return formatNumber(result);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leftController.jumpTo(_tileHeight * fromIndex);
      _rightController.jumpTo(_tileHeight * toIndex);
    });
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void onKeyTap(String key) {
    setState(() {
      // Determine if Feet-Inch is selected on left
      bool fromIsFeetInch = units[fromIndex]['name'] == 'Feet-Inch';

      if (fromIsFeetInch) {
        // Update feet or inches field
        if (_activeField == "feet") {
          if (key == "AC") {
            feetValue = "";
          } else if (key == "⌫") {
            if (feetValue.isNotEmpty)
              feetValue = feetValue.substring(0, feetValue.length - 1);
          } else if (key == "+/-") {
            feetValue = feetValue.startsWith("-")
                ? feetValue.substring(1)
                : "-$feetValue";
          } else if (key == ".") {
            if (!feetValue.contains(".")) feetValue += ".";
          } else {
            if (feetValue == "0")
              feetValue = key;
            else
              feetValue += key;
          }
        } else {
          if (key == "AC") {
            inchValue = "";
          } else if (key == "⌫") {
            if (inchValue.isNotEmpty)
              inchValue = inchValue.substring(0, inchValue.length - 1);
          } else if (key == "+/-") {
            inchValue = inchValue.startsWith("-")
                ? inchValue.substring(1)
                : "-$inchValue";
          } else if (key == ".") {
            if (!inchValue.contains(".")) inchValue += ".";
          } else {
            if (inchValue == "0")
              inchValue = key;
            else
              inchValue += key;
          }
        }
      } else {
        // Normal input
        if (key == "AC") {
          inputValue = "";
        } else if (key == "⌫") {
          if (inputValue.isNotEmpty)
            inputValue = inputValue.substring(0, inputValue.length - 1);
        } else if (key == "+/-") {
          inputValue = inputValue.startsWith("-")
              ? inputValue.substring(1)
              : "-$inputValue";
        } else if (key == ".") {
          if (!inputValue.contains(".")) inputValue += ".";
        } else {
          if (inputValue == "0")
            inputValue = key;
          else
            inputValue += key;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Length",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. FIXED CENTER LIST AREA
          SizedBox(
            height: _listHeight,
            child: Row(
              children: [
                // LEFT COLUMN
                Expanded(
                  child: _buildCenteredList(
                    controller: _leftController,
                    isLeft: true,
                    selectedIndex: fromIndex,
                    onSelected: (index) {
                      setState(() => fromIndex = index);
                      // When switching to Feet-Inch, default active field to "feet"
                      if (units[index]['name'] == 'Feet-Inch') {
                        _activeField = "feet";
                      }
                    },
                  ),
                ),

                // Divider
                Container(width: 1, color: Colors.grey.shade300),

                // RIGHT COLUMN
                Expanded(
                  child: _buildCenteredList(
                    controller: _rightController,
                    isLeft: false,
                    selectedIndex: toIndex,
                    onSelected: (index) {
                      setState(() => toIndex = index);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 2. NUMPAD
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  Expanded(child: _buildNumpadRow(["7", "8", "9", "⌫"])),
                  Expanded(child: _buildNumpadRow(["4", "5", "6", "AC"])),
                  Expanded(child: _buildNumpadRow(["1", "2", "3", "+/-"])),
                  Expanded(
                    child: Row(
                      children: [
                        _numpadButton(
                          Icons.swap_horiz,
                          Colors.grey.shade600,
                          onTap: () {
                            setState(() {
                              int temp = fromIndex;
                              fromIndex = toIndex;
                              toIndex = temp;
                            });
                            _leftController.animateTo(
                              _tileHeight * fromIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                            _rightController.animateTo(
                              _tileHeight * toIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                        _numpadTextButton("0", const Color(0xFF1565C0)),
                        _numpadTextButton(".", const Color(0xFF1565C0)),
                        _numpadButton(
                          Icons.settings,
                          Colors.grey.shade600,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a scrollable list with 2 blank spaces top/bottom, fixed center overlay
  Widget _buildCenteredList({
    required ScrollController controller,
    required bool isLeft,
    required int selectedIndex,
    required void Function(int) onSelected,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification) {
          double offset = notification.metrics.pixels;
          int index = (offset / _tileHeight).round();
          index = index.clamp(0, units.length - 1);

          if (index != selectedIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                onSelected(index);
              }
            });
          }
        }
        return true;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Scrollable List
          ListView.builder(
            controller: controller,
            physics: const ClampingScrollPhysics(),
            itemCount: units.length,
            padding: EdgeInsets.only(top: _paddingSize, bottom: _paddingSize),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  onSelected(index);
                  controller.animateTo(
                    _tileHeight * index,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                },
                child: Container(
                  height: _tileHeight,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          units[index]['name'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          units[index]['symbol'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Fixed Center Overlay
          SizedBox(
            height: _tileHeight,
            child: Container(
              color: isLeft ? const Color(0xFF1565C0) : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: isLeft
                  ? _buildLeftOverlay(selectedIndex)
                  : _buildRightOverlay(selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  // LEFT OVERLAY: Blue box
  Widget _buildLeftOverlay(int selectedIndex) {
    bool isFeetInch = units[selectedIndex]['name'] == 'Feet-Inch';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFeetInch)
          // TWO INPUT FIELDS (Feet + Inch)
          Row(
            children: [
              // Feet Field
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeField = "feet"),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.black,
                            ),
                            alignment: Alignment.bottomRight,
                            child: Text(
                              feetValue.isEmpty ? "0" : feetValue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          "ft",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Inch Field
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeField = "inch"),
                  child: SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey,
                            ),
                            alignment: Alignment.bottomRight,
                            child: Text(
                              inchValue.isEmpty ? "0" : inchValue,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          "in",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Align(
            alignment: AlignmentGeometry.centerEnd,
            child: Text(
              inputValue.isEmpty ? "0" : inputValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 2),
        // Unit name
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              units[selectedIndex]['name'],
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              units[selectedIndex]['symbol'],
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  // RIGHT OVERLAY: Grey box
  Widget _buildRightOverlay(int selectedIndex) {
    bool isFeetInch = units[selectedIndex]['name'] == 'Feet-Inch';

    // If right side is Feet-Inch, split the result
    if (isFeetInch) {
      // Parse the result string "Xft-Yin"
      String res = resultValue;
      List<String> parts = res.split('-');
      String ftPart = parts[0].replaceAll('ft', '');
      String inPart = parts[1].replaceAll('in', '');

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Two values: Feet and Inches
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ftPart,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              const Text(
                "ft",
                style: TextStyle(color: Colors.black87, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                inPart,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              const Text(
                "in",
                style: TextStyle(color: Colors.black87, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 2),
          // Unit name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                units[selectedIndex]['name'],
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                units[selectedIndex]['symbol'],
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ],
      );
    }

    // Normal result
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          resultValue,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              units[selectedIndex]['name'],
              style: const TextStyle(color: Colors.black, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Text(
              units[selectedIndex]['symbol'],
              style: const TextStyle(color: Colors.black87, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumpadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        if (key == "⌫") {
          return _numpadButton(
            Icons.backspace,
            const Color(0xFFD32F2F),
            onTap: () => onKeyTap(key),
            isIcon: true,
          );
        } else if (key == "AC") {
          return _numpadTextButton(key, const Color(0xFFF57C00));
        } else if (key == "+/-") {
          return _numpadTextButton(key, const Color(0xFF1E88E5));
        } else {
          return _numpadTextButton(key, const Color(0xFF1565C0));
        }
      }).toList(),
    );
  }

  Widget _numpadTextButton(String text, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: () => onKeyTap(text),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _numpadButton(
    IconData icon,
    Color color, {
    required VoidCallback onTap,
    bool isIcon = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onTap,
            child: Center(child: Icon(icon, color: Colors.white, size: 26)),
          ),
        ),
      ),
    );
  }
}
