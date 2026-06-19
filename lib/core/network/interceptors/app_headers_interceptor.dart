import 'dart:io' show Platform;

import 'package:dio/dio.dart';

/// Stamps every outbound request with the BEIGE app-identity headers the
/// backend uses for routing, analytics, and per-surface feature flags:
///
/// - `device_type`     — `"android"` or `"iOS"` (String).
/// - `user_type_name`  — `"client"` or `"creative"` (String).
/// - `user_type`       — `2` = Creative, `3` = Client (int, sent as string).
///
/// This client is the **creative** (crew-side) surface, so `userTypeName` and
/// `userType` default to the creative pair. Values are resolved once at
/// construction and reused for every request to avoid per-call Platform reads.
class AppHeadersInterceptor extends Interceptor {
  static const int userTypeCreative = 2;
  static const int userTypeClient = 3;

  final String deviceType;
  final String userTypeName;
  final int userType;

  AppHeadersInterceptor({
    String? deviceType,
    this.userTypeName = 'creative',
    this.userType = userTypeCreative,
  }) : deviceType = deviceType ?? (Platform.isIOS ? 'iOS' : 'android');

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['device_type'] = deviceType;
    options.headers['user_type_name'] = userTypeName;
    options.headers['user_type'] = userType;
    handler.next(options);
  }
}
