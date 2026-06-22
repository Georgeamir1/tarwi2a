class DeviceTokenDTO {
  final String id;
  final String userId;
  final String token;
  final String platform;
  final DateTime createdAt;

  const DeviceTokenDTO({
    required this.id,
    required this.userId,
    required this.token,
    required this.platform,
    required this.createdAt,
  });

  factory DeviceTokenDTO.fromJson(Map<String, dynamic> json) {
    return DeviceTokenDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      token: json['token'] as String,
      platform: json['platform'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'user_id': userId,
        'token': token,
        'platform': platform,
      };
}
