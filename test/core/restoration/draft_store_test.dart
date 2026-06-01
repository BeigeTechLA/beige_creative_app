import 'package:beige_creative_app/core/restoration/draft_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SignUpDraft serialization', () {
    test('toJson omits null fields', () {
      const draft = SignUpDraft(firstName: 'A', step1Progress: 1);
      final json = draft.toJson();
      expect(json, {
        'firstName': 'A',
        'step1Progress': 1,
      });
    });

    test('fromJson round-trip preserves fields', () {
      const original = SignUpDraft(
        crewMemberId: 42,
        email: 'a@b.co',
        firstName: 'Alice',
        lastName: 'Doe',
        location: 'NYC',
        workingDistance: '25',
        primaryRole: 'photo',
        experience: '3y',
        hourlyRate: '50',
        bio: 'short',
        skills: 'a,b',
        equipments: 'x,y',
        step1Progress: 30,
        step2Progress: 60,
        currentRoute: '/signup-step-3',
      );
      final restored = SignUpDraft.fromJson(original.toJson());
      expect(restored.crewMemberId, 42);
      expect(restored.email, 'a@b.co');
      expect(restored.firstName, 'Alice');
      expect(restored.lastName, 'Doe');
      expect(restored.location, 'NYC');
      expect(restored.workingDistance, '25');
      expect(restored.primaryRole, 'photo');
      expect(restored.experience, '3y');
      expect(restored.hourlyRate, '50');
      expect(restored.bio, 'short');
      expect(restored.skills, 'a,b');
      expect(restored.equipments, 'x,y');
      expect(restored.step1Progress, 30);
      expect(restored.step2Progress, 60);
      expect(restored.currentRoute, '/signup-step-3');
    });

    test('fromRouteExtra accepts existing step-2 extra shape', () {
      final draft = SignUpDraft.fromRouteExtra({
        'crewMemberId': 7,
        'email': 'x@y.z',
        'firstName': 'Bob',
        'lastName': 'Lee',
        'step1Progress': 30,
      }, currentRoute: '/signup-step-2');
      expect(draft.crewMemberId, 7);
      expect(draft.email, 'x@y.z');
      expect(draft.step1Progress, 30);
      expect(draft.currentRoute, '/signup-step-2');
    });

    test('mergeOver prefers this over other for null fields', () {
      const a = SignUpDraft(firstName: 'A', step1Progress: 1);
      const b = SignUpDraft(firstName: 'B', lastName: 'B', step2Progress: 2);
      final m = a.mergeOver(b);
      expect(m.firstName, 'A');
      expect(m.lastName, 'B');
      expect(m.step1Progress, 1);
      expect(m.step2Progress, 2);
    });
  });

  group('DraftStore round-trip', () {
    late SharedPreferences prefs;
    late DraftStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = DraftStore(prefs);
    });

    test('readSignUpDraft returns null when nothing stored', () {
      expect(store.readSignUpDraft(), isNull);
    });

    test('write then read returns the draft', () async {
      const draft = SignUpDraft(firstName: 'Foo', step1Progress: 30);
      await store.writeSignUpDraft(draft);
      final read = store.readSignUpDraft();
      expect(read, isNotNull);
      expect(read!.firstName, 'Foo');
      expect(read.step1Progress, 30);
    });

    test('clearAll wipes the draft', () async {
      await store.writeSignUpDraft(const SignUpDraft(firstName: 'Foo'));
      await store.clearAll();
      expect(store.readSignUpDraft(), isNull);
    });

    test('readSignUpDraft drops corrupt JSON', () async {
      await prefs.setString(DraftKeys.signUp, '{not json');
      expect(store.readSignUpDraft(), isNull);
      expect(prefs.getString(DraftKeys.signUp), isNull);
    });
  });
}
