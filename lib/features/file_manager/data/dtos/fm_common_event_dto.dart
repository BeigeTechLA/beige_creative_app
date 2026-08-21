import '../../domain/models/fm_common_event.dart';
import 'fm_envelope_dto.dart';

/// Entry in `GET /external-file-manager/common-events`.
///
/// ```json
/// {
///   "eventId": 2,
///   "eventName": "Diwana December Event",
///   "eventSlug": "diwana_december_event",
///   "externalId": "event_diwana_december_event_1776415230475",
///   "rootPath": "Event - Diwana December Event/",
///   "visibleUntil": null,
///   "createdByUserId": 198,
///   "createdAt": "…",
///   "updatedAt": "…"
/// }
/// ```
class FmCommonEventDto {
  static FmCommonEvent fromJson(Map<String, dynamic> j) {
    return FmCommonEvent(
      eventId: FmJson.asInt(j['eventId']) ?? 0,
      eventName: (j['eventName'] ?? '').toString(),
      eventSlug: (j['eventSlug'] ?? '').toString(),
      externalId: (j['externalId'] ?? '').toString(),
      rootPath: (j['rootPath'] ?? '').toString(),
      visibleUntil: FmJson.asDate(j['visibleUntil']),
      createdByUserId: FmJson.asInt(j['createdByUserId']),
      createdAt: FmJson.asDate(j['createdAt']),
      updatedAt: FmJson.asDate(j['updatedAt']),
    );
  }

  static List<FmCommonEvent> listFromJson(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(fromJson)
          .toList();
    }
    if (raw is Map && raw['items'] is List) {
      return FmJson.asList(raw['items']).map(fromJson).toList();
    }
    return const [];
  }
}
