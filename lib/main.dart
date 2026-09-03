import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:units_plus/screens/length_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(ProviderScope(child: MyApp()));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Your design mockup size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Units Plus',
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF333333),
            // Set text theme to support .sp
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: child,
        );
      },
      child: const UnitsPlusHome(),
    );
  }
}

class UnitsPlusHome extends StatelessWidget {
  const UnitsPlusHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. The Blue App Bar at the top
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0), // Deep Blue
        title: const Text(
          "Units Plus",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        elevation: 0,
      ),

      // 2. The Grid of Categories
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3, // 3 columns
          crossAxisSpacing: 12, // Horizontal space between tiles
          mainAxisSpacing: 20, // Vertical space between tiles
          childAspectRatio: 0.75, // Makes the tiles taller than they are wide

          children: [
            // Row 1
            _CategoryTile(
              color: const Color(0xFFCDDC39),
              icon: Icons.square_foot,
              label: 'Area',
            ),
            _CategoryTile(
              color: const Color(0xFF4CAF50),
              icon: Icons.attach_money,
              label: 'Currency',
            ),
            _CategoryTile(
              color: const Color(0xFF424242),
              icon: Icons.code,
              label: 'Data',
            ),

            // Row 2
            _CategoryTile(
              color: const Color(0xFFFF5252),
              icon: Icons.local_gas_station,
              label: 'Fuel-Mileage',
            ),
            // LENGTH TILE WITH NAVIGATION
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LengthScreen()),
                );
              },
              child: _CategoryTile(
                color: const Color(0xFF2196F3),
                icon: Icons.straighten,
                label: 'Length',
              ),
            ),
            _CategoryTile(
              color: const Color(0xFFAB47BC),
              icon: Icons.flash_on,
              label: 'Power',
            ),

            // Row 3
            _CategoryTile(
              color: const Color(0xFF3F51B5),
              icon: Icons.speed,
              label: 'Pressure',
            ),
            _CategoryTile(
              color: const Color(0xFF26C6DA),
              icon: Icons.speed,
              label: 'Speed',
            ),
            _CategoryTile(
              color: const Color(0xFFF44336),
              icon: Icons.thermostat,
              label: 'Temperature',
            ),

            // Row 4
            _CategoryTile(
              color: const Color(0xFF43A047),
              icon: Icons.access_time,
              label: 'Time',
            ),
            _CategoryTile(
              color: const Color(0xFFFF9800),
              icon: Icons.local_drink,
              label: 'Volume',
            ),
            _CategoryTile(
              color: const Color(0xFF795548),
              icon: Icons.fitness_center,
              label: 'Weight',
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable widget for the colorful square tiles
class _CategoryTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _CategoryTile({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The colored square box
        Container(
          width: 70, // Width of the square
          height: 70, // Height of the square
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),

        // The text label below the box
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
