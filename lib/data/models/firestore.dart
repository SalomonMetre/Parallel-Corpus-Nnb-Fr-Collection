import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreInterface {
  Future<void> add(String collectionName, Map<String, dynamic> data);
  Future<void> delete(String collectionName, String id);
  Future<List<Map<String, dynamic>>> getAll(String collectionName);
  Future<Map<String, dynamic>?> getById(String collectionName, String id);
  Future<void> update(String collectionName, String id, Map<String, dynamic> data);
}

// Implement the interface in FirestoreModel
class FirestoreModel implements FirestoreInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> add(String collectionName, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).add(data);
    } catch (e) {
      print("Error adding document: $e");
    }
  }

  @override
  Future<void> delete(String collectionName, String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String collectionName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(collectionName).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include the document ID in the data
        return data;
      }).toList();
    } catch (e) {
      print("Error getting documents: $e");
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> getById(String collectionName, String id) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection(collectionName).doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        data['id'] = documentSnapshot.id; // Include the document ID in the data
        return data;
      } else {
        print("Document does not exist");
        return null;
      }
    } catch (e) {
      print("Error getting document: $e");
      return null;
    }
  }

  @override
  Future<void> update(String collectionName, String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collectionName).doc(id).update(data);
    } catch (e) {
      print("Error updating document: $e");
    }
  }
}
