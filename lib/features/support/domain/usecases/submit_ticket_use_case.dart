import '../repositories/support_repository.dart';

class SubmitTicketUseCase {
  final SupportRepository _repository;
  SubmitTicketUseCase(this._repository);

  Future<void> call({required String subject, required String message}) =>
      _repository.submitTicket(subject: subject, message: message);
}
