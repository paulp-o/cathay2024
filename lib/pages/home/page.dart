import 'package:clicky_flutter/clicky_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late GoogleMapController _mapController;
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  String _sheetTitle = 'Place Name';
  String _sheetDescription = 'Detailed Address';
  LatLng _sheetPosition = LatLng(22.2968, 114.1722);
  final RxDouble _sheetHeight = 0.0.obs;
  double _sheetState = 0.0;

  @override
  void initState() {
    _sheetState = 0.0;
    super.initState();
    _sheetController.addListener(() {
      _sheetHeight.value = _sheetController.size;
      // _checkSnapPoints();
    });
  }

  void _checkSnapPoints() {
    if (_sheetController.size < 0.4) {
      print('Bottom sheet snapped to 0.3');
      _sheetHeight.value = _sheetState = 0.3;
    } else if (_sheetController.size > 0.95) {
      print('Bottom sheet snapped to 1.0');
      _sheetHeight.value = _sheetState = 1.0;
      // setState(() {
      //   _sheetState = 1.0;
      // });
      // Add your custom logic here
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _moveCamera(LatLng position, String title, String description) {
    _mapController.animateCamera(CameraUpdate.newLatLng(position));
    setState(() {
      _sheetTitle = title;
      _sheetDescription = description;
      _sheetPosition = position;
      _sheetState = 0.3;
      _sheetHeight.value = 0.3;
    });
    _sheetController.animateTo(0.3, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId('marker1'),
        position: LatLng(22.297, 114.172),
        onTap: () {
          _moveCamera(LatLng(22.297, 114.172), 'Marker 1', 'This is marker 1');
        },
      ),
      Marker(
        markerId: MarkerId('marker2'),
        position: LatLng(22.296, 114.173),
        onTap: () {
          _moveCamera(LatLng(22.296, 114.173), 'Marker 2', 'This is marker 2');
        },
      ),
      Marker(
        markerId: MarkerId('marker3'),
        position: LatLng(22.295, 114.171),
        onTap: () {
          _moveCamera(LatLng(22.295, 114.171), 'Marker 3', 'This is marker 3');
        },
      ),
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(() {
          return AnimatedOpacity(
            opacity: _sheetHeight.value > 0.50 ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: _sheetHeight.value > 0.55,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Clicky(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
                        margin: const EdgeInsets.only(bottom: 2.0),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Handle the tap
                          },
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.black, size: 30),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TST",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(22.2968, 114.1722),
              zoom: 14.4746,
            ),
            markers: markers,
          ),
          DraggableScrollableSheet(
            snapAnimationDuration: const Duration(milliseconds: 300),
            controller: _sheetController,
            initialChildSize: _sheetState > 0.0 ? 0.3 : 0.0,
            minChildSize: _sheetState > 0.0 ? 0.3 : 0.0,
            maxChildSize: 1,
            snap: true,
            snapSizes: [0.3, 1],
            shouldCloseOnMinExtent: false,
            builder: (BuildContext context, ScrollController scrollController) {
              return Obx(() {
                return BottomSheetContent(
                  title: _sheetTitle,
                  description: _sheetDescription,
                  position: _sheetPosition,
                  scrollController: scrollController,
                  sheetController: _sheetController,
                  onClose: () {
                    setState(() {
                      _sheetState = 0.0;
                      _sheetHeight.value = 0.0;
                      // animate to 0.0 after 0.01 seconds to prevent flickering
                      Future.delayed(Duration(milliseconds: 50), () {
                        _sheetController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                      });
                    });
                  },
                  sheetHeight: _sheetHeight.value,
                );
              });
            },
          ),
          Positioned(
            right: 16.0,
            top: 16.0 + kToolbarHeight,
            child: AnimatedOpacity(
              opacity: _sheetHeight.value > 0 ? 0.0 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // chatbot icon button
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: IconButton(
                      icon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat,
                            color: Colors.white,
                            size: 35, // Increase icon size
                          ),
                          Container(
                            height: 16, // Set a fixed height
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Chat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Increase text size
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      iconSize: 50, // Increase button size
                      style: ButtonStyle(),
                      onPressed: () {
                        // Handle chatbot button press
                      },
                    ),
                  ),

                  // plane icon button
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: IconButton(
                      icon: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.airplanemode_active,
                            color: Colors.white,
                            size: 35, // Increase icon size
                          ),
                          Container(
                            height: 16, // Set a fixed height
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Flight',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, // Increase text size
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      iconSize: 50, // Increase button size
                      style: ButtonStyle(),
                      onPressed: () {
                        // Handle settings button press
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _sheetState > 0.0 ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Handle text button press
          },
          label: Text(
            'search here',
            style: TextStyle(
              color: Colors.white,
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
          ),
          icon: Icon(Icons.search),
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

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
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.onPrimary,
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
            Divider(
              color: Colors.white,
              thickness: 1.0,
            ),
            Center(
              child: Container(
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
            ),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
