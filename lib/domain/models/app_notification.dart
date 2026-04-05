class AppNotification {
  final int? id;
  final String title;
  final String description;
  final String type; // 'transaction', 'security', 'reminder', 'system'
  final bool isUnread;
  final DateTime createdAt;

  AppNotification({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isUnread = true,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      isUnread: map['isUnread'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'isUnread': isUnread ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    bool? isUnread,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
