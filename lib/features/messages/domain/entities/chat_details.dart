import 'package:flutter/foundation.dart';

import 'participant.dart';
import 'shared_file.dart';

@immutable
class ContactInfo {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  const ContactInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
  });
}

@immutable
class ChatDetails {
  final String conversationId;
  /// Room display name (`room.display_name` / `room.name`) — used by the
  /// details hero (title + avatar initials). Falls back to empty when the
  /// backend ships neither.
  final String roomName;
  final ContactInfo contact;
  final List<Participant> participants;
  final List<SharedFile> sharedFiles;

  const ChatDetails({
    required this.conversationId,
    required this.roomName,
    required this.contact,
    required this.participants,
    required this.sharedFiles,
  });
}
