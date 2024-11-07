import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BottomSheetContent extends StatelessWidget {
  final String title;
  final String description;
  final LatLng position;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final VoidCallback onClose;
  final double sheetHeight;

  const BottomSheetContent({
    Key? key,
    required this.title,
    required this.description,
    required this.position,
    required this.scrollController,
    required this.sheetController,
    required this.onClose,
    required this.sheetHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColorDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  // make the line disappear when the sheet is fully expanded
                  color: Colors.white.withOpacity(sheetHeight > 0.95 ? 0.0 : 0.8),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            // add some space when the sheet is fully expanded. Use smooth animation
            AnimatedContainer(
              duration: Duration(milliseconds: 600),
              height: sheetHeight > 0.95 ? 25.0 : 0.0,
              curve: Curves.easeOut,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AnimatedCrossFade(
                  sizeCurve: Curves.easeOut,
                  firstCurve: Curves.easeOut,
                  secondCurve: Curves.easeOut,
                  firstChild: Container(),
                  secondChild: InkWell(
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        sheetController.animateTo(0.3, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                      },
                    ),
                  ),
                  crossFadeState: sheetHeight > 0.95 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 600),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Spacer(),

                // conditionally show the close button when the sheet is fully expanded. use smooth animation
                AnimatedOpacity(
                  opacity: sheetHeight > 0.95 ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: sheetHeight == 1
                        ? null
                        : () {
                            sheetController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                            onClose();
                          },
                  ),
                )
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Latitude: ${position.latitude}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            Text(
              'Longitude: ${position.longitude}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Reservation Date: 2023-10-01',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // Handle reservation button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text(
                'Make Reservation',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 8.0),
            Stack(
              alignment: Alignment.center,
              children: [
                Divider(
                  color: Colors.white,
                  thickness: 1.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 12.0),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      color: Colors.white,
                      child: Text(
                        'Main Dish',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
