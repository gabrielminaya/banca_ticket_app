import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:frontend/core/context_ext.dart';
import 'package:frontend/module/controllers/customer_controller.dart';
import 'package:frontend/module/entities/customer_entity.dart';
import 'package:frontend/module/repositories/customer_repository.dart';

final fileNameProvider = StateProvider<String>((_) {
  return "Cargar CSV";
});

final fileProvider = StateProvider<List<List<dynamic>>?>((_) {
  return null;
});

final idCustomerForSearchProvider = StateProvider<String>((_) {
  return "";
});

final customersFilteredProvider = StateProvider.family<List<CustomerEntity>, List<CustomerEntity>>((ref, value) {
  final idCustomerForSearch = ref.watch(idCustomerForSearchProvider);

  if (idCustomerForSearch.isEmpty) {
    return value;
  }

  return value.where((element) => element.id.contains(idCustomerForSearch)).toList();
});

class HomeView extends ConsumerWidget {
  HomeView({super.key});

  final formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerControllerAsync = ref.watch(customerControllerProvider);
    final screenSize = MediaQuery.of(context).size;

    void refresh() {
      ref.invalidate(customerControllerProvider);
    }

    void updateCSV() async {
      final screenSize = MediaQuery.of(context).size;

      void importCSV() async {
        //Pick file
        FilePickerResult? csvFile = await FilePicker.platform
            .pickFiles(allowedExtensions: ['csv'], type: FileType.custom, allowMultiple: false);
        if (csvFile != null) {
          //decode bytes back to utf8
          final bytes = utf8.decode(csvFile.files[0].bytes!.toList());
          //from the csv plugin
          List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(bytes);
          ref.read(fileNameProvider.notifier).update((_) => csvFile.files.first.name);
          ref.read(fileProvider.notifier).update((_) => rowsAsListOfValues);
        }
      }

      context.showModal(SizedBox(
        width: screenSize.width / 2,
        child: FormBuilder(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Divider(),
              const Center(
                child: Text("Actualizar por CSV", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              const SizedBox(height: 20),
              Consumer(builder: (context, ref, widget) {
                return ElevatedButton(onPressed: importCSV, child: Text(ref.watch(fileNameProvider)));
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: screenSize.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: const Text("Actualizar"),
                  onPressed: () async {
                    final files = ref.watch(fileProvider);

                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      if (files != null) {
                        Navigator.of(context).pop();
                        ref.read(customerRepositoryProvider).updateByCSV(files).then((value) {
                          if (value) {
                            refresh();

                            ref.invalidate(fileNameProvider);
                            ref.invalidate(fileProvider);
                          }
                        });
                      }
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenSize.width,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.invalidate(fileNameProvider);
                    ref.invalidate(fileProvider);
                  },
                  child: const Text("Cerrar"),
                ),
              )
            ],
          ),
        ),
      ));
    }

    void updateEmail() async {
      final screenSize = MediaQuery.of(context).size;

      context.showModal(SizedBox(
        width: screenSize.width / 2,
        child: FormBuilder(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Divider(),
              const Center(
                child: Text("Actualizar Correo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'oldEmail',
                decoration: const InputDecoration(label: Text("Correo a Actualizar")),
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 20),
              FormBuilderTextField(
                name: 'newEmail',
                decoration: const InputDecoration(label: Text("Nuevo Correo")),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: screenSize.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                  child: const Text("Actualizar"),
                  onPressed: () async {
                    if (formKey.currentState?.saveAndValidate() ?? false) {
                      final oldEmail = formKey.currentState?.value['oldEmail'] ?? '';
                      final newEmail = formKey.currentState?.value['newEmail'] ?? '';

                      ref
                          .read(customerRepositoryProvider)
                          .updateEmail(oldEmail: oldEmail, newEmail: newEmail)
                          .then((value) {
                        if (value) {
                          Navigator.of(context).pop();

                          refresh();
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenSize.width,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cerrar"),
                ),
              )
            ],
          ),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(5),
          child: TextFormField(
            decoration: const InputDecoration(label: Text("Busqueda por ID")),
            onChanged: (value) => ref.read(idCustomerForSearchProvider.notifier).update((_) => value),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: updateCSV, child: const Text("Subir CSV")),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: updateEmail, child: const Text("Actualizar Correo")),
          ),
        ],
      ),
      body: customerControllerAsync.when(
        data: (customers) {
          final customersFiltered = ref.watch(customersFilteredProvider(customers));

          return SizedBox(
            height: screenSize.height,
            width: screenSize.width,
            child: SelectionArea(
              child: PaginatedDataTable(
                columns: const [
                  DataColumn(label: Text("ID")),
                  DataColumn(label: Text("Titulo")),
                  DataColumn(label: Text("Correo")),
                  DataColumn(label: Text("Apellido")),
                  DataColumn(label: Text("Comentario")),
                  DataColumn(label: Text("Acciones")),
                ],
                source: CustomerDataSource(
                  customers: customersFiltered,
                  context: context,
                  ref: ref,
                  refresh: refresh,
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(child: Text(error.toString()));
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class CustomerDataSource extends DataTableSource {
  final List<CustomerEntity> customers;
  final BuildContext context;
  final WidgetRef ref;
  final VoidCallback refresh;

  CustomerDataSource({
    required this.customers,
    required this.context,
    required this.ref,
    required this.refresh,
  });

  final formKey = GlobalKey<FormBuilderState>();

  void updateComment(String id) async {
    final screenSize = MediaQuery.of(context).size;

    context.showModal(SizedBox(
      width: screenSize.width / 2,
      child: FormBuilder(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Divider(),
            const Center(
              child: Text("Actualizar Comentario", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'id',
              readOnly: true,
              initialValue: id,
              decoration: const InputDecoration(label: Text("ID")),
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(label: Text("Nombre Contacto")),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'contactOne',
              decoration: const InputDecoration(label: Text("Contacto 1")),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'contactTwo',
              decoration: const InputDecoration(label: Text("Contacto 2")),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenSize.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                child: const Text("Actualizar"),
                onPressed: () async {
                  if (formKey.currentState?.saveAndValidate() ?? false) {
                    final name = formKey.currentState?.value['name'] ?? '';
                    final contactOne = formKey.currentState?.value['contactOne'] ?? '';
                    final contactTwo = formKey.currentState?.value['contactTwo'] ?? '';

                    ref
                        .read(customerRepositoryProvider)
                        .updateComment(id: id, name: name, contactOne: contactOne, contactTwo: contactTwo)
                        .then((value) {
                      if (value) {
                        Navigator.of(context).pop();

                        refresh();
                      }
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: screenSize.width,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cerrar"),
              ),
            )
          ],
        ),
      ),
    ));
  }

  @override
  DataRow? getRow(int index) {
    final customer = customers.elementAt(index);

    return DataRow(cells: [
      DataCell(Text(customer.id)),
      DataCell(Text(customer.title)),
      DataCell(Text(customer.email)),
      DataCell(Text(customer.lastname)),
      DataCell(Text(customer.comment)),
      DataCell(IconButton(onPressed: () => updateComment(customer.id), icon: const Icon(Icons.comment))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => customers.length;

  @override
  int get selectedRowCount => 0;
}
