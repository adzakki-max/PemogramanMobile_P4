import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(name: '', email: '');
  bool _isLoading = true;
  bool _isDarkMode = false;
  int _visitCount = 0;
  List<String> _favorites = [];

  User get user => _user;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _isDarkMode;
  int get visitCount => _visitCount;
  List<String> get favorites => _favorites;

  UserProvider() {
    _loadData();
  }

  // Memuat data dari SharedPreferences saat inisialisasi
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load User Data
    final name = prefs.getString('user_name') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _user = User(name: name, email: email, isLoggedIn: isLoggedIn);

    // 2. Load Dark Mode Preference (Latihan 1)
    _isDarkMode = prefs.getBool('is_dark_mode') ?? false;

    // 3. Counter Kunjungan (Latihan 2)
    int count = prefs.getInt('visit_count') ?? 0;
    count++;
    await prefs.setInt('visit_count', count);
    _visitCount = count;

    // 4. Load Daftar Favorit (Latihan 3)
    _favorites = prefs.getStringList('favorites') ?? [];

    _isLoading = false;
    notifyListeners();
  }

  // Toggle Tema Dark/Light Mode (Latihan 1)
  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    _isDarkMode = isDark;
    notifyListeners();
  }

  // Menyimpan data user
  Future<void> updateUser(User newUser) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', newUser.name);
    await prefs.setString('user_email', newUser.email);
    await prefs.setBool('is_logged_in', newUser.isLoggedIn);

    _user = newUser;
    _isLoading = false;
    notifyListeners();
  }

  // Logout: hapus data user (kecuali email)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.setBool('is_logged_in', false);

    _user = _user.copyWith(name: '', isLoggedIn: false);
    notifyListeners();
  }

  // Tambah Favorit (Latihan 3)
  Future<void> addFavorite(String item) async {
    if (item.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _favorites.add(item.trim());
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }

  // Hapus Favorit (Latihan 3)
  Future<void> removeFavorite(String item) async {
    final prefs = await SharedPreferences.getInstance();
    _favorites.remove(item);
    await prefs.setStringList('favorites', _favorites);
    notifyListeners();
  }
}