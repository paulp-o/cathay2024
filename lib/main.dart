import 'package:flutter/material.dart';
import 'pages/home/page.dart';
import 'utils/file_downloader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Downloader',
      theme: ThemeData(
        canvasColor: Colors.transparent,
        scaffoldBackgroundColor: Colors.transparent,
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.black.withOpacity(0),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(0, 92, 99, 1),
          brightness: Brightness.dark,
          primary: Color.fromRGBO(0, 92, 99, 1),
        ),
        useMaterial3: true,
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
