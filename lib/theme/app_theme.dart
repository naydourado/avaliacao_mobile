import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(seedColor: AppColors.roxo).copyWith(
      primary: AppColors.roxo,
      secondary: AppColors.amarelo,
      onSecondary: AppColors.roxo,
      surface: AppColors.branco,
      onSurface: AppColors.texto,
      outline: AppColors.textoSuave,
      outlineVariant: AppColors.borda,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: esquema);
    final contorno = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borda),
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fundo,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.texto,
        displayColor: AppColors.roxo,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundo,
        foregroundColor: AppColors.roxo,
        scrolledUnderElevation: 0,
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 72,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          color: AppColors.roxo,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.branco,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.borda),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.branco,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: contorno,
        enabledBorder: contorno,
        focusedBorder: contorno.copyWith(
          borderSide: const BorderSide(color: AppColors.roxo, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textoSuave),
        prefixIconColor: AppColors.roxo,
        suffixIconColor: AppColors.roxo,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.roxo,
          foregroundColor: AppColors.branco,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.roxo,
          minimumSize: const Size(48, 48),
          side: const BorderSide(color: AppColors.borda),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.branco,
        selectedColor: AppColors.roxo,
        side: const BorderSide(color: AppColors.borda),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.borda, space: 32),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.roxo,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.fundo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.roxo,
      ),
    );
  }
}
