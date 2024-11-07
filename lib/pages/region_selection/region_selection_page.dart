import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const hong_kong_regions = {
  "Hong Kong Island": {
    "Central and Western": {
      "Central": {"lat": 22.2822, "lng": 114.1588},
      "Sheung Wan": {"lat": 22.2870, "lng": 114.1495},
      "Sai Ying Pun": {"lat": 22.2867, "lng": 114.1403},
    },
    "Eastern": {
      "North Point": {"lat": 22.2913, "lng": 114.2006},
      "Quarry Bay": {"lat": 22.2908, "lng": 114.2097},
      "Shau Kei Wan": {"lat": 22.2790, "lng": 114.2304},
    },
  },
  "Kowloon": {
    "Yau Tsim Mong": {
      "Tsim Sha Tsui": {"lat": 22.2976, "lng": 114.1722},
      "Yau Ma Tei": {"lat": 22.3113, "lng": 114.1708},
      "Mong Kok": {"lat": 22.3193, "lng": 114.1702},
    },
    "Kowloon City": {
      "Ho Man Tin": {"lat": 22.3167, "lng": 114.1780},
      "To Kwa Wan": {"lat": 22.3175, "lng": 114.1890},
      "Hung Hom": {"lat": 22.3034, "lng": 114.1812},
    },
  },
  "New Territories": {
    "Tsuen Wan": {
      "Tsuen Wan Town": {"lat": 22.3732, "lng": 114.1176},
      "Kwai Chung": {"lat": 22.3637, "lng": 114.1324},
    },
    "Sha Tin": {
      "Sha Tin Town": {"lat": 22.3820, "lng": 114.1915},
      "Tai Wai": {"lat": 22.3727, "lng": 114.1817},
    },
  },
};

class RegionSelectionPage extends StatefulWidget {
  final String? initialSelectedRegion;

  RegionSelectionPage({this.initialSelectedRegion});

  @override
  _RegionSelectionPageState createState() => _RegionSelectionPageState();
}

class _RegionSelectionPageState extends State<RegionSelectionPage> {
  String? selectedRegion;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedRegion = widget.initialSelectedRegion;
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Region'),
      ),
      body: Column(
        children: [
          if (selectedRegion != null)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Selected Region: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Hero(
                    tag: 'selectedRegion',
                    child: Text(
                      selectedRegion!,
                      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: hong_kong_regions.entries.where((region) {
                final regionName = region.key.toLowerCase();
                final matchesRegion = regionName.contains(searchQuery.toLowerCase());
                final matchesDistrict = region.value.entries.any((district) {
                  final districtName = district.key.toLowerCase();
                  final matchesDistrictName = districtName.contains(searchQuery.toLowerCase());
                  final matchesNeighborhood = district.value.entries.any((neighborhood) {
                    final neighborhoodName = neighborhood.key.toLowerCase();
                    return neighborhoodName.contains(searchQuery.toLowerCase());
                  });
                  return matchesDistrictName || matchesNeighborhood;
                });
                return matchesRegion || matchesDistrict;
              }).map((region) {
                return ExpansionTile(
                  title: Text(
                    region.key,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: region.value.entries.where((district) {
                    final districtName = district.key.toLowerCase();
                    final matchesDistrictName = districtName.contains(searchQuery.toLowerCase());
                    final matchesNeighborhood = district.value.entries.any((neighborhood) {
                      final neighborhoodName = neighborhood.key.toLowerCase();
                      return neighborhoodName.contains(searchQuery.toLowerCase());
                    });
                    return matchesDistrictName || matchesNeighborhood;
                  }).map((district) {
                    return ExpansionTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          district.key,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      children: district.value.entries.where((neighborhood) {
                        final neighborhoodName = neighborhood.key.toLowerCase();
                        return neighborhoodName.contains(searchQuery.toLowerCase());
                      }).map((neighborhood) {
                        return ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(
                              neighborhood.key,
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                          onTap: () {
                            final latLng = LatLng(
                              neighborhood.value['lat'] ?? 0.0,
                              neighborhood.value['lng'] ?? 0.0,
                            );
                            setState(() {
                              selectedRegion = neighborhood.key;
                            });
                            Get.back(result: {
                              'title': neighborhood.key,
                              'latLng': latLng,
                            });
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
