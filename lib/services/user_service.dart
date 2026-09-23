import '../models/user_profile.dart';

class UserService {
  Future<UserProfile> getUserProfile() async {
    // Simüle edilmiş ağ gecikmesi
    await Future.delayed(const Duration(seconds: 1));

    return UserProfile(
      id: 'usr_123',
      firstName: 'Mahmut Eren',
      lastName: 'Yılmaz',
      email: 'mahmut.eren@example.com',
      phone: '+90 555 123 4567',
      rating: 4.8,
    );
  }
}

