import 'package:flutter/foundation.dart';

/// Typed args for `/featured-work-details`. Replaces the non-null
/// `state.extra as Map<String,dynamic>` cast in the route builder (P15).
@immutable
class FeaturedWorkDetailsArgs {
  const FeaturedWorkDetailsArgs({
    required this.title,
    required this.images,
  });

  final String title;
  final List<dynamic> images;

  Map<String, dynamic> toExtra() => {
        'title': title,
        'images': images,
      };

  factory FeaturedWorkDetailsArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return FeaturedWorkDetailsArgs(
      title: (m['title'] as String?) ?? '',
      images: (m['images'] as List?) ?? const [],
    );
  }
}

/// Typed args for `/change-password`. Replaces the bare-`String` extra cast
/// (the only non-map `state.extra` in the app).
@immutable
class ChangePasswordArgs {
  const ChangePasswordArgs({required this.email});

  final String email;

  /// `/change-password` historically passed `extra: String`. Keep that shape
  /// so legacy callers keep working until C4 sweeps them.
  Object toExtra() => email;

  factory ChangePasswordArgs.fromExtra(Object? extra) {
    if (extra is String) return ChangePasswordArgs(email: extra);
    if (extra is Map) {
      return ChangePasswordArgs(
        email: (extra['email'] as String?) ?? '',
      );
    }
    return const ChangePasswordArgs(email: '');
  }
}

/// Typed args for `/profile-otp`.
@immutable
class ProfileOtpArgs {
  const ProfileOtpArgs({required this.email});

  final String email;

  Map<String, dynamic> toExtra() => {'email': email};

  factory ProfileOtpArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return ProfileOtpArgs(email: (m['email'] as String?) ?? '');
  }
}

/// Typed args for `/new-password`.
@immutable
class ProfileNewPasswordArgs {
  const ProfileNewPasswordArgs({required this.email, required this.otp});

  final String email;
  final String otp;

  Map<String, dynamic> toExtra() => {'email': email, 'otp': otp};

  factory ProfileNewPasswordArgs.fromExtra(Object? extra) {
    final m = (extra as Map?)?.cast<String, dynamic>() ?? const {};
    return ProfileNewPasswordArgs(
      email: (m['email'] as String?) ?? '',
      otp: (m['otp'] as String?) ?? '',
    );
  }
}
