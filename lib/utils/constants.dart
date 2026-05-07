import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// AppConstants — menyimpan semua konstanta statis aplikasi.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── Supabase (isi sendiri) ──
  static final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  static final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  // ── PokeAPI ──
  static const String pokeApiBaseUrl = 'https://pokeapi.co/api/v2';

  // ── App Info ──
  static const String appName = 'Pokédex Gacha';
}

/// AppColors — palet warna utama aplikasi bertema Pokédex.
class AppColors {
  AppColors._();

  // ── Brand / Pokeball ──
  static const Color pokeBallRed = Color(0xFFDC3545);
  static const Color pokeBallWhite = Color(0xFFFFFFFF);
  static const Color pokeBallBlack = Color(0xFF1A1A2E);

  // ── Primary ──
  static const Color primary = Color(0xFFDC3545);
  static const Color primaryDark = Color(0xFFB02A37);
  static const Color accent = Color(0xFFFFCC00);
  static const Color gold = Color(0xFFFFD700);

  // ── Background & Surface ──
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textWhite = Color(0xFFFFFFFF);

  // ── Greys ──
  static const Color greyLight = Color(0xFFE5E7EB);
  static const Color greyMedium = Color(0xFF9CA3AF);
  static const Color greyDark = Color(0xFF4B5563);

  // ── Rarity Tiers ──
  static const Color common = Color(0xFF9CA3AF);
  static const Color rare = Color(0xFF3B82F6);
  static const Color epic = Color(0xFF8B5CF6);
  static const Color legendary = Color(0xFFFFD700);

  // ── Utility ──
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
}
