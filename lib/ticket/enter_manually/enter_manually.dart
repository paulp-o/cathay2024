import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'additional_info_page.dart';
import 'find_airport.dart';

class EnterManuallyPage extends StatefulWidget {
  const EnterManuallyPage(
      {super.key,
      required this.departureDate,
      required this.departureAirport,
      required this.arrivalAirport,
      required this.name});

  final DateTime? departureDate;
  final String? departureAirport;
  final String? arrivalAirport;
  final String? name;

  @override
  State<EnterManuallyPage> createState() => _EnterManuallyPageState();
}

class _EnterManuallyPageState extends State<EnterManuallyPage> {
  // create textcontroller for each textfield
  TextEditingController departureAirportController = TextEditingController();
  TextEditingController arrivalAirportController = TextEditingController();
  TextEditingController flightDateController = TextEditingController();
  TextEditingController passengerNameController = TextEditingController();
  TextEditingController flightNumberController = TextEditingController();
  TextEditingController seatNumberController = TextEditingController();
  TextEditingController boardingSequenceController = TextEditingController();
  DateTime? departureDate;
  String? departureAirport;
  String? arrivalAirport;
  DateTime? endingDate;
  String? name;

  @override
  void initState() {
    super.initState();
    // if there is a value passed from previous page, set the textfield to the value
    if (widget.departureDate != null) {
      departureDate = widget.departureDate;
      flightDateController.text = widget.departureDate.toString().substring(0, 10);
    }
    if (widget.departureAirport != null) {
      departureAirport = widget.departureAirport;
      departureAirportController.text = widget.departureAirport!;
    }
    if (widget.arrivalAirport != null) {
      arrivalAirport = widget.arrivalAirport;
      arrivalAirportController.text = widget.arrivalAirport!;
    }
    if (widget.name != null) {
      name = widget.name;
      passengerNameController.text = widget.name!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // use textfields
          children: [
            Text(
              "Let's begin",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Please enter the below information.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 100),
            const Text("Passenger Name"),
            const SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                name = value;
              },
              controller: passengerNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Required',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Departure Airport"),
                      const SizedBox(height: 10),
                      TextField(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FindAirportPage()))
                              .then((value) {
                            departureAirport = value;
                            setState(() {
                              departureAirportController.text = value;
                            });
                          });
                        },
                        readOnly: true,
                        controller: departureAirportController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Required',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Arrival Airport"),
                      const SizedBox(height: 10),
                      TextField(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const FindAirportPage()))
                              .then((value) {
                            arrivalAirport = value;
                            setState(() {
                              arrivalAirportController.text = value;
                            });
                          });
                        },
                        readOnly: true,
                        controller: arrivalAirportController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Required',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Departure Date"),
                const SizedBox(height: 10),
                TextField(
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2015),
                      lastDate: DateTime(2050),
                    ).then((value) {
                      if (value != null) {
                        departureDate = value;
                        setState(() {
                          flightDateController.text = value.toString().substring(0, 10);
                        });
                      }
                    });
                  },
                  readOnly: true,
                  controller: flightDateController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Required',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (departureAirportController.text.isEmpty ||
                    arrivalAirportController.text.isEmpty ||
                    flightDateController.text.isEmpty ||
                    passengerNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill in all required fields.',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      padding: const EdgeInsets.all(22),
                      elevation: 0,
                    ),
                  );
                } else {
                  //printall the values formatted
                  print(
                      'Departure Airport: $departureAirport \nArrival Airport: $arrivalAirport\nDeparture Date: $departureDate \nName: $name');
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdditionalInfoPage(
                                departureDate: departureDate!,
                                departureAirport: departureAirport!,
                                arrivalAirport: arrivalAirport!,
                                name: name!,
                              )));
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: const Text('Next'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
