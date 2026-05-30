import 'package:wafra_frontend/core/network/api_service.dart';
import 'package:wafra_frontend/features/support/domain/entities/support_ticket.dart';

class AdminRepository {
  AdminRepository._();
  static final instance = AdminRepository._();

  Future<Map<String, dynamic>> getStats() =>
      ApiService.instance.getAdminStats();

  Future<List<dynamic>> getUsers() => ApiService.instance.getAdminUsers();

  Future<void> approveUser(int userId) =>
      ApiService.instance.adminApproveUser(userId);

  Future<void> rejectUser(int userId) =>
      ApiService.instance.adminRejectUser(userId);

  Future<List<dynamic>> getListings() => ApiService.instance.getAdminListings();

  Future<void> deleteListing(int listingId) =>
      ApiService.instance.adminDeleteListing(listingId);

  Future<void> logout() => ApiService.instance.logout();

  Future<List<dynamic>> getReservations() =>
      ApiService.instance.getRestaurantReservations();

  Future<void> acceptReservation(int id) =>
      ApiService.instance.acceptReservation(id);

  Future<void> declineReservation(int id) =>
      ApiService.instance.declineReservation(id);

  Future<List<SupportTicket>> getSupportTickets() async {
    final raw = await ApiService.instance.getAdminSupportTickets();
    return raw
        .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> resolveTicket(int ticketId) =>
      ApiService.instance.resolveAdminSupportTicket(ticketId);
}
