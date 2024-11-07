import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'result_page.dart';

class AdditionalInfoPage extends StatefulWidget {
  final DateTime departureDate;
  final String departureAirport;
  final String arrivalAirport;
  final String name;

  const AdditionalInfoPage({
    Key? key,
    required this.departureDate,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.name,
  }) : super(key: key);

  @override
  _AdditionalInfoPageState createState() => _AdditionalInfoPageState();
}

class _AdditionalInfoPageState extends State<AdditionalInfoPage> {
  final TextEditingController _lastDateController = TextEditingController();
  DateTime? _selectedLastDate;

  @override
  void dispose() {
    _lastDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller, DateTime? selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        _selectedLastDate = picked;
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _saveTripInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', widget.name);
    await prefs.setString('departureAirport', widget.departureAirport);
    await prefs.setString('arrivalAirport', widget.arrivalAirport);
    await prefs.setString('departureDate', widget.departureDate.toIso8601String());
    await prefs.setString('lastDate', _selectedLastDate!.toIso8601String());
    await prefs.setBool('tripModeEnabled', true);
  }

  void _submit() async {
    if (_selectedLastDate != null) {
      await _saveTripInfo();
      Get.off(() => ResultPage());
    } else {
      Get.snackbar('Error', 'Please fill in all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Additional Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // big text about hello name
            RichText(
              text: TextSpan(
                text: 'Hello, ${widget.name}!\n',
                style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                    text: 'To enable trip mode, please provide your planned last date of travel.',
                    style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _lastDateController,
              decoration: InputDecoration(
                labelText: 'Last Date of Travel',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () {
                _selectDate(context, _lastDateController, _selectedLastDate);
              },
              readOnly: true,
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: Icon(Icons.check),
              label: Text('Submit'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Get.back(result: {'enabled': false});
              },
              icon: Icon(Icons.cancel),
              label: Text('Cancel'),
              style: TextButton.styleFrom(
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
