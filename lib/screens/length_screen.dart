// ---------------- LENGTH SCREEN (FEET-INCH SUPPORT) ----------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Providers for state management
final fromIndexProvider = StateProvider<int>((ref) => 0);
final toIndexProvider = StateProvider<int>((ref) => 2);
final inputValueProvider = StateProvider<String>((ref) => "100");
final feetValueProvider = StateProvider<String>((ref) => "0");
final inchValueProvider = StateProvider<String>((ref) => "0");
final activeFieldProvider = StateProvider<String>((ref) => "feet");

// Result calculation provider
final resultValueProvider = Provider<String>((ref) {
  final units = [
    {'name': 'Mile', 'symbol': 'mi', 'factor': 1609.344},
    {'name': 'Yard', 'symbol': 'yd', 'factor': 0.9144},
    {'name': 'Kilometer', 'symbol': 'km', 'factor': 1000.0},
    {'name': 'Meter', 'symbol': 'm', 'factor': 1.0},
    {'name': 'Feet', 'symbol': 'ft', 'factor': 0.3048},
    {'name': 'Inch', 'symbol': 'in', 'factor': 0.0254},
    {
      'name': 'Feet-Inch',
      'symbol': 'ft-in',
      'factor': {'feet': 0.3048, 'inch': 0.0254},
    },
    {'name': 'Decimeter', 'symbol': 'dm', 'factor': 0.1},
    {'name': 'Nautical Mile', 'symbol': 'nmi', 'factor': 1852.0},
    {'name': 'Centimeter', 'symbol': 'cm', 'factor': 0.01},
  ];

  final fromIndex = ref.watch(fromIndexProvider);
  final toIndex = ref.watch(toIndexProvider);
  final inputValue = ref.watch(inputValueProvider);
  final feetValue = ref.watch(feetValueProvider);
  final inchValue = ref.watch(inchValueProvider);

  bool fromIsFeetInch = units[fromIndex]['name'] == 'Feet-Inch';
  bool toIsFeetInch = units[toIndex]['name'] == 'Feet-Inch';

  String formatNumber(double num) {
    if (num == num.roundToDouble()) return num.toInt().toString();
    return num.toStringAsFixed(
      4,
    ).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  if (fromIsFeetInch) {
    double feet = double.tryParse(feetValue) ?? 0;
    double inches = double.tryParse(inchValue) ?? 0;
    double totalMeters = (feet * 0.3048) + (inches * 0.0254);

    if (toIsFeetInch) return "${feetValue}ft-${inchValue}in";

    double toFactor = units[toIndex]['factor'] as double;
    double result = totalMeters / toFactor;

    return formatNumber(result);
  } else if (toIsFeetInch) {
    double input = double.tryParse(inputValue) ?? 0;
    double fromFactor = units[fromIndex]['factor'] as double;
    double totalMeters = input * fromFactor;

    double totalInches = totalMeters / 0.0254;
    int feet = totalInches ~/ 12;
    double remainingInches = totalInches % 12;

    return "${feet}ft-${formatNumber(remainingInches)}in";
  } else {
    double input = double.tryParse(inputValue) ?? 0;
    double fromFactor = units[fromIndex]['factor'] as double;
    double toFactor = units[toIndex]['factor'] as double;
    double result = (input * fromFactor) / toFactor;

    return formatNumber(result);
  }
});

class LengthScreen extends ConsumerStatefulWidget {
  const LengthScreen({super.key});

  @override
  ConsumerState<LengthScreen> createState() => _LengthScreenState();
}

class _LengthScreenState extends ConsumerState<LengthScreen> {
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
      'factor': {'feet': 0.3048, 'inch': 0.0254},
    },
    {'name': 'Decimeter', 'symbol': 'dm', 'factor': 0.1},
    {'name': 'Nautical Mile', 'symbol': 'nmi', 'factor': 1852.0},
    {'name': 'Centimeter', 'symbol': 'cm', 'factor': 0.01},
  ];

  // Scroll controllers
  final ScrollController _leftController = ScrollController();
  final ScrollController _rightController = ScrollController();

  // Fixed height per tile (responsive)
  final double _tileHeight = 67.h;
  final double _listHeight = 275.h;
  final double _paddingSize = 134.h; // _tileHeight * 2

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fromIndex = ref.read(fromIndexProvider);
      final toIndex = ref.read(toIndexProvider);
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
    final fromIsFeetInch =
        units[ref.read(fromIndexProvider)]['name'] == 'Feet-Inch';

    if (fromIsFeetInch) {
      final activeField = ref.read(activeFieldProvider);

      if (activeField == "feet") {
        final feetValue = ref.read(feetValueProvider);
        if (key == "AC") {
          ref.read(feetValueProvider.notifier).state = "";
        } else if (key == "⌫") {
          if (feetValue.isNotEmpty) {
            ref.read(feetValueProvider.notifier).state = feetValue.substring(
              0,
              feetValue.length - 1,
            );
          }
        } else if (key == "+/-") {
          ref.read(feetValueProvider.notifier).state = feetValue.startsWith("-")
              ? feetValue.substring(1)
              : "-$feetValue";
        } else if (key == ".") {
          if (!feetValue.contains(".")) {
            ref.read(feetValueProvider.notifier).state = feetValue + ".";
          }
        } else {
          if (feetValue == "0") {
            ref.read(feetValueProvider.notifier).state = key;
          } else {
            ref.read(feetValueProvider.notifier).state = feetValue + key;
          }
        }
      } else {
        final inchValue = ref.read(inchValueProvider);
        if (key == "AC") {
          ref.read(inchValueProvider.notifier).state = "";
        } else if (key == "⌫") {
          if (inchValue.isNotEmpty) {
            ref.read(inchValueProvider.notifier).state = inchValue.substring(
              0,
              inchValue.length - 1,
            );
          }
        } else if (key == "+/-") {
          ref.read(inchValueProvider.notifier).state = inchValue.startsWith("-")
              ? inchValue.substring(1)
              : "-$inchValue";
        } else if (key == ".") {
          if (!inchValue.contains(".")) {
            ref.read(inchValueProvider.notifier).state = inchValue + ".";
          }
        } else {
          if (inchValue == "0") {
            ref.read(inchValueProvider.notifier).state = key;
          } else {
            ref.read(inchValueProvider.notifier).state = inchValue + key;
          }
        }
        _normalizeFeetInch();
      }
    } else {
      final inputValue = ref.read(inputValueProvider);
      if (key == "AC") {
        ref.read(inputValueProvider.notifier).state = "";
      } else if (key == "⌫") {
        if (inputValue.isNotEmpty) {
          ref.read(inputValueProvider.notifier).state = inputValue.substring(
            0,
            inputValue.length - 1,
          );
        }
      } else if (key == "+/-") {
        ref.read(inputValueProvider.notifier).state = inputValue.startsWith("-")
            ? inputValue.substring(1)
            : "-$inputValue";
      } else if (key == ".") {
        if (!inputValue.contains(".")) {
          ref.read(inputValueProvider.notifier).state = inputValue + ".";
        }
      } else {
        if (inputValue == "0") {
          ref.read(inputValueProvider.notifier).state = key;
        } else {
          ref.read(inputValueProvider.notifier).state = inputValue + key;
        }
      }
    }
  }

  void _normalizeFeetInch() {
    double feet = double.tryParse(ref.read(feetValueProvider)) ?? 0;
    double inches = double.tryParse(ref.read(inchValueProvider)) ?? 0;

    // 12 inches भएमा feet मा convert गर्ने
    if (inches >= 12) {
      feet += (inches / 12).floor();
      inches = inches % 12;

      ref.read(feetValueProvider.notifier).state = feet.toString();
      ref.read(inchValueProvider.notifier).state = inches.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromIndex = ref.watch(fromIndexProvider);
    final toIndex = ref.watch(toIndexProvider);
    final inputValue = ref.watch(inputValueProvider);
    final feetValue = ref.watch(feetValueProvider);
    final inchValue = ref.watch(inchValueProvider);
    final resultValue = ref.watch(resultValueProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Length",
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. FIXED CENTER LIST AREA
          Expanded(
            flex: 5,
            child: SizedBox(
              height: _listHeight,
              child: Row(
                children: [
                  // LEFT COLUMN
                  Expanded(
                    child: _buildCenteredList(
                      controller: _leftController,
                      isLeft: true,
                      selectedIndex: fromIndex,
                      inputValue: inputValue,
                      feetValue: feetValue,
                      inchValue: inchValue,
                      resultValue: resultValue,
                      onSelected: (index) {
                        ref.read(fromIndexProvider.notifier).state = index;
                        if (units[index]['name'] == 'Feet-Inch') {
                          ref.read(activeFieldProvider.notifier).state = "feet";
                        }
                      },
                    ),
                  ),

                  // Divider
                  Container(width: 1.w, color: Colors.grey.shade300),

                  // RIGHT COLUMN
                  Expanded(
                    child: _buildCenteredList(
                      controller: _rightController,
                      isLeft: false,
                      selectedIndex: toIndex,
                      inputValue: inputValue,
                      feetValue: feetValue,
                      inchValue: inchValue,
                      resultValue: resultValue,
                      onSelected: (index) {
                        ref.read(toIndexProvider.notifier).state = index;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. NUMPAD
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(2.w),
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
                            final temp = fromIndex;
                            ref.read(fromIndexProvider.notifier).state =
                                toIndex;
                            ref.read(toIndexProvider.notifier).state = temp;

                            _leftController.animateTo(
                              _tileHeight * toIndex,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                            _rightController.animateTo(
                              _tileHeight * temp,
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
    required String inputValue,
    required String feetValue,
    required String inchValue,
    required String resultValue,
    required void Function(int) onSelected,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollEndNotification) {
          double offset = notification.metrics.pixels;
          int index = (offset / _tileHeight).round();
          index = index.clamp(0, units.length - 1);

          // Snap to exact position
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.hasClients) {
              controller.animateTo(
                _tileHeight * index,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOut,
              );
            }
          });

          if (index != selectedIndex) {
            onSelected(index);
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 1.w),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          units[index]['name'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          units[index]['symbol'],
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
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
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: isLeft
                  ? _buildLeftOverlay(
                      selectedIndex,
                      inputValue,
                      feetValue,
                      inchValue,
                    )
                  : _buildRightOverlay(selectedIndex, resultValue),
            ),
          ),
        ],
      ),
    );
  }

  // LEFT OVERLAY: Blue box
  Widget _buildLeftOverlay(
    int selectedIndex,
    String inputValue,
    String feetValue,
    String inchValue,
  ) {
    bool isFeetInch = units[selectedIndex]['name'] == 'Feet-Inch';
    // Feet-Inch input लाई normalize गर्ने
    if (isFeetInch) {
      double feet = double.tryParse(feetValue) ?? 0;
      double inches = double.tryParse(inchValue) ?? 0;

      // 12 inches भएमा feet मा convert गर्ने
      if (inches >= 12) {
        feet += (inches / 12).floor();
        inches = inches % 12;

        // State update गर्ने
        ref.read(feetValueProvider.notifier).state = feet.toString();
        ref.read(inchValueProvider.notifier).state = inches.toString();
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        if (isFeetInch)
          Row(
            children: [
              // Feet Field
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(activeFieldProvider.notifier).state = "feet",
                  child: SizedBox(
                    height: 40.h,
                    width: 60.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40.h,
                            width: 60.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              color: Colors.black,
                            ),
                            alignment: Alignment.bottomRight,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                String text = feetValue.isEmpty
                                    ? "0"
                                    : feetValue;
                                double baseFontSize = 28.sp;

                                // List of font sizes to try
                                List<double> fontSizes = [
                                  baseFontSize, // 100% - 1 line
                                  baseFontSize * 0.5, // 50% - 2 lines
                                  baseFontSize * 0.3333, // 33.33% - 3 lines
                                  baseFontSize * 0.25, // 25% - 4 lines
                                  baseFontSize * 0.2, // 20% - 5 lines
                                  baseFontSize * 0.1667, // 16.67% - 6 lines
                                ];

                                double selectedFontSize = baseFontSize;

                                for (int i = 0; i < fontSizes.length; i++) {
                                  double charWidth = fontSizes[i] * 0.6;
                                  int charsPerLine =
                                      (constraints.maxWidth / charWidth)
                                          .floor();
                                  if (charsPerLine < 1) charsPerLine = 1;

                                  int estimatedLines =
                                      (text.length / charsPerLine).ceil();
                                  if (estimatedLines < 1) estimatedLines = 1;

                                  if (estimatedLines <= (i + 1)) {
                                    selectedFontSize = fontSizes[i];
                                    break;
                                  }
                                }

                                return Text(
                                  text,
                                  maxLines: 6,
                                  textAlign: TextAlign.right,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: selectedFontSize,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "ft",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              // Inch Field
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      ref.read(activeFieldProvider.notifier).state = "inch",
                  child: SizedBox(
                    height: 40.h,
                    width: 60.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40.h,
                            width: 60.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.r),
                              color: Colors.grey,
                            ),
                            alignment: Alignment.bottomRight,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                String text = inchValue.isEmpty
                                    ? "0"
                                    : inchValue;
                                double baseFontSize = 28.sp;

                                List<double> fontSizes = [
                                  baseFontSize,
                                  baseFontSize * 0.5,
                                  baseFontSize * 0.3333,
                                  baseFontSize * 0.25,
                                  baseFontSize * 0.2,
                                  baseFontSize * 0.1667,
                                ];

                                double selectedFontSize = baseFontSize;

                                for (int i = 0; i < fontSizes.length; i++) {
                                  double charWidth = fontSizes[i] * 0.6;
                                  int charsPerLine =
                                      (constraints.maxWidth / charWidth)
                                          .floor();
                                  if (charsPerLine < 1) charsPerLine = 1;

                                  int estimatedLines =
                                      (text.length / charsPerLine).ceil();
                                  if (estimatedLines < 1) estimatedLines = 1;

                                  if (estimatedLines <= (i + 1)) {
                                    selectedFontSize = fontSizes[i];
                                    break;
                                  }
                                }

                                return Text(
                                  text,
                                  maxLines: 6,
                                  textAlign: TextAlign.right,
                                  softWrap: true,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: selectedFontSize,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          "in",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
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
            child: Container(
              constraints: BoxConstraints(maxWidth: 200.w, minWidth: 100.w),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  String text = inputValue.isEmpty ? "0" : inputValue;
                  double baseFontSize = 28.sp;

                  List<double> fontSizes = [
                    baseFontSize,
                    baseFontSize * 0.5,
                    baseFontSize * 0.3333,
                    baseFontSize * 0.25,
                    baseFontSize * 0.2,
                    baseFontSize * 0.1667,
                  ];

                  double selectedFontSize = baseFontSize;

                  for (int i = 0; i < fontSizes.length; i++) {
                    double charWidth = fontSizes[i] * 0.6;
                    int charsPerLine = (constraints.maxWidth / charWidth)
                        .floor();
                    if (charsPerLine < 1) charsPerLine = 1;

                    int estimatedLines = (text.length / charsPerLine).ceil();
                    if (estimatedLines < 1) estimatedLines = 1;

                    if (estimatedLines <= (i + 1)) {
                      selectedFontSize = fontSizes[i];
                      break;
                    }
                  }

                  return Text(
                    text,
                    maxLines: 6,
                    textAlign: TextAlign.right,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: selectedFontSize,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  );
                },
              ),
            ),
          ),
        Spacer(),
        // Unit name
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              units[selectedIndex]['name'],
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
            Text(
              units[selectedIndex]['symbol'],
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
          ],
        ),
      ],
    );
  }

  // RIGHT OVERLAY: Grey box
  Widget _buildRightOverlay(int selectedIndex, String resultValue) {
    bool isFeetInch = units[selectedIndex]['name'] == 'Feet-Inch';

    if (isFeetInch) {
      String res = resultValue;
      List<String> parts = res.split('-');
      String ftPart = parts[0].replaceAll('ft', '').trim();
      String inPart = parts[1].replaceAll('in', '').trim();

      // Ensure defaults
      if (ftPart.isEmpty) ftPart = "0";
      if (inPart.isEmpty) inPart = "0";

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // FT + IN combined with adaptive scaling
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Combine ft and in into single text for calculation
                    String combinedText = "$ftPart ft $inPart in";
                    double baseFontSize = 28.sp;

                    List<double> fontSizes = [
                      baseFontSize,
                      baseFontSize * 0.5,
                      baseFontSize * 0.3333,
                      baseFontSize * 0.25,
                      baseFontSize * 0.2,
                      baseFontSize * 0.1667,
                    ];

                    double selectedFontSize = baseFontSize;

                    for (int i = 0; i < fontSizes.length; i++) {
                      double charWidth = fontSizes[i] * 0.6;
                      int charsPerLine = (constraints.maxWidth / charWidth)
                          .floor();
                      if (charsPerLine < 1) charsPerLine = 1;

                      int estimatedLines = (combinedText.length / charsPerLine)
                          .ceil();
                      if (estimatedLines < 1) estimatedLines = 1;

                      if (estimatedLines <= (i + 1)) {
                        selectedFontSize = fontSizes[i];
                        break;
                      }
                    }

                    // return Text(
                    //   "$ftPart ft - $inPart in",
                    //   maxLines: 6,
                    //   textAlign: TextAlign.right,
                    //   softWrap: true,
                    //   style: TextStyle(
                    //     color: Colors.black,
                    //     fontSize: selectedFontSize,
                    //     fontWeight: FontWeight.bold,
                    //     height: 1.3,
                    //   ),
                    // );
                    return Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: ftPart,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: selectedFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "ft",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize:
                                  selectedFontSize *
                                  0.6, // Unit को font size सानो
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: " - ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: selectedFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: inPart,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: selectedFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "in",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize:
                                  selectedFontSize *
                                  0.6, // Unit को font size सानो
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 6,
                      textAlign: TextAlign.right,
                      softWrap: true,
                    );
                  },
                ),
              ),
              SizedBox(width: 2.w),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                units[selectedIndex]['name'],
                style: TextStyle(color: Colors.black, fontSize: 14.sp),
              ),
              SizedBox(width: 4.w),
              Text(
                units[selectedIndex]['symbol'],
                style: TextStyle(color: Colors.black87, fontSize: 14.sp),
              ),
            ],
          ),
        ],
      );
    }
    // Normal result with adaptive scaling
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Spacer(),
        Container(
          height: 40.h,
          constraints: BoxConstraints(maxWidth: 200.w, minWidth: 100.w),
          alignment: Alignment.bottomRight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              String text = resultValue;
              double baseFontSize = 28.sp;

              List<double> fontSizes = [
                baseFontSize,
                baseFontSize * 0.5,
                baseFontSize * 0.3333,
                baseFontSize * 0.25,
                baseFontSize * 0.2,
                baseFontSize * 0.1667,
              ];

              double selectedFontSize = baseFontSize;

              for (int i = 0; i < fontSizes.length; i++) {
                double charWidth = fontSizes[i] * 0.6;
                int charsPerLine = (constraints.maxWidth / charWidth).floor();
                if (charsPerLine < 1) charsPerLine = 1;

                int estimatedLines = (text.length / charsPerLine).ceil();
                if (estimatedLines < 1) estimatedLines = 1;

                if (estimatedLines <= (i + 1)) {
                  selectedFontSize = fontSizes[i];
                  break;
                }
              }

              return Text(
                text,
                maxLines: 6,
                textAlign: TextAlign.right,
                softWrap: true,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: selectedFontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              );
            },
          ),
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              units[selectedIndex]['name'],
              style: TextStyle(color: Colors.black, fontSize: 14.sp),
            ),
            SizedBox(width: 4.w),
            Text(
              units[selectedIndex]['symbol'],
              style: TextStyle(color: Colors.black87, fontSize: 14.sp),
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
        padding: EdgeInsets.all(2.w),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
          child: InkWell(
            onTap: () => onKeyTap(text),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
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
        padding: EdgeInsets.all(2.w),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(4.r),
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Icon(icon, color: Colors.white, size: 26.r),
            ),
          ),
        ),
      ),
    );
  }
}
