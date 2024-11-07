import 'package:cathay2024/ticket/enter_manually/enter_manually.dart';
import 'package:cathay2024/ticket/scan/scanner_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'manual_input_page.dart';

class InputTripInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Trip Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              text: TextSpan(
                text: 'To enable trip mode, please provide your ',
                style: TextStyle(fontSize: 18, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text: 'name, ',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(
                    text: 'arrival airport, ',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(
                    text: 'and dates of travel. ',
                    style: TextStyle(color: Colors.blue),
                  ),
                  TextSpan(
                    text: 'This information is necessary to proceed. If you cancel, trip mode will remain disabled.',
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            // asset image
            Image.asset('assets/illustration2.png'),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EnterManuallyPage(
                            departureDate: null,
                            departureAirport: null,
                            arrivalAirport: null,
                            name: null,
                          )),
                );
              },
              icon: Icon(Icons.edit),
              label: Text('Enter Manually'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'or...',
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DemoPage()),
                );
              },
              icon: Icon(Icons.qr_code),
              label: Text('Use your boarding pass!'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
