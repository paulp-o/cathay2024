// import 'package:flutter/material.dart';

// import '../../../../logic/pdf417parser.dart';
// import '../../../../model/boarding_pass.dart';
// import '../../../../widgets/boarding_pass_widget.dart';
// import '../../create_album/create_photobook_steps.dart';

// class BoardingPassInfoPage extends StatefulWidget {
//   const BoardingPassInfoPage({super.key, required this.boardingPass, required this.boardingPassWidget});

//   final BoardingPass boardingPass;
//   final BoardingPassWidget boardingPassWidget;

//   @override
//   State<BoardingPassInfoPage> createState() => _BoardingPassInfoPageState();
// }

// class _BoardingPassInfoPageState extends State<BoardingPassInfoPage> {
//   late Map<String, dynamic> boardingPassJson;
//   late bool isManuallyEnteredBoardingPass;
//   late String _rawData;

//   Map<String, dynamic> parsedData = {};

//   @override
//   void initState() {
//     super.initState();
//     // store as dictionary using pdf417parser.dart
//     boardingPassJson = widget.boardingPass.toJson();
//     isManuallyEnteredBoardingPass = boardingPassJson['isManuallyEnteredBoardingPass'];
//     _rawData = boardingPassJson['rawData'];
//     // parse raw Data and convert to map
//     final parser = PDF417Parser(_rawData);

//     // add a certain day from this year's january 1st, and return it as form of 'MM-DD'
//     String addDays(int days) {
//       final DateTime date = DateTime(DateTime.now().year, 1, 1);
//       final DateTime newDate = date.add(Duration(days: days - 1));
//       return '${newDate.month}/${newDate.day}';
//     }

//     parsedData['Passenger Name'] = parser.getName();
//     parsedData['Departure'] = parser.getDepartureAirport();
//     parsedData['Date'] = addDays(int.parse(parser.getDepartureDateByDaysSinceJanFirst()));
//     parsedData['Arrival'] = parser.getArrivalAirport();
//     parsedData['Flight No'] = parser.getFlightNumber();
//     parsedData['Seat No.'] = parser.getSeatNumber();
//     parsedData['Boarding Sequence'] = parser.getBoardingSequenceNumber();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Travel Information'),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         body: ListView(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Hero(
//                     tag: 'boardingpass',
//                     transitionOnUserGestures: true,
//                     child: widget.boardingPassWidget,
//                   ),
//                 ],
//               ),
//             ),
//             // show info
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3),
//                 itemCount: 7,
//                 itemBuilder: (BuildContext context, int index) {
//                   print(parsedData.keys);
//                   return Container(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(parsedData.keys.elementAt(index), style: const TextStyle(fontWeight: FontWeight.bold)),
//                         Text(parsedData.values.elementAt(index)),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: BottomAppBar(
//           color: Colors.transparent,
//           surfaceTintColor: Colors.transparent,
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: OutlinedButton(
//                 onPressed: () {
//                   Navigator.push(
//                       context, MaterialPageRoute(builder: (context) => CreatePhotobookPage(boardingPass: widget.boardingPass)));
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: const Text('Create Photo Album!'),
//                 ),
//               ),
//             ),
//           ),
//         ));
//   }
// }
