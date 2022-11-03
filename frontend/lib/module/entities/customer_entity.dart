import 'package:flutter/foundation.dart';

@immutable
class CustomerEntity {
  final String id;
  final String title;
  final String email;
  final String lastname;
  final String comment;

  const CustomerEntity({
    required this.id,
    required this.title,
    required this.email,
    required this.lastname,
    required this.comment,
  });

  factory CustomerEntity.fromMap(Map<String, dynamic> map) {
    return CustomerEntity(
      id: map['login'] ?? '',
      title: map['title'] ?? '',
      email: map['email'] ?? '',
      lastname: map['last_name'] ?? '',
      comment: map['comments'] ?? '',
    );
  }
}
