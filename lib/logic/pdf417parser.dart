// In this file, we are going to implement the logic of the PDF417 parser.
// it will convert from pdf417 barcode string of a boarding pass, and extract
// passenger information from it.
// info is: name, flight number, seat number, departure airport, arrival airport, departure time, arrival time, gate number, and class.
// example string: "M1PARK/BYEONG HYUN    ETMU6RM DXBHKGCX 0738 238Y046A0072 34B>6180 O3238BCX              2A16096546121970 CX                        N8"

class PDF417Parser {
  String _pdf417String = "";
  String _name = "";
  String _flightNumber = "";
  String _seatNumber = "";
  String _boardingSequenceNumber = "";
  String _departureAirport = "";
  String _arrivalAirport = "";
  String _flightDate = "";

  PDF417Parser(String pdf417String) {
    _pdf417String = pdf417String;
    _parse();
  }

  void _parse() {
    final bcbpString = _pdf417String;
    // print out the length of the bcbpString first
    print("Length of BCBP string: ${bcbpString.length}");
    _name = bcbpString.substring(2, 21).trim();
    // final operatingCarrierPNRCode = bcbpString.substring(22, 30).trim(); // Not used but extracted for completeness.
    _departureAirport = bcbpString.substring(30, 33);
    _arrivalAirport = bcbpString.substring(33, 36);
    // final operatingCarrierDesignator = bcbpString.substring(36, 39); // Not used but extracted for completeness.
    _flightNumber = bcbpString.substring(39, 44).trim();
    _flightDate = bcbpString.substring(44, 47); // This is in Julian date format, you'll need to convert to a regular date.
    _seatNumber = bcbpString.substring(48, 52).trim();
    _boardingSequenceNumber = bcbpString.substring(52, 57).trim();
    // final checkInSequenceNumber = bcbpString.substring(52, 57).trim(); // Not used but extracted for completeness.
    //  _passengerStatus = bcbpString.substring(57, 58); // Not used but extracted for completeness.
  }

  String getName() {
    return _name;
  }

  String getFlightNumber() {
    return _flightNumber;
  }

  String getSeatNumber() {
    return _seatNumber;
  }

  String getDepartureAirport() {
    return _departureAirport;
  }

  String getArrivalAirport() {
    return _arrivalAirport;
  }

  String getDepartureDateByDaysSinceJanFirst() {
    return _flightDate;
  }

  String getBoardingSequenceNumber() {
    return _boardingSequenceNumber;
  }

  void printAll() {
    print("name: $_name");
    print("flight number: $_flightNumber");
    print("seat number: $_seatNumber");
    print("departure airport: $_departureAirport");
    print("arrival airport: $_arrivalAirport");
    print("boarding sequence number: $_boardingSequenceNumber");
    print("departure date: $_flightDate");
  }
}
