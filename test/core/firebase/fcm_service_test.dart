import 'package:beige_creative_app/core/firebase/fcm_service.dart';
import 'package:beige_creative_app/core/providers/core_providers.dart';
import 'package:beige_creative_app/core/session/session_store.dart';
import 'package:beige_creative_app/features/notification/domain/repositories/notification_repository.dart';
import 'package:beige_creative_app/features/notification/presentation/providers/notification_list_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSessionStore extends Mock implements SessionStore {}

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MockSessionStore mockSessionStore;
  late MockNotificationRepository mockNotificationRepo;
  late ProviderContainer container;

  setUp(() {
    mockSessionStore = MockSessionStore();
    mockNotificationRepo = MockNotificationRepository();

    container = ProviderContainer(
      overrides: [
        sessionStoreProvider.overrideWithValue(mockSessionStore),
        notificationRepositoryProvider.overrideWithValue(mockNotificationRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('ensureFcmTokenRegistered does nothing when session token is null', () async {
    when(() => mockSessionStore.readToken()).thenAnswer((_) async => null);

    final service = container.read(fcmServiceProvider);
    await service.ensureFcmTokenRegistered();

    verifyNever(
      () => mockNotificationRepo.saveFcmToken(
        fcmToken: any(named: 'fcmToken'),
        sessionId: any(named: 'sessionId'),
      ),
    );
  });

  test('ensureFcmTokenRegistered calls saveFcmToken when session token is present', () async {
    when(() => mockSessionStore.readToken()).thenAnswer((_) async => 'fake_session_123');
    when(
      () => mockNotificationRepo.saveFcmToken(
        fcmToken: any(named: 'fcmToken'),
        sessionId: 'fake_session_123',
      ),
    ).thenAnswer((_) async {});

    final service = container.read(fcmServiceProvider);
    await service.ensureFcmTokenRegistered();

    verify(
      () => mockNotificationRepo.saveFcmToken(
        fcmToken: any(named: 'fcmToken'),
        sessionId: 'fake_session_123',
      ),
    ).called(1);
  });
}
