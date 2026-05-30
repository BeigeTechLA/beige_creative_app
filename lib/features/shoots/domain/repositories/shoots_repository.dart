import '../../../../model_class/shoot_count_model.dart' as count_model;
import '../../../../model_class/shoots_model.dart';
import '../../../../model_class/upcoming_shootview_model.dart';

abstract class ShootsRepository {
  /// GET `creator/project-details/$id`. Throws on non-2xx or `error: true`.
  Future<MyData> fetchProjectDetail(int projectId);

  /// POST `creator/accept-project` with `{project_id, status}` — status is
  /// `accepted` or `declined`. Optional `reason`/`comment` carry through for
  /// declines. Legacy ShootsScreen passed `{project_id, crew_accept: 1|2}`
  /// which is bridged here behind the typed status enum.
  Future<void> respondToProject({
    required int projectId,
    required String status,
    String? reason,
    String? comment,
  });

  /// GET `creator/dashboard-details`. Returns full shoots list backing the
  /// ShootsScreen list view (hydrated, then filtered client-side by search).
  Future<List<Shoot>> fetchShoots();

  /// GET `creator/shoot-count`. Returns aggregate counters used by the four
  /// stat cards at the top of ShootsScreen.
  Future<count_model.Data> fetchShootCount();
}
