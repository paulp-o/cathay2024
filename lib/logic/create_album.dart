// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// Future<void> createAlbum({
//   required String albumName,
//   required String departureAirport,
//   required String arrivalAirport,
//   required DateTime departureDate,
//   required DateTime endingDate,
// }) async {
//   final String uid = FirebaseAuth.instance.currentUser!.uid;

//   // Map for the album data
//   Map<String, dynamic> albumData = {
//     'departureAirport': departureAirport,
//     'arrivalAirport': arrivalAirport,
//     'albumName': albumName,
//     'departureDate': departureDate,
//     'endingDate': endingDate,
//     'createdDate': DateTime.now(),
//     'shared': false,
//   };

//   // Storing the album in Firestore
//   await FirebaseFirestore.instance.collection('users').doc(uid).collection('albums').doc(albumName).set(albumData);
// }
