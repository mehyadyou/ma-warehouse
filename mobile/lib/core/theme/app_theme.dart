import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4ADE80);
  static const Color secondaryColor = Color(0xFF34A853);
  static const Color errorColor = Color(0xFFEA4335);

  static const Color _bg = Color(0xFF0F1114);
  static const Color _surface = Color(0xFF1A1D22);
  static const Color _surfaceAlt = Color(0xFF22262C);
  static const Color _green = Color(0xFF4ADE80);
  static const Color _border = Color(0xFF2A2E35);
  static const Color _textPrimary = Color(0xFFE5E7EB);
  static const Color _textSecondary = Color(0xFF9CA3AF);
  static const Color _hint = Color(0xFF6B7280);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bg,
      canvasColor: _bg,
      dialogBackgroundColor: _surface,
      colorScheme: const ColorScheme.dark(
        primary: _green,
        onPrimary: Colors.black,
        secondary: _green,
        onSecondary: Colors.black,
        surface: _surface,
        onSurface: _textPrimary,
        error: errorColor,
        onError: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _textPrimary),
        bodyMedium: TextStyle(color: _textPrimary),
        bodySmall: TextStyle(color: _textSecondary),
        titleLarge: TextStyle(color: _textPrimary),
        titleMedium: TextStyle(color: _textPrimary),
        titleSmall: TextStyle(color: _textPrimary),
        labelLarge: TextStyle(color: _textPrimary),
        labelMedium: TextStyle(color: _textPrimary),
        labelSmall: TextStyle(color: _textSecondary),
      ),
      iconTheme: const IconThemeData(color: _textPrimary),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _surface,
        foregroundColor: _textPrimary,
        iconTheme: IconThemeData(color: _textPrimary),
        titleTextStyle: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      ),
        dialogTheme: const DialogThemeData(
        backgroundColor: _surface,
        titleTextStyle: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        contentTextStyle: TextStyle(color: _textPrimary, fontSize: 14),
         ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _green),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceAlt,
        hintStyle: const TextStyle(color: _hint),
        labelStyle: const TextStyle(color: _textSecondary),
        floatingLabelStyle: const TextStyle(color: _green),
        prefixIconColor: _textSecondary,
        suffixIconColor: _textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: _textPrimary),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(_surface),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _border),
          ),
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: _surface,
        textStyle: TextStyle(color: _textPrimary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        modalBackgroundColor: _surface,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _surfaceAlt,
        contentTextStyle: TextStyle(color: _textPrimary),
      ),
      dividerTheme: const DividerThemeData(color: _border),
    );
  }

  static ThemeData get lightTheme => darkTheme;
}
