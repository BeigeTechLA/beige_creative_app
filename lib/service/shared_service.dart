    // import 'package:shared_preferences/shared_preferences.dart';
    //
    // class SharedService {
    //   static String imageURL = "https://development-shambhavi.s3.amazonaws.com/nextgengurukul/";
    //
    //   static Future<bool> isLoggedIn() async {
    //     final prefs = await SharedPreferences.getInstance();
    //     String? token = prefs.getString('token');
    //     return token != null && token.isNotEmpty;
    //   }
    //
    //   static Future<void> setLoginDetails(Map<String, dynamic> loginData) async {
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.setString('token', loginData['token']);
    //
    //     final userData = loginData['userData'] as Map<String, dynamic>;
    //
    //     await prefs.setString('name', userData['name'] ?? '');
    //     await prefs.setString('email', userData['email'] ?? '');
    //     await prefs.setInt('id', userData['id'] ?? -1);
    //   }
    //
    //   static Future<Map<String, dynamic>> getUserData() async {
    //     final prefs = await SharedPreferences.getInstance();
    //     String name = prefs.getString('name') ?? '';
    //     String email = prefs.getString('email') ?? '';
    //     String token = prefs.getString('token') ?? '';
    //     int id = prefs.getInt('id') ?? -1;
    //
    //     return {
    //       'name': name,
    //       'email': email,
    //       'token': token,
    //       'id': id,
    //     };
    //   }
    //
    //   static Future<void> clearUserData() async {
    //     final prefs = await SharedPreferences.getInstance();
    //     await prefs.remove('name');
    //     await prefs.remove('email');
    //     await prefs.remove('token');
    //     await prefs.remove('id');
    //   }
    //
    //   static String getImageURL(String image) {
    //     return imageURL + image;
    //   }
    // }


    import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';

    class SharedService {
      static String imageURL = AppConfig.imageUrl; // Using image URL from AppConfig


      /// Save user login details from API response
      static Future<void> setLoginDetails(Map<String, dynamic> response) async {
        final prefs = await SharedPreferences.getInstance();

        final data = response['data'] ?? {};
        final userData = data['user'] ?? {};

        // Extract values safely
        final String token = data['token'] ?? '';
        final int environmentId = userData['environment_id'] ?? -1;
        final String folder = userData['folder'] ?? '';
        final String name = userData['name'] ?? '';
        final String email = userData['email'] ?? '';

        final String designation = userData['designation'] ?? '';
        final String department = userData['department'] ?? '';
        final String departmentId = userData['department_id'] ?? '';

        // Store in SharedPreferences
        await prefs.setString('token', token);
        await prefs.setString('email', email);
        await prefs.setInt('environment_id', environmentId);
        await prefs.setString('folder', folder);
        await prefs.setString('name', name);
        await prefs.setString('designation', designation);
        await prefs.setString('department', department);
        await prefs.setString('department_id', departmentId);
        await prefs.setBool('isLoggedIn', true);

        // Optional: print for debugging
        print("🔐 token: $token");
        print("🌍 environment_id: $environmentId");
        print("📂 folder: $folder");
        print("👤 name: $name");
        print("🏢 department: $department");
        print("🆔 department_id: $departmentId");
        print("✅ isLoggedIn: true");
        print("🎉 All login details saved to SharedPreferences");
      }

      /// Retrieve user data
      static Future<Map<String, dynamic>> getUserData() async {
        final prefs = await SharedPreferences.getInstance();

        String name = prefs.getString('name') ?? '';
        String designation = prefs.getString('designation') ?? '';
        String department = prefs.getString('department') ?? '';
        String departmentId = prefs.getString('department_id') ?? '';
        String token = prefs.getString('token') ?? '';
        int environmentId = prefs.getInt('environment_id') ?? -1;
        String folder = prefs.getString('folder') ?? '';

        return {
          'name': name,
          'nameInitial':
          name.isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : '',
          'designation': designation,
          'department': department,
          'departmentId': departmentId,
          'token': token,
          'environmentId': environmentId,
          'folder': folder,
        };
      }

      /// Clear user data on logout
      static Future<void> logout() async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        print("🗑️ User data cleared from SharedPreferences");
      }

      /// Get stored token
      static Future<String?> getToken() async {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('token');
      }
    }

