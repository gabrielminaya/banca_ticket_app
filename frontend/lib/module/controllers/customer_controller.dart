import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/module/entities/customer_entity.dart';
import 'package:frontend/module/repositories/customer_repository.dart';

final customerControllerProvider = FutureProvider<List<CustomerEntity>>((ref) async {
  return await ref.read(customerRepositoryProvider).getAllCustomers();
});
