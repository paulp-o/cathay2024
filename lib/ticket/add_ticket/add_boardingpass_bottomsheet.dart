import 'package:clicky_flutter/clicky_flutter.dart';
import 'package:clicky_flutter/styles.dart';
import 'package:flutter/material.dart';

import '../scan/scanner_page.dart';

class AddBoardingPassWidgetBottomSheetContent extends StatelessWidget {
  const AddBoardingPassWidgetBottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: FittedBox(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // make two square buttons with an icon in it
                  Clicky(
                    style: const ClickyStyle(color: Colors.transparent, shrinkScale: ShrinkScale.byRatio(0.05)),
                    child: InkWell(
                      onTap: () {
                        // get camera permission
                        void getCameraPermission() async {
                          // if (await Permission.camera.request().isGranted) {
                          //   print('Permission granted');
                          //   // Either the permission was already granted before or the user just granted it.
                          // }
                        }

                        // ! START PDF417 SCANNER
                        getCameraPermission();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const DemoPage()));
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            // make outline, padding and rounded corners
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.airplane_ticket),
                          ),
                          const SizedBox(height: 16),
                          const Text('Scan Barcode'),
                        ],
                      ),
                    ),
                  ),
                  Clicky(
                    style: const ClickyStyle(color: Colors.transparent, shrinkScale: ShrinkScale.byRatio(0.05)),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/enter_manually_page');
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            // make outline, padding and rounded corners
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.qr_code),
                          ),
                          const SizedBox(height: 16),
                          const Text('Enter Manually'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
