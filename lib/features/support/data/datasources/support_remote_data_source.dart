import 'package:wafra_frontend/core/network/api_service.dart';
import '../../domain/entities/support_ticket.dart';

class SupportRemoteDataSource {
  final ApiService _api;
  SupportRemoteDataSource(this._api);

  Future<void> submitTicket({
    required String subject,
    required String message,
  }) =>
      _api.submitSupportTicket(subject: subject, message: message);

  Future<List<SupportTicket>> getTickets() async {
    final raw = await _api.getAdminSupportTickets();
    return raw
        .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> resolveTicket(int ticketId) =>
      _api.resolveAdminSupportTicket(ticketId);
}
