


    import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

    class SharedService {
      static String imageURL = AppConfig.imageUrl; // Using image URL from AppConfig


      /// Save user login details from API response
      static Future<void> setLoginDetails(Map<String, dynamic> response) async {
        final prefs = await SharedPreferences.getInstance();

        final data = response['data'] ?? {};
        final user = data['user'] ?? {};

        // ✅ Correct mapping from API
        final String token = data['token'] ?? '';
        final int id = user['id'] ?? -1;
        final String name = user['name'] ?? '';
        final String email = user['email'] ?? '';
        final String role = user['role'] ?? '';
        final int userType = user['user_type'] ?? -1;
        final String image = user['profile_image_url'] ?? '';


        // Save data
        await prefs.setString('token', token);
        await prefs.setInt('id', id);
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        await prefs.setString('role', role);
        await prefs.setInt('user_type', userType);
        await prefs.setString('profile_image_url', image);
        await prefs.setBool('isLoggedIn', true);

        print("✅ Login data saved successfully");

        // Optional: print for debugging
        print("✅ isLoggedIn: true");
        print("🎉 All login details saved to SharedPreferences");
      }


      /// Clear user data on logout
      static Future<void> logout() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print("🗑️ User data cleared from SharedPreferences");
      }

    }

