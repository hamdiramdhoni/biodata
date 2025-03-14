import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BiodataService.dart';

class MyHomepage extends StatefulWidget {
  const MyHomepage({super.key});

  @override
  State<MyHomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<MyHomepage> {
  //panggil model
  BiodataService? service;
  String? selectedDocId;
  //jalankan saat screen show
  @override
  void initState() {
    //inisialisasi an instance of cloud firestore
    service = BiodataService(FirebaseFirestore.instance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final addressController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(hintText: 'age'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(hintText: 'address'),
              ),
              Expanded(
                child: StreamBuilder(
                  //call `biodata` which return a stream
                  stream: service?.getBiodata(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.connectionState == ConnectionState.none) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("error fecthing data: ${snapshot.data}");
                    } else if (snapshot.hasData &&
                        snapshot.data?.docs.isEmpty == true) {
                      return const Center(child: Text('Empty documents'));
                    }
                    // `data?doct` return a [list<QueryDocumentSnapshot>]
                    final documents = snapshot.data?.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: documents?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          // since it return a map<string,dynamic> we access data by `key`
                          title: Text(documents?[index]['name']),
                          subtitle: Text(documents?[index]['age']),
                          onTap: () {
                            // populate the text filds with the selected document's data
                            nameController.text = documents?[index]['name'];
                            ageController.text = documents?[index]['age'];
                            addressController.text =
                                documents?[index]['address'];
                            selectedDocId = documents?[index].id;
                          },
                          trailing: IconButton(
                            onPressed: () {
                              if (documents?[index].id != null) {
                                service?.delete(documents![index].id);
                              }
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // get name,age and address dari controller
          final name = nameController.text.trim();
          final age = ageController.text.trim();
          final address = addressController.text.trim();
          // panggil Biodataservice function add untuk buat record baru pada firebase
          //service?.add({'name': name, 'age': age, 'address': address});
          if (selectedDocId != null) {
            service?.update(selectedDocId!, {
              'name': name,
              'age': age,
              'address': address,
            });
          } else {
            service?.add({'name': name, 'age': age, 'address': address});
          }
          nameController.clear();
          ageController.clear();
          addressController.clear();
        },
      ),
    );
  }
}
