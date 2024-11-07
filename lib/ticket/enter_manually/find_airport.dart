import 'package:clicky_flutter/clicky_flutter.dart';
import 'package:clicky_flutter/styles.dart';
import 'package:flutter/material.dart';

class FindAirportPage extends StatefulWidget {
  const FindAirportPage({super.key});

  @override
  State<FindAirportPage> createState() => _FindAirportPageState();
}

class _FindAirportPageState extends State<FindAirportPage> {
  final TextEditingController _searchController = TextEditingController();
  // final List<Widget> _airportListItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Airport"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // search bar
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {});
                      }
                    },
                    onSubmitted: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: "Search",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // search icon button
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {});
                  },
                ),
              ],
            ),
            // list of airports
            Expanded(
              child: FutureBuilder(
                future: readAirportDatabase(context),
                builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
                  if (snapshot.hasData) {
                    return (_searchController.text.isEmpty)
                        ? const Center(child: Text('Enter some text :)', style: TextStyle(fontSize: 15)))
                        : Scrollbar(
                            interactive: true,
                            radius: const Radius.circular(10),
                            child:
                                // ListView.builder(
                                //   cacheExtent: 1000,
                                //   // show scroll bar
                                //   scrollDirection: Axis.vertical,
                                //   shrinkWrap: true,
                                //   itemCount: snapshot.data!.length,

                                //   itemBuilder: (BuildContext context, int index) {
                                //     // filter the list by the search text. search any information including airport name, country and city
                                //     if (snapshot.data!.keys
                                //             .elementAt(index)
                                //             .toString()
                                //             .toLowerCase()
                                //             .contains(_searchController.text.toLowerCase()) ||
                                //         snapshot.data!.values
                                //             .elementAt(index)[0]
                                //             .toString()
                                //             .toLowerCase()
                                //             .contains(_searchController.text.toLowerCase()) ||
                                //         snapshot.data!.values
                                //             .elementAt(index)[1]
                                //             .toString()
                                //             .toLowerCase()
                                //             .contains(_searchController.text.toLowerCase()) ||
                                //         snapshot.data!.values
                                //             .elementAt(index)[2]
                                //             .toString()
                                //             .toLowerCase()
                                //             .contains(_searchController.text.toLowerCase())) {
                                //       return ListTile(
                                //         // show as:
                                //         // title: Airport Name (Code)
                                //         // subtitle: Country

                                //         title: Text(
                                //           snapshot.data!.keys.elementAt(index).toString().replaceAll('"', '') +
                                //               " (" +
                                //               snapshot.data!.values.elementAt(index)[0].toString() +
                                //               ")",
                                //         ),
                                //         // show BOTH COUNTRY AND CITY
                                //         subtitle: Text(snapshot.data!.values.elementAt(index)[2].toString() +
                                //             ", " +
                                //             snapshot.data!.values.elementAt(index)[1].toString()),
                                //         onTap: () {
                                //           // when tapped, return the airport code
                                //           Navigator.pop(
                                //             context,
                                //             snapshot.data!.values.elementAt(index)[0].toString(),
                                //           );
                                //         },
                                //       );
                                //     } else {
                                //       return const SizedBox();
                                //     }
                                //   },
                                // ),
                                /* convert above listview.builder to ListView */
                                Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: ListView(
                                physics: const ClampingScrollPhysics(),
                                children: [
                                  for (int index = 0; index < snapshot.data!.length; index++)
                                    if (snapshot.data!.keys
                                            .elementAt(index)
                                            .toString()
                                            .toLowerCase()
                                            .contains(_searchController.text.toLowerCase()) ||
                                        snapshot.data!.values
                                            .elementAt(index)[0]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_searchController.text.toLowerCase()) ||
                                        snapshot.data!.values
                                            .elementAt(index)[1]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_searchController.text.toLowerCase()) ||
                                        snapshot.data!.values
                                            .elementAt(index)[2]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_searchController.text.toLowerCase()))
                                      Clicky(
                                        style: const ClickyStyle(
                                          boundaryStyle: ClickyBoundaryStyle.fromInitialTouchPoint,
                                          boundaryFromInitialTouchPoint: 1,
                                        ),
                                        child: ListTile(
                                          // show as:
                                          // title: Airport Name (Code)
                                          // subtitle: Country
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                          title: Text(
                                            "${snapshot.data!.keys.elementAt(index).toString().replaceAll('"', '')} (${snapshot.data!.values.elementAt(index)[0]})",
                                          ),
                                          // show BOTH COUNTRY AND CITY
                                          subtitle: Text(
                                              "${snapshot.data!.values.elementAt(index)[2]}, ${snapshot.data!.values.elementAt(index)[1]}"),
                                          onTap: () {
                                            // when tapped, return the airport code
                                            Navigator.pop(
                                              context,
                                              snapshot.data!.values.elementAt(index)[0].toString(),
                                            );
                                          },
                                        ),
                                      )
                                ],
                              ),
                            ),
                          );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// there will be a text file of databases that contains the list of airports, and corresponding country and city on this link:
// parse the content in below form:
// E.G.:
// 1,"Goroka Airport","Goroka","Papua New Guinea","GKA","AYGA",-6.081689834590001,145.391998291,5282,10,"U","Pacific/Port_Moresby","airport","OurAirports"
// 2,"Madang Airport","Madang","Papua New Guinea","MAG","AYMD",-5.20707988739,145.789001465,20,10,"U","Pacific/Port_Moresby","airport","OurAirports"
// 640,"Bardufoss Airport","Bardufoss","Norway","BDU","ENDU",69.055801391602,18.540399551392,252,1,"E","Europe/Oslo","airport","OurAirports"
// below is a function that reads the text file and convert them into a map containing country, city and airport code

Future<Map> readAirportDatabase(context) async {
  String airportRawData = await DefaultAssetBundle.of(context).loadString("assets/airportdb.txt");
  // convert the text file into a map, that includes all of these: airport name, code, country and city
  Map<String, List<String>> airportMap = {};
  // map is in the form of:
// {
//   "airport name": [airport code, country, city],
//   "airport name": [airport code, country, city],
// }
  List<String> airportRawDataList = airportRawData.split("\n");
  for (int i = 0; i < airportRawDataList.length; i++) {
    // split the data into a list
    List<String> airportData = airportRawDataList[i].split(",");
    // add the data into the map
    airportMap[airportData[1]] = [airportData[4], airportData[3], airportData[2]];
  }
  // remove all " from the map
  airportMap.forEach((key, value) {
    key = key.replaceAll('"', '');
    value[0] = value[0].replaceAll('"', '');
    value[1] = value[1].replaceAll('"', '');
    value[2] = value[2].replaceAll('"', '');
  });

  return airportMap;
}
