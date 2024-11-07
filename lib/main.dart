import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'pages/home/home_page.dart';
import 'utils/file_downloader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'File Downloader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 92, 99, 1)),
        primaryColor: Color.fromRGBO(0, 92, 99, 1),
        primaryColorDark: Color.fromRGBO(0, 56, 64, 1),
        primaryColorLight: Color.fromRGBO(76, 138, 143, 1),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(0, 92, 99, 1), // Primary color for buttons
          textTheme: ButtonTextTheme.primary,
        ),
        useMaterial3: true,
        // disable splash effect
        splashFactory: NoSplash.splashFactory,
      ),
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final FileDownloader _fileDownloader = FileDownloader();

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  void _downloadFile() async {
    try {
      final filePath = await _fileDownloader.downloadFile(
        'https://raw.githubusercontent.com/paulp-o/ghdb/refs/heads/main/restaurant_data_with_details.csv',
        'restaurant_data_with_details.csv',
      );
      print('File downloaded to: $filePath');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(title: ''),
        ),
      );
    } catch (e) {
      print('Error: $e');
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Downloading file...'),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
    );
  }
}
