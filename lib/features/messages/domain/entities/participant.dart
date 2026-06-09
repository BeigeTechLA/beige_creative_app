import 'package:flutter/foundation.dart';

@immutable
class Participant {
  final String id;
  final String name;
  final String role;
  final String? avatarUrl;

  const Participant({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}
