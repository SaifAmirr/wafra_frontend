class SupportTicket {
  final int id;
  final int userId;
  final String username;
  final String email;
  final String subject;
  final String message;
  final String status;
  final DateTime createdAt;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
        id: json['id'] as int,
        userId: json['user_id'] as int? ?? 0,
        username: json['username'] as String? ?? '—',
        email: json['email'] as String? ?? '—',
        subject: json['subject'] as String? ?? '',
        message: json['message'] as String? ?? '',
        status: json['status'] as String? ?? 'open',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  bool get isOpen => status == 'open';
}
