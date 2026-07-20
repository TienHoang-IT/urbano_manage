import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = "isDarkMode";
  
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_themeKey)) {
      _isDarkMode = prefs.getBool(_themeKey) ?? true;
    } else {
      _isDarkMode = true; // Default is Dark Mode
    }
    AppColors.isDarkMode = _isDarkMode;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    AppColors.isDarkMode = _isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }
}
