import '../../../../model_class/shoot_count_model.dart' as count_model;
import '../../../../model_class/shoots_model.dart';
import '../../../../model_class/upcoming_shootview_model.dart';

abstract class ShootsRepository {
  /// GET `creator/project-details/$id`. Throws on non-2xx or `error: true`.
  Future<MyData> fetchProjectDetail(int projectId);

  /// POST `creator/accept-project`. Server contract is
  /// `{project_id, crew_accept: 1|2}` (1=accepted, 2=declined). Callers pass
  /// `status` as `accepted`/`declined`; impl maps to `crew_accept`. Optional
  /// `reason`/`comment` carry through for declines.
  Future<void> respondToProject({
    required int projectId,
    required String status,
    String? reason,
    String? comment,
  });

  /// GET `creator/shoots`. Returns shoots list backing the ShootsScreen list view.
  /// Query params: `request_status` (`all` | `pending` | `confirmed`) and
  /// `shoot_status` (`completed` | `cancelled`).
  Future<ShootsData> fetchShoots({
    String requestStatus = 'all',
    String shootStatus = 'completed',
  });

  /// GET `creator/shoot-count`. Returns aggregate counters used by the four
  /// stat cards at the top of ShootsScreen.
  Future<count_model.ShootCountData> fetchShootCount();

  /// GET `creator/shoot-card-details?status=$status`. Returns shoots list
  /// for a selected top count card (pending, confirmed, completed, rejected).
  Future<List<Shoot>> fetchShootCardDetails(String status);
}
