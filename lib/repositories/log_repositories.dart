import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {

  Future<void> fetchAllDocuments() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('deviceData')
          .get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        print("Document ID: ${doc.id}, Data: ${doc.data()}");
      }
    } catch (e) {
      print("Error fetching documents: $e");
    }
  }

}