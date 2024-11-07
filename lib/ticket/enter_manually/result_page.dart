import 'package:cathay2024/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              text: TextSpan(
                text: 'Congratulations,\n trip mode is enabled!\n\n',
                style: TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              textAlign: TextAlign.center,
            ),
            Image.asset('assets/illustration1.png'),
            SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'Enjoy useful trip information including our featured restaurants all over the world!',
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Flush all past pages and send the user to the main homepage
                Get.offAll(() => const MyHomePage(title: ''));
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
