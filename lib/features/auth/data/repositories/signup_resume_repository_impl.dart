import 'dart:convert';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../model_class/myprofile_model.dart';
import '../../domain/models/signup_step1_prefill.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/signup_resume_repository.dart';

class SignupResumeRepositoryImpl implements SignupResumeRepository {
  final DioClient _client;

  SignupResumeRepositoryImpl(this._client);

  @override
  Future<SignupStep1Prefill> fetchStep1Prefill() async {
    final response = await _client.dio.post<dynamic>(
      ApiEndpoints.profiledetails,
      data: <String, dynamic>{},
    );
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Profile details returned an unexpected response');
    }
    if (body['error'] == true) {
      throw Exception(body['message'] ?? 'Failed to load profile details');
    }

    final rawProfile = body['data'];
    if (rawProfile is! Map) {
      throw Exception('Profile details returned an unexpected response');
    }
    final profileJson = Map<String, dynamic>.from(rawProfile);
    final rawUser = profileJson['user'] is Map
        ? Map<String, dynamic>.from(profileJson['user'] as Map)
        : const <String, dynamic>{};
    final profile = MyProfileModel.fromJson(body).data;
    final nested = profile.user;
    return SignupStep1Prefill(
      crewMemberId: profile.crewMemberId == 0 ? null : profile.crewMemberId,
      firstName: profile.firstName,
      lastName: profile.lastName,
      email: profile.email.isNotEmpty ? profile.email : nested.email,
      phone: profile.phoneNumber.isNotEmpty
          ? profile.phoneNumber
          : nested.phoneNumber,
      location: profile.location.isNotEmpty
          ? profile.location
          : nested.location,
      workingDistance: profile.workingDistance.isNotEmpty
          ? profile.workingDistance
          : nested.workingDistance,
      latitude: double.tryParse(nested.latitude),
      longitude: double.tryParse(nested.longitude),
      profileImageUrl: profile.profileImageUrl.isNotEmpty
          ? profile.profileImageUrl
          : (nested.profileImageUrl.isNotEmpty
                ? nested.profileImageUrl
                : nested.userProfileImageUrl),
      primaryRoles: _parseOptions(
        profileJson['primary_role'] ?? rawUser['primary_role'],
        idKeys: const ['role_id', 'id'],
        nameKeys: const ['role_name', 'name'],
      ),
      yearsOfExperience: _stringValue(
        profileJson['years_of_experience'] ?? rawUser['years_of_experience'],
      ),
      hourlyRate: _stringValue(
        profileJson['hourly_rate'] ?? rawUser['hourly_rate'],
      ),
      bio: _stringValue(profileJson['bio'] ?? rawUser['bio']),
      skills: _parseOptions(
        profileJson['skills'] ?? rawUser['skills'],
        idKeys: const ['skill_id', 'id'],
        nameKeys: const ['skill_name', 'name'],
      ),
      equipments: _parseOptions(
        profileJson['equipment_ownership'] ?? rawUser['equipment_ownership'],
        idKeys: const ['equipment_id', 'id'],
        nameKeys: const ['equipment_name', 'name'],
      ),
      socialMediaLinks: _parseSocialLinks(profile.socialMediaLinks),
      // `MyProfileModel` parses `portfolio_links` into `CrewFile`, which
      // drops the platform/url the sheet needs, so read the raw value here.
      portfolioLinks: _parseLinkList(
        profileJson['portfolio_links'] ?? rawUser['portfolio_links'],
      ),
    );
  }

  /// Flatten a raw `portfolio_links` value (JSON string or list of
  /// `{platform, url}` maps) into `{platform, url}` entries.
  static List<Map<String, dynamic>> _parseLinkList(dynamic raw) {
    dynamic decoded = raw;
    if (raw is String) {
      final value = raw.trim();
      if (value.isEmpty) return const [];
      try {
        decoded = jsonDecode(value);
      } catch (_) {
        return const [];
      }
    }
    if (decoded is! List) return const [];
    final result = <Map<String, dynamic>>[];
    for (final entry in decoded) {
      if (entry is! Map) continue;
      final platform = _stringValue(entry['platform']);
      final url = _stringValue(entry['url']);
      if (platform.isEmpty || url.isEmpty) continue;
      result.add({'platform': platform, 'url': url});
    }
    return result;
  }

  /// [MyProfileModel] already decodes `social_media_links` into a
  /// `{platform: url}` map. Flatten it into the `{platform, url}` entries
  /// the signup step 3 sheet hydrates from. Presentation maps the platform
  /// key to a display name.
  static List<Map<String, dynamic>> _parseSocialLinks(
    Map<String, dynamic> links,
  ) {
    final result = <Map<String, dynamic>>[];
    links.forEach((platform, url) {
      final platformKey = platform.trim();
      final urlValue = _stringValue(url);
      if (platformKey.isEmpty || urlValue.isEmpty) return;
      result.add({'platform': platformKey, 'url': urlValue});
    });
    return result;
  }

  static String _stringValue(dynamic value) => value?.toString().trim() ?? '';

  static List<LookupOption> _parseOptions(
    dynamic raw, {
    required List<String> idKeys,
    required List<String> nameKeys,
  }) {
    dynamic decoded = raw;
    if (raw is String) {
      final value = raw.trim();
      if (value.isEmpty) return const [];
      try {
        decoded = jsonDecode(value);
      } catch (_) {
        decoded = value.contains(',')
            ? value.split(',').map((item) => item.trim()).toList()
            : value;
      }
    }

    final values = decoded is List ? decoded : <dynamic>[decoded];
    final options = <LookupOption>[];
    final seen = <String>{};
    for (final value in values) {
      int id = 0;
      String name = '';
      if (value is Map) {
        for (final key in idKeys) {
          id = _intValue(value[key]) ?? id;
          if (id > 0) break;
        }
        for (final key in nameKeys) {
          name = _stringValue(value[key]);
          if (name.isNotEmpty) break;
        }
      } else {
        id = _intValue(value) ?? 0;
        if (id == 0) name = _stringValue(value);
      }
      if (id == 0 && name.isEmpty) continue;
      final key = id > 0 ? 'id:$id' : 'name:${name.toLowerCase()}';
      if (seen.add(key)) options.add(LookupOption(id: id, name: name));
    }
    return options;
  }

  static int? _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
