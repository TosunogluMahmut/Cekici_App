import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  static const String _keyRememberMe = 'auth_remember_me';
  static const String _keyCurrentUser = 'auth_current_user';
  static const String _keyUsersDb = 'auth_registered_users';

  /// Cihaz hafızasındaki "Beni Hatırla" bayrağını ve kayıtlı kullanıcıyı kontrol eder.
  Future<UserProfile?> getRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    if (!rememberMe) return null;

    final userJson = prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> map = jsonDecode(userJson);
      return UserProfile.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Kullanıcı girişi yapar.
  Future<UserProfile> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    // Simüle edilmiş ağ gecikmesi
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    final usersDbJson = prefs.getString(_keyUsersDb);
    Map<String, dynamic> usersMap = {};

    if (usersDbJson != null) {
      try {
        usersMap = jsonDecode(usersDbJson);
      } catch (_) {}
    }

    final normalizedEmail = email.trim().toLowerCase();

    // Kayıtlı kullanıcılarda ara
    if (usersMap.containsKey(normalizedEmail)) {
      final userData = usersMap[normalizedEmail] as Map<String, dynamic>;
      final savedPassword = userData['password'] as String?;

      if (savedPassword != password) {
        throw Exception('Girdiğiniz şifre hatalı. Lütfen tekrar deneyin.');
      }

      final profile = UserProfile.fromJson(userData['profile'] as Map<String, dynamic>);
      await _saveSession(profile, rememberMe, prefs);
      return profile;
    }

    // İlk defa varsayılan demo hesabı ile giriş yapılıyorsa
    if (normalizedEmail == 'demo@cekici.com' && password == '123456') {
      final defaultProfile = UserProfile(
        id: 'usr_demo',
        firstName: 'Mahmut Eren',
        lastName: 'Yılmaz',
        email: 'demo@cekici.com',
        phone: '+90 555 123 4567',
        rating: 4.8,
      );
      await _saveSession(defaultProfile, rememberMe, prefs);
      return defaultProfile;
    }

    throw Exception('Bu e-posta adresiyle kayıtlı bir hesap bulunamadı.');
  }

  /// Yeni kullanıcı kaydı oluşturur.
  Future<UserProfile> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required bool rememberMe,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final prefs = await SharedPreferences.getInstance();
    final usersDbJson = prefs.getString(_keyUsersDb);
    Map<String, dynamic> usersMap = {};

    if (usersDbJson != null) {
      try {
        usersMap = jsonDecode(usersDbJson);
      } catch (_) {}
    }

    final normalizedEmail = email.trim().toLowerCase();

    if (usersMap.containsKey(normalizedEmail)) {
      throw Exception('Bu e-posta adresi zaten kullanımda. Giriş yapmayı deneyin.');
    }

    final newProfile = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      rating: 5.0,
    );

    usersMap[normalizedEmail] = {
      'password': password,
      'profile': newProfile.toJson(),
    };

    await prefs.setString(_keyUsersDb, jsonEncode(usersMap));
    await _saveSession(newProfile, rememberMe, prefs);

    return newProfile;
  }

  /// Oturum kapatır.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUser);
    await prefs.setBool(_keyRememberMe, false);
  }

  /// Profil güncellendiğinde aktif oturumu da günceller.
  Future<void> updateActiveUser(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_keyCurrentUser) != null) {
      await prefs.setString(_keyCurrentUser, jsonEncode(profile.toJson()));
    }

    // Ayrıca veri tabanını da güncelle
    final usersDbJson = prefs.getString(_keyUsersDb);
    if (usersDbJson != null) {
      try {
        final Map<String, dynamic> usersMap = jsonDecode(usersDbJson);
        final normalizedEmail = profile.email.trim().toLowerCase();
        if (usersMap.containsKey(normalizedEmail)) {
          final userData = usersMap[normalizedEmail] as Map<String, dynamic>;
          userData['profile'] = profile.toJson();
          usersMap[normalizedEmail] = userData;
          await prefs.setString(_keyUsersDb, jsonEncode(usersMap));
        }
      } catch (_) {}
    }
  }

  Future<void> _saveSession(
    UserProfile profile,
    bool rememberMe,
    SharedPreferences prefs,
  ) async {
    await prefs.setString(_keyCurrentUser, jsonEncode(profile.toJson()));
    await prefs.setBool(_keyRememberMe, rememberMe);
  }
}

