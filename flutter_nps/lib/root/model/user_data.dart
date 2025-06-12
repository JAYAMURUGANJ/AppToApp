class UserData {
  final String? userName;
  final String? userId;
  final String? email;
  final int? timestamp;
  final bool? isActive;
  final String? deviceInfo;
  final Map<String, dynamic>? additionalData;

  UserData({
    this.userName,
    this.userId,
    this.email,
    this.timestamp,
    this.isActive,
    this.deviceInfo,
    this.additionalData,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    // Extract known fields
    final knownFields = {
      'userName',
      'userId',
      'email',
      'timestamp',
      'isActive',
      'deviceInfo'
    };

    // Separate additional data
    final additionalData = <String, dynamic>{};
    map.forEach((key, value) {
      if (!knownFields.contains(key)) {
        additionalData[key] = value;
      }
    });

    return UserData(
      userName: map['userName']?.toString(),
      userId: map['userId']?.toString(),
      email: map['email']?.toString(),
      timestamp: _parseTimestamp(map['timestamp']),
      isActive: _parseBool(map['isActive']),
      deviceInfo: map['deviceInfo']?.toString(),
      additionalData: additionalData.isNotEmpty ? additionalData : null,
    );
  }

  static int? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) return value != 0;
    return null;
  }

  DateTime? get timestampAsDateTime {
    if (timestamp == null) return null;
    try {
      return DateTime.fromMillisecondsSinceEpoch(timestamp!);
    } catch (e) {
      return null;
    }
  }

  String get displayName => userName ?? 'Unknown User';
  String get displayId => userId ?? 'Unknown ID';

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      if (userName != null) 'userName': userName,
      if (userId != null) 'userId': userId,
      if (email != null) 'email': email,
      if (timestamp != null) 'timestamp': timestamp,
      if (isActive != null) 'isActive': isActive,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };

    if (additionalData != null) {
      map.addAll(additionalData!);
    }

    return map;
  }

  @override
  String toString() {
    return 'UserData(userName: $userName, userId: $userId, email: $email, timestamp: $timestamp, isActive: $isActive, deviceInfo: $deviceInfo, additionalData: $additionalData)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserData &&
        other.userName == userName &&
        other.userId == userId &&
        other.email == email &&
        other.timestamp == timestamp &&
        other.isActive == isActive &&
        other.deviceInfo == deviceInfo &&
        _mapsEqual(other.additionalData, additionalData);
  }

  bool _mapsEqual(Map<String, dynamic>? map1, Map<String, dynamic>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;

    for (String key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      if (map1[key] != map2[key]) return false;
    }

    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
      userName,
      userId,
      email,
      timestamp,
      isActive,
      deviceInfo,
      additionalData,
    );
  }
}
