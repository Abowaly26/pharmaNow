class UserNotificationSettings {
  final bool systemNotifications;
  final bool offers;
  final bool orders;

  UserNotificationSettings({
    this.systemNotifications = true,
    this.offers = true,
    this.orders = true,
  });

  factory UserNotificationSettings.fromMap(Map<String, dynamic> map) {
    return UserNotificationSettings(
      systemNotifications: map['systemNotifications'] ?? true,
      offers: map['offers'] ?? true,
      orders: map['orders'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'systemNotifications': systemNotifications,
      'offers': offers,
      'orders': orders,
    };
  }
}
