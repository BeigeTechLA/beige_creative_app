import 'package:flutter/foundation.dart';

import 'participant.dart';
import 'shared_file.dart';

@immutable
class LinkedShoot {
  final String id;
  final String title;
  final DateTime date;

  const LinkedShoot({
    required this.id,
    required this.title,
    required this.date,
  });
}

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
  final ContactInfo contact;
  final List<Participant> participants;
  final LinkedShoot? linkedShoot;
  final List<SharedFile> sharedFiles;
  final String notes;

  const ChatDetails({
    required this.conversationId,
    required this.contact,
    required this.participants,
    required this.sharedFiles,
    required this.notes,
    this.linkedShoot,
  });
}
