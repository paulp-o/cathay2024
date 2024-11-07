// there will be a text file of databases that contains the list of airports, and corresponding country and city on this link:
// parse the content with below form:
// E.G.:
// 1,"Goroka Airport","Goroka","Papua New Guinea","GKA","AYGA",-6.081689834590001,145.391998291,5282,10,"U","Pacific/Port_Moresby","airport","OurAirports"
// 2,"Madang Airport","Madang","Papua New Guinea","MAG","AYMD",-5.20707988739,145.789001465,20,10,"U","Pacific/Port_Moresby","airport","OurAirports"
// 640,"Bardufoss Airport","Bardufoss","Norway","BDU","ENDU",69.055801391602,18.540399551392,252,1,"E","Europe/Oslo","airport","OurAirports"
// below is a function that: Receive an airport code, and return the corresponding city and country name as "city, country" format, with use of the text file above.

import 'package:flutter/services.dart';

String? _airportRawData;

class AirportToCity {
  Future<String> convert(String airportCode) async {
    _airportRawData = await rootBundle.loadString('assets/airportdb.txt');
    List<String> airportRawDataList = _airportRawData!.split("\n");
    String airportRawDataListElement = airportRawDataList.firstWhere((element) => element.contains(airportCode));
    List<String> airportRawDataListElementList = airportRawDataListElement.split(",");
    String airportCity = airportRawDataListElementList[2];
    String airportCountry = airportRawDataListElementList[3];
    String airportCityCountry = airportCity + "\n" + airportCountry;
    return airportCityCountry.replaceAll('"', '');
  }
}
