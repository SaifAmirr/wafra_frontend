import '../../domain/entities/support_ticket.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  final SupportRemoteDataSource _dataSource;
  SupportRepositoryImpl(this._dataSource);

  @override
  Future<void> submitTicket({
    required String subject,
    required String message,
  }) =>
      _dataSource.submitTicket(subject: subject, message: message);

  @override
  Future<List<SupportTicket>> getTickets() => _dataSource.getTickets();

  @override
  Future<void> resolveTicket(int ticketId) =>
      _dataSource.resolveTicket(ticketId);
}
