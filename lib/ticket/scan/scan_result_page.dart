import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import '../../logic/pdf417parser.dart';
import '../enter_manually/enter_manually.dart';

class ScanResultPage extends StatefulWidget {
  const ScanResultPage({super.key, required this.result, required this.code});

  final String result;
  final Code code;

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  late Encode encodedResult;
  Map<String, String> parsedData = {
    'Passenger Name': '',
    'Flight No': '',
    'Seat No.': '',
    'Boarding Sequence': '',
    'Departure': '',
    'Arrival': '',
    'Date': '',
  };
  Widget? barcode;

  @override
  void initState() {
    // store as dictionary using pdf417parser.dart
    final parser = PDF417Parser(widget.result);

    // add a certain day from this year's january 1st, and return it as form of 'MM-DD'
    String addDays(int days) {
      final DateTime date = DateTime(DateTime.now().year, 1, 1);
      final DateTime newDate = date.add(Duration(days: days - 1));
      return '${newDate.month}/${newDate.day}';
    }

    parsedData['Passenger Name'] = parser.getName();
    parsedData['Departure'] = parser.getDepartureAirport();
    parsedData['Date'] = addDays(int.parse(parser.getDepartureDateByDaysSinceJanFirst()));
    parsedData['Arrival'] = parser.getArrivalAirport();
    parsedData['Flight No'] = parser.getFlightNumber();
    parsedData['Seat No.'] = parser.getSeatNumber();
    parsedData['Boarding Sequence'] = parser.getBoardingSequenceNumber();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // prevent user from going back to scanner page by swiping
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan Result'),
          leading: TextButton(
            child: const Icon(Icons.arrow_back),
            onPressed: () {
              // go to myhomepage
              Navigator.popUntil(context, ModalRoute.withName('/home_page'));
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              // show raw data
              Text(widget.result, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(height: 32),
              const Text('Extracted Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3),
                itemCount: 7,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(parsedData.keys.elementAt(index), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(parsedData.values.elementAt(index)),
                      ],
                    ),
                  );
                },
              ),
              ElevatedButton(
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Continue!'),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  width: double.infinity,
                ),
                // send to enter manually with parsed data
                onPressed: () {
                  String year = '2023';
                  final DateTime date = DateTime(int.parse(year), 1, 1);
                  print(parsedData['Passenger Name']);
                  Navigator.push(
                      // go to enter manually page
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnterManuallyPage(
                          departureAirport: parsedData['Departure'],
                          arrivalAirport: parsedData['Arrival'],
                          // parsedData['Date'] is in a form of '8/26'
                          departureDate: DateTime(date.year, int.parse(parsedData['Date']!.split('/')[0]),
                              int.parse(parsedData['Date']!.split('/')[1])),
                          name: parsedData['Passenger Name'],
                        ),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
