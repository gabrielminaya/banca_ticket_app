class ProfileEntity {
  final String roleId;

  ProfileEntity({
    required this.roleId,
  });

  factory ProfileEntity.fromMap(Map<String, dynamic> map) {
    return ProfileEntity(
      roleId: map['role_id'] ?? "none",
    );
  }

  bool get canDoActions => roleId.contains("call service") || roleId.contains("admin");
  bool get canContactUpdate => roleId.contains("supervisores");
}
