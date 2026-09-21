import '../models/fm_share.dart';

abstract class SharesRepository {
  Future<List<FmShareRecipient>> list(FmShareTarget target);
  Future<FmShareRecipient> create(
    FmShareTarget target, {
    String? email,
    required FmSharePermission permission,
    String message = '',
  });
  Future<void> revoke(int shareId);
  Future<List<FmShareAccessLog>> accessLogs(FmShareTarget target);
}
