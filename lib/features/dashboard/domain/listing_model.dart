enum ListingStatus { active, pending }

class RestaurantListing {
  final String name;
  final int quantity;
  final ListingStatus status;
  final String timeDetail;
  final String listedAgo;
  final int reservationCount;

  const RestaurantListing({
    required this.name,
    required this.quantity,
    required this.status,
    required this.timeDetail,
    required this.listedAgo,
    this.reservationCount = 0,
  });
}

RestaurantListing restaurantListingFromJson(Map<String, dynamic> j) {
  final status = (j['status'] as String?) == 'available'
      ? ListingStatus.active
      : ListingStatus.pending;

  String timeDetail = '';
  final rawTime = j['pickup_time'] as String?;
  if (rawTime != null) {
    try {
      final dt = DateTime.parse(rawTime);
      final diff = dt.difference(DateTime.now());
      if (status == ListingStatus.active) {
        timeDetail = diff.isNegative
            ? 'Pickup time passed'
            : 'Expires in ${diff.inHours}h ${diff.inMinutes % 60}m';
      } else {
        timeDetail = 'Driver arriving soon';
      }
    } catch (_) {}
  }

  String listedAgo = '';
  final rawCreated = j['created_at'] as String?;
  if (rawCreated != null) {
    try {
      final created = DateTime.parse(rawCreated);
      final diff = DateTime.now().difference(created);
      if (diff.inMinutes < 60) {
        listedAgo = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        listedAgo = '${diff.inHours}h ago';
      } else {
        listedAgo = '${diff.inDays}d ago';
      }
    } catch (_) {}
  }

  return RestaurantListing(
    name: j['food_name'] as String? ?? '',
    quantity: j['quantity'] as int? ?? 0,
    status: status,
    timeDetail: timeDetail,
    listedAgo: listedAgo,
    reservationCount: j['reservation_count'] as int? ?? 0,
  );
}
