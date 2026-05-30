import '../entities/support_ticket.dart';

abstract class SupportRepository {
  Future<void> submitTicket({
    required String subject,
    required String message,
  });

  Future<List<SupportTicket>> getTickets();

  Future<void> resolveTicket(int ticketId);
}
