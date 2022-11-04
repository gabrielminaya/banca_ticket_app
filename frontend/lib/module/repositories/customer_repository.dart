import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/http_client.dart';
import '../entities/customer_entity.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.read(httpClientProvider));
});

class CustomerRepository {
  final http.Client _client;

  const CustomerRepository(this._client);

  String get host => "172.16.220.50";
  String get port => "3001";

  Future<List<CustomerEntity>> getAllCustomers() async {
    try {
      final response = await _client.get(
        Uri.parse("http://$host:$port/users"),
        headers: {"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/json', 'Accept': '*/*'},
      );

      final result = jsonDecode(response.body)["result"];
      final customers = <CustomerEntity>[];

      for (var element in result) {
        customers.add(CustomerEntity.fromMap(element));
      }

      return customers;
    } catch (e) {
      log(e.toString());
      return [];
    }
  }

  Future<bool> updateComment({
    required String id,
    required String name,
    required String contactOne,
    required String contactTwo,
  }) async {
    try {
      await _client.post(
        Uri.parse("http://$host:$port/updateCommentary"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "id": id,
          "name": name,
          "contactOne": contactOne.replaceAllMapped(
            RegExp(r'(\d{3})(\d{3})(\d+)'),
            (Match m) => "(${m[1]}) ${m[2]}-${m[3]}",
          ),
          "contactTwo": contactTwo.replaceAllMapped(
            RegExp(r'(\d{3})(\d{3})(\d+)'),
            (Match m) => "(${m[1]}) ${m[2]}-${m[3]}",
          ),
        }),
      );

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> updateByCSV(List<List<dynamic>> files) async {
    try {
      for (final element in files) {
        await _client.post(
          Uri.parse("http://$host:$port/updateLastname"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({"id": element[0], "newLastname": element[1]}),
        );
      }

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  Future<bool> updateEmail({
    required String oldEmail,
    required String newEmail,
  }) async {
    try {
      await _client.post(
        Uri.parse("http://$host:$port/updateMails"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"oldEmail": oldEmail, "newEmail": newEmail}),
      );

      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }
}
