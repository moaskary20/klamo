import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // سماء ليلية سحرية
  static const skyDeep = Color(0xFF1A2B6D);
  static const skyMid = Color(0xFF2E5BBA);
  static const skyGlow = Color(0xFF4DD0E1);
  static const skyLight = Color(0xFFB2EBF2);

  // طبيعة ومغامرة
  static const grass = Color(0xFF8BC34A);
  static const grassDark = Color(0xFF689F38);
  static const path = Color(0xFFFFB74D);

  // ألوان مرحة
  static const purple = Color(0xFF7E57C2);
  static const purpleDeep = Color(0xFF5E35B1);
  static const teal = Color(0xFF26C6DA);
  static const tealDeep = Color(0xFF00ACC1);
  static const orange = Color(0xFFFF9800);
  static const orangeWarm = Color(0xFFFFB74D);
  static const yellow = Color(0xFFFFEB3B);
  static const pink = Color(0xFFEC407A);

  static const primary = tealDeep;
  static const secondary = purple;
  static const success = grass;
  static const background = skyLight;
  static const card = Colors.white;

  static const skyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyDeep, skyMid, skyGlow, skyLight],
    stops: [0.0, 0.35, 0.72, 1.0],
  );

  static const appBarGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purpleDeep, Color(0xFF3949AB), tealDeep],
  );

  static const buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeWarm, yellow],
  );

  static const rewardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [grass, teal, purple],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFE8F5E9)],
  );

  static List<Color> worldColors = const [
    grass,
    orangeWarm,
    purple,
    teal,
    pink,
    Color(0xFF42A5F5),
  ];

  static List<LinearGradient> worldGradients = const [
    LinearGradient(colors: [grassDark, grass]),
    LinearGradient(colors: [orange, orangeWarm]),
    LinearGradient(colors: [purpleDeep, purple]),
    LinearGradient(colors: [tealDeep, teal]),
    LinearGradient(colors: [Color(0xFFD81B60), pink]),
    LinearGradient(colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)]),
  ];

  static BoxDecoration get skyBackground => const BoxDecoration(
        gradient: skyGradient,
      );

  static BoxDecoration playfulCardDecoration({Color? accent}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF3E5F5),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: (accent ?? teal).withValues(alpha: 0.25),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: skyDeep.withValues(alpha: 0.12),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: primary,
        secondary: secondary,
        tertiary: orange,
        surface: card,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.94),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: teal.withValues(alpha: 0.18)),
        ),
        shadowColor: skyDeep.withValues(alpha: 0.15),
        margin: EdgeInsets.zero,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: yellow,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        unselectedLabelStyle: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          shadowColor: orange.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.tajawal(color: purpleDeep),
        hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: teal.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: teal.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: tealDeep, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: teal.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.tajawal(
          fontWeight: FontWeight.w700,
          color: purpleDeep,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: purple.withValues(alpha: 0.2)),
        ),
      ),
      textTheme: GoogleFonts.tajawalTextTheme(),
    );

    return base.copyWith(
      textTheme: GoogleFonts.tajawalTextTheme(base.textTheme).apply(
        bodyColor: skyDeep,
        displayColor: skyDeep,
      ),
      primaryTextTheme: GoogleFonts.tajawalTextTheme(base.primaryTextTheme),
    );
  }
}
