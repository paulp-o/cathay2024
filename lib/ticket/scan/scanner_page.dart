import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart'
    show
        CameraLensDirection,
        Code,
        Codes,
        DynamicScannerOverlay,
        FixedScannerOverlay,
        Format,
        ReaderWidget,
        ResolutionPreset,
        zx;
// import '../../../../libraries/zxing_ui/ui/reader_widget.dart' show ReaderWidget;

// import '../../../../libraries/zxing_ui/widgets/debug_info_widget.dart';
// import '../../../../libraries/zxing_ui/widgets/unsupported_platform_widget.dart';
// import '../../../../logic/pdf417parser.dart';
import '../../logic/pdf417parser.dart';
import 'scan_result_page.dart';

void main() {
  zx.setLogEnabled(kDebugMode);
  debugPrint('ZXing version:  ${zx.version()}');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Zxing Example',
      debugShowCheckedModeBanner: false,
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  Uint8List? createdCodeBytes;
  Code? result;
  Codes? multiResult;
  bool isMultiScan = true;
  bool showDebugInfo = false;
  int successScans = 0;
  int failedScans = 0;

  // Add a flag to track if we're currently processing a scan
  bool _isProcessingScan = false;

  @override
  Widget build(BuildContext context) {
    final isCameraSupported = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
        backgroundColor: Colors.transparent,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18)),
        ),
        leadingWidth: 100,
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (kIsWeb)
              const UnsupportedPlatformWidget()
            else if (!isCameraSupported)
              const Center(
                child: Text('Camera not supported on this platform'),
              )
            else
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ReaderWidget(
                  onScan: _onScanSuccess,
                  onScanFailure: _onScanFailure,
                  onMultiScan: _onMultiScanSuccess,
                  onMultiScanFailure: _onMultiScanFailure,
                  onMultiScanModeChanged: null,
                  isMultiScan: isMultiScan,
                  showScannerOverlay: true,
                  tryInverted: true,
                  tryHarder: true,
                  scanDelay: const Duration(milliseconds: 100),
                  scanDelaySuccess: const Duration(milliseconds: 1000),
                  resolution: ResolutionPreset.high,
                  lensDirection: CameraLensDirection.back,
                  showToggleCamera: true,
                  showFlashlight: true,
                  tryRotate: true,
                  codeFormat: Format.pdf417,
                  cropPercent: 0,
                  loading: const Center(child: CupertinoActivityIndicator()),
                  scannerOverlay: FixedScannerOverlay(
                    borderColor: Colors.yellow,
                    borderWidth: 2,
                    overlayColor: Colors.black.withOpacity(0.5),
                    borderRadius: 10,
                    borderLength: 40,
                    cutOutSize: 250,
                  ),
                ),
              ),
            if (kIsWeb) const UnsupportedPlatformWidget(),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Text('Scan the barcode on your boarding pass. ', style: TextStyle(fontSize: 20)),
            ),
            if (showDebugInfo)
              DebugInfoWidget(
                successScans: successScans,
                failedScans: failedScans,
                error: isMultiScan ? multiResult?.error : result?.error,
                duration: isMultiScan ? multiResult?.duration ?? 0 : result?.duration ?? 0,
                onReset: _onReset,
              ),
          ],
        ),
      ),
    );
  }

  _onScanSuccess(Code? code) async {
    if (!mounted) return;
    setState(() {
      successScans++;
    });
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() {
      result = code;
    });
  }

  _onScanFailure(Code? code) {
    if (!mounted) return;
    setState(() {
      failedScans++;
      result = code;
    });
    if (code?.error?.isNotEmpty == true) {
      _showMessage(context, 'Error: ${code?.error}');
    }
  }

  _onMultiScanSuccess(Codes codes) async {
    // Return early if we're already processing a scan or if there are no codes
    if (_isProcessingScan || !mounted || codes.codes.isEmpty) return;

    // Set processing flag
    _isProcessingScan = true;

    setState(() {
      successScans++;
      multiResult = codes;
    });

    try {
      if (!mounted) return;

      final firstCode = codes.codes.first;
      print(firstCode.text);

      if (firstCode.text == null || firstCode.text!.isEmpty || firstCode.text!.length < 100) return;

      PDF417Parser(firstCode.text.toString()).printAll();

      await Future.delayed(const Duration(milliseconds: 2000));
      // Navigate to result page
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultPage(
            result: firstCode.text.toString(),
            code: firstCode,
          ),
        ),
        ModalRoute.withName('/home_page'),
      );

      if (!mounted) return;
      setState(() {
        result = null;
      });
    } finally {
      // Reset processing flag regardless of success or failure
      _isProcessingScan = false;
    }
  }

  _onMultiScanFailure(Codes result) {
    if (!mounted) return;
    setState(() {
      failedScans++;
      multiResult = result;
    });
    if (result.codes.isNotEmpty == true) {
      _showMessage(context, 'Error: ${result.codes.first.error}');
    }
  }

  _onMultiScanModeChanged(bool isMultiScan) {
    setState(() {
      this.isMultiScan = isMultiScan;
    });
  }

  _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  _onReset() {
    setState(() {
      successScans = 0;
      failedScans = 0;
    });
  }
}

class DebugInfoWidget extends StatelessWidget {
  final int successScans;
  final int failedScans;
  final String? error;
  final int duration;
  final VoidCallback onReset;

  const DebugInfoWidget({
    Key? key,
    required this.successScans,
    required this.failedScans,
    required this.error,
    required this.duration,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Success Scans: $successScans', style: const TextStyle(color: Colors.white)),
            Text('Failed Scans: $failedScans', style: const TextStyle(color: Colors.white)),
            Text('Error: $error', style: const TextStyle(color: Colors.white)),
            Text('Duration: $duration ms', style: const TextStyle(color: Colors.white)),
            ElevatedButton(
              onPressed: onReset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class UnsupportedPlatformWidget extends StatelessWidget {
  const UnsupportedPlatformWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Unsupported platform', style: TextStyle(fontSize: 20)),
    );
  }
}
