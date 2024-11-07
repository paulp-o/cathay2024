// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ManualInputPage extends StatefulWidget {
//   @override
//   _ManualInputPageState createState() => _ManualInputPageState();
// }

// class _ManualInputPageState extends State<ManualInputPage> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _airportController = TextEditingController();
//   final TextEditingController _arrivalDateController = TextEditingController();
//   final TextEditingController _lastDateController = TextEditingController();
//   DateTime? _selectedArrivalDate;
//   DateTime? _selectedLastDate;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _airportController.dispose();
//     _arrivalDateController.dispose();
//     _lastDateController.dispose();
//     super.dispose();
//   }

//   Future<void> _selectDate(BuildContext context, TextEditingController controller, DateTime? selectedDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//         controller.text = "${picked.toLocal()}".split(' ')[0];
//       });
//     }
//   }

//   void _submit() {
//     if (_nameController.text.isNotEmpty &&
//         _airportController.text.isNotEmpty &&
//         _selectedArrivalDate != null &&
//         _selectedLastDate != null) {
//       Get.back(result: {'enabled': true});
//     } else {
//       // Show error message
//       Get.snackbar('Error', 'Please fill in all fields');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Manual Trip Information'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Your Name',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.person),
//               ),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _airportController,
//               decoration: InputDecoration(
//                 labelText: 'Arrival Airport',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.flight_land),
//               ),
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _arrivalDateController,
//               decoration: InputDecoration(
//                 labelText: 'Arrival Date',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.calendar_today),
//               ),
//               onTap: () {
//                 _selectDate(context, _arrivalDateController, _selectedArrivalDate);
//               },
//               readOnly: true,
//             ),
//             SizedBox(height: 20),
//             TextField(
//               controller: _lastDateController,
//               decoration: InputDecoration(
//                 labelText: 'Last Date of Travel',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.calendar_today),
//               ),
//               onTap: () {
//                 _selectDate(context, _lastDateController, _selectedLastDate);
//               },
//               readOnly: true,
//             ),
//             SizedBox(height: 30),
//             ElevatedButton.icon(
//               onPressed: _submit,
//               icon: Icon(Icons.check),
//               label: Text('Submit'),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextButton.icon(
//               onPressed: () {
//                 Get.back(result: {'enabled': false});
//               },
//               icon: Icon(Icons.cancel),
//               label: Text('Cancel'),
//               style: TextButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 textStyle: TextStyle(fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
