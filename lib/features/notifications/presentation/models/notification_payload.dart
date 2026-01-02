class NotificationPayload {
  final String type;
  final String? entityId;
  final String? route;
  final String? imageUrl;
  final String title;
  final String body;

  NotificationPayload({
    required this.type,
    this.entityId,
    this.route,
    this.imageUrl,
    required this.title,
    required this.body,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      type: map['type'] as String,
      entityId: map['entityId'] as String?,
      route: map['route'] as String?,
      imageUrl: map['image'] as String?,
      title: map['title'] as String,
      body: map['body'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (entityId != null) 'entityId': entityId,
      if (route != null) 'route': route,
      if (imageUrl != null) 'image': imageUrl,
      'title': title,
      'body': body,
    };
  }
}
