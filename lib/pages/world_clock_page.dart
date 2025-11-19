import 'package:flutter/material.dart';
import 'dart:async';

class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key});

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  final GlobalKey<_WorldClockListState> _worldClockListKey = GlobalKey<_WorldClockListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: const Text(
            "World Clock",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.orange),
            onPressed: () {
              _worldClockListKey.currentState?._showAddCityDialog();
            },
          ),
        ],
        elevation: 0,
      ),
      body: WorldClockList(key: _worldClockListKey),
    );
  }
}

class WorldClockList extends StatefulWidget {
  const WorldClockList({super.key});

  @override
  State<WorldClockList> createState() => _WorldClockListState();
}

class _WorldClockListState extends State<WorldClockList> {
  late Timer _timer;

  final List<Map<String, dynamic>> _timeZones = [
    {
      'city': 'Kathmandu',
      'country': 'Nepal',
      'timeZone': 'Asia/Kathmandu',
      'offset': 5.75, // UTC+5:45
    },
    {
      'city': 'New York',
      'country': 'USA',
      'timeZone': 'America/New_York',
      'offset': -5, // UTC-5 (EST)
    },
    {
      'city': 'London',
      'country': 'UK',
      'timeZone': 'Europe/London',
      'offset': 0, // UTC+0
    },
    {
      'city': 'Tokyo',
      'country': 'Japan',
      'timeZone': 'Asia/Tokyo',
      'offset': 9, // UTC+9
    },
    {
      'city': 'Sydney',
      'country': 'Australia',
      'timeZone': 'Australia/Sydney',
      'offset': 11, // UTC+11
    },
  ];

  // Predefined cities that users can choose from
  final List<Map<String, dynamic>> _availableCities = [
    // North America
    {'city': 'New York', 'country': 'USA', 'timeZone': 'America/New_York', 'offset': -5},
    {'city': 'Los Angeles', 'country': 'USA', 'timeZone': 'America/Los_Angeles', 'offset': -8},
    {'city': 'Chicago', 'country': 'USA', 'timeZone': 'America/Chicago', 'offset': -6},
    {'city': 'Toronto', 'country': 'Canada', 'timeZone': 'America/Toronto', 'offset': -5},
    {'city': 'Vancouver', 'country': 'Canada', 'timeZone': 'America/Vancouver', 'offset': -8},
    {'city': 'Mexico City', 'country': 'Mexico', 'timeZone': 'America/Mexico_City', 'offset': -6},
    {'city': 'Miami', 'country': 'USA', 'timeZone': 'America/New_York', 'offset': -5},
    {'city': 'Las Vegas', 'country': 'USA', 'timeZone': 'America/Los_Angeles', 'offset': -8},
    {'city': 'Denver', 'country': 'USA', 'timeZone': 'America/Denver', 'offset': -7},
    {'city': 'Phoenix', 'country': 'USA', 'timeZone': 'America/Phoenix', 'offset': -7},
    {'city': 'Seattle', 'country': 'USA', 'timeZone': 'America/Los_Angeles', 'offset': -8},
    {'city': 'Montreal', 'country': 'Canada', 'timeZone': 'America/Montreal', 'offset': -5},
    
    // South America
    {'city': 'São Paulo', 'country': 'Brazil', 'timeZone': 'America/Sao_Paulo', 'offset': -3},
    {'city': 'Rio de Janeiro', 'country': 'Brazil', 'timeZone': 'America/Sao_Paulo', 'offset': -3},
    {'city': 'Buenos Aires', 'country': 'Argentina', 'timeZone': 'America/Argentina/Buenos_Aires', 'offset': -3},
    {'city': 'Lima', 'country': 'Peru', 'timeZone': 'America/Lima', 'offset': -5},
    {'city': 'Bogotá', 'country': 'Colombia', 'timeZone': 'America/Bogota', 'offset': -5},
    {'city': 'Santiago', 'country': 'Chile', 'timeZone': 'America/Santiago', 'offset': -3},
    {'city': 'Caracas', 'country': 'Venezuela', 'timeZone': 'America/Caracas', 'offset': -4},
    
    // Europe
    {'city': 'London', 'country': 'UK', 'timeZone': 'Europe/London', 'offset': 0},
    {'city': 'Paris', 'country': 'France', 'timeZone': 'Europe/Paris', 'offset': 1},
    {'city': 'Berlin', 'country': 'Germany', 'timeZone': 'Europe/Berlin', 'offset': 1},
    {'city': 'Rome', 'country': 'Italy', 'timeZone': 'Europe/Rome', 'offset': 1},
    {'city': 'Madrid', 'country': 'Spain', 'timeZone': 'Europe/Madrid', 'offset': 1},
    {'city': 'Amsterdam', 'country': 'Netherlands', 'timeZone': 'Europe/Amsterdam', 'offset': 1},
    {'city': 'Vienna', 'country': 'Austria', 'timeZone': 'Europe/Vienna', 'offset': 1},
    {'city': 'Brussels', 'country': 'Belgium', 'timeZone': 'Europe/Brussels', 'offset': 1},
    {'city': 'Prague', 'country': 'Czech Republic', 'timeZone': 'Europe/Prague', 'offset': 1},
    {'city': 'Warsaw', 'country': 'Poland', 'timeZone': 'Europe/Warsaw', 'offset': 1},
    {'city': 'Stockholm', 'country': 'Sweden', 'timeZone': 'Europe/Stockholm', 'offset': 1},
    {'city': 'Oslo', 'country': 'Norway', 'timeZone': 'Europe/Oslo', 'offset': 1},
    {'city': 'Copenhagen', 'country': 'Denmark', 'timeZone': 'Europe/Copenhagen', 'offset': 1},
    {'city': 'Helsinki', 'country': 'Finland', 'timeZone': 'Europe/Helsinki', 'offset': 2},
    {'city': 'Athens', 'country': 'Greece', 'timeZone': 'Europe/Athens', 'offset': 2},
    {'city': 'Zurich', 'country': 'Switzerland', 'timeZone': 'Europe/Zurich', 'offset': 1},
    {'city': 'Dublin', 'country': 'Ireland', 'timeZone': 'Europe/Dublin', 'offset': 0},
    {'city': 'Lisbon', 'country': 'Portugal', 'timeZone': 'Europe/Lisbon', 'offset': 0},
    {'city': 'Moscow', 'country': 'Russia', 'timeZone': 'Europe/Moscow', 'offset': 3},
    {'city': 'Istanbul', 'country': 'Turkey', 'timeZone': 'Europe/Istanbul', 'offset': 3},
    {'city': 'Budapest', 'country': 'Hungary', 'timeZone': 'Europe/Budapest', 'offset': 1},
    {'city': 'Bucharest', 'country': 'Romania', 'timeZone': 'Europe/Bucharest', 'offset': 2},
    {'city': 'Kiev', 'country': 'Ukraine', 'timeZone': 'Europe/Kiev', 'offset': 2},
    
    // Asia
    {'city': 'Tokyo', 'country': 'Japan', 'timeZone': 'Asia/Tokyo', 'offset': 9},
    {'city': 'Beijing', 'country': 'China', 'timeZone': 'Asia/Shanghai', 'offset': 8},
    {'city': 'Shanghai', 'country': 'China', 'timeZone': 'Asia/Shanghai', 'offset': 8},
    {'city': 'Hong Kong', 'country': 'Hong Kong', 'timeZone': 'Asia/Hong_Kong', 'offset': 8},
    {'city': 'Singapore', 'country': 'Singapore', 'timeZone': 'Asia/Singapore', 'offset': 8},
    {'city': 'Seoul', 'country': 'South Korea', 'timeZone': 'Asia/Seoul', 'offset': 9},
    {'city': 'Mumbai', 'country': 'India', 'timeZone': 'Asia/Kolkata', 'offset': 5.5},
    {'city': 'Delhi', 'country': 'India', 'timeZone': 'Asia/Kolkata', 'offset': 5.5},
    {'city': 'Bangalore', 'country': 'India', 'timeZone': 'Asia/Kolkata', 'offset': 5.5},
    {'city': 'Chennai', 'country': 'India', 'timeZone': 'Asia/Kolkata', 'offset': 5.5},
    {'city': 'Kolkata', 'country': 'India', 'timeZone': 'Asia/Kolkata', 'offset': 5.5},
    {'city': 'Bangkok', 'country': 'Thailand', 'timeZone': 'Asia/Bangkok', 'offset': 7},
    {'city': 'Jakarta', 'country': 'Indonesia', 'timeZone': 'Asia/Jakarta', 'offset': 7},
    {'city': 'Manila', 'country': 'Philippines', 'timeZone': 'Asia/Manila', 'offset': 8},
    {'city': 'Kuala Lumpur', 'country': 'Malaysia', 'timeZone': 'Asia/Kuala_Lumpur', 'offset': 8},
    {'city': 'Ho Chi Minh City', 'country': 'Vietnam', 'timeZone': 'Asia/Ho_Chi_Minh', 'offset': 7},
    {'city': 'Hanoi', 'country': 'Vietnam', 'timeZone': 'Asia/Ho_Chi_Minh', 'offset': 7},
    {'city': 'Taipei', 'country': 'Taiwan', 'timeZone': 'Asia/Taipei', 'offset': 8},
    {'city': 'Dubai', 'country': 'UAE', 'timeZone': 'Asia/Dubai', 'offset': 4},
    {'city': 'Abu Dhabi', 'country': 'UAE', 'timeZone': 'Asia/Dubai', 'offset': 4},
    {'city': 'Doha', 'country': 'Qatar', 'timeZone': 'Asia/Qatar', 'offset': 3},
    {'city': 'Riyadh', 'country': 'Saudi Arabia', 'timeZone': 'Asia/Riyadh', 'offset': 3},
    {'city': 'Kuwait City', 'country': 'Kuwait', 'timeZone': 'Asia/Kuwait', 'offset': 3},
    {'city': 'Tehran', 'country': 'Iran', 'timeZone': 'Asia/Tehran', 'offset': 3.5},
    {'city': 'Karachi', 'country': 'Pakistan', 'timeZone': 'Asia/Karachi', 'offset': 5},
    {'city': 'Islamabad', 'country': 'Pakistan', 'timeZone': 'Asia/Karachi', 'offset': 5},
    {'city': 'Dhaka', 'country': 'Bangladesh', 'timeZone': 'Asia/Dhaka', 'offset': 6},
    {'city': 'Colombo', 'country': 'Sri Lanka', 'timeZone': 'Asia/Colombo', 'offset': 5.5},
    {'city': 'Yangon', 'country': 'Myanmar', 'timeZone': 'Asia/Yangon', 'offset': 6.5},
    {'city': 'Phnom Penh', 'country': 'Cambodia', 'timeZone': 'Asia/Phnom_Penh', 'offset': 7},
    {'city': 'Kathmandu', 'country': 'Nepal', 'timeZone': 'Asia/Kathmandu', 'offset': 5.75},
    {'city': 'Kabul', 'country': 'Afghanistan', 'timeZone': 'Asia/Kabul', 'offset': 4.5},
    {'city': 'Tashkent', 'country': 'Uzbekistan', 'timeZone': 'Asia/Tashkent', 'offset': 5},
    {'city': 'Almaty', 'country': 'Kazakhstan', 'timeZone': 'Asia/Almaty', 'offset': 6},
    
    // Africa
    {'city': 'Cairo', 'country': 'Egypt', 'timeZone': 'Africa/Cairo', 'offset': 2},
    {'city': 'Lagos', 'country': 'Nigeria', 'timeZone': 'Africa/Lagos', 'offset': 1},
    {'city': 'Johannesburg', 'country': 'South Africa', 'timeZone': 'Africa/Johannesburg', 'offset': 2},
    {'city': 'Cape Town', 'country': 'South Africa', 'timeZone': 'Africa/Johannesburg', 'offset': 2},
    {'city': 'Nairobi', 'country': 'Kenya', 'timeZone': 'Africa/Nairobi', 'offset': 3},
    {'city': 'Addis Ababa', 'country': 'Ethiopia', 'timeZone': 'Africa/Addis_Ababa', 'offset': 3},
    {'city': 'Casablanca', 'country': 'Morocco', 'timeZone': 'Africa/Casablanca', 'offset': 1},
    {'city': 'Tunis', 'country': 'Tunisia', 'timeZone': 'Africa/Tunis', 'offset': 1},
    {'city': 'Algiers', 'country': 'Algeria', 'timeZone': 'Africa/Algiers', 'offset': 1},
    {'city': 'Accra', 'country': 'Ghana', 'timeZone': 'Africa/Accra', 'offset': 0},
    {'city': 'Dar es Salaam', 'country': 'Tanzania', 'timeZone': 'Africa/Dar_es_Salaam', 'offset': 3},
    {'city': 'Kampala', 'country': 'Uganda', 'timeZone': 'Africa/Kampala', 'offset': 3},
    {'city': 'Kigali', 'country': 'Rwanda', 'timeZone': 'Africa/Kigali', 'offset': 2},
    {'city': 'Lusaka', 'country': 'Zambia', 'timeZone': 'Africa/Lusaka', 'offset': 2},
    {'city': 'Harare', 'country': 'Zimbabwe', 'timeZone': 'Africa/Harare', 'offset': 2},
    
    // Oceania
    {'city': 'Sydney', 'country': 'Australia', 'timeZone': 'Australia/Sydney', 'offset': 11},
    {'city': 'Melbourne', 'country': 'Australia', 'timeZone': 'Australia/Melbourne', 'offset': 11},
    {'city': 'Brisbane', 'country': 'Australia', 'timeZone': 'Australia/Brisbane', 'offset': 10},
    {'city': 'Perth', 'country': 'Australia', 'timeZone': 'Australia/Perth', 'offset': 8},
    {'city': 'Adelaide', 'country': 'Australia', 'timeZone': 'Australia/Adelaide', 'offset': 10.5},
    {'city': 'Auckland', 'country': 'New Zealand', 'timeZone': 'Pacific/Auckland', 'offset': 13},
    {'city': 'Wellington', 'country': 'New Zealand', 'timeZone': 'Pacific/Auckland', 'offset': 13},
    {'city': 'Christchurch', 'country': 'New Zealand', 'timeZone': 'Pacific/Auckland', 'offset': 13},
    {'city': 'Suva', 'country': 'Fiji', 'timeZone': 'Pacific/Fiji', 'offset': 12},
    {'city': 'Port Vila', 'country': 'Vanuatu', 'timeZone': 'Pacific/Efate', 'offset': 11},
    {'city': 'Noumea', 'country': 'New Caledonia', 'timeZone': 'Pacific/Noumea', 'offset': 11},
    
    // Pacific Islands
    {'city': 'Honolulu', 'country': 'USA', 'timeZone': 'Pacific/Honolulu', 'offset': -10},
    {'city': 'Anchorage', 'country': 'USA', 'timeZone': 'America/Anchorage', 'offset': -9},
    {'city': 'Papeete', 'country': 'French Polynesia', 'timeZone': 'Pacific/Tahiti', 'offset': -10},
    {'city': 'Nuku\'alofa', 'country': 'Tonga', 'timeZone': 'Pacific/Tongatapu', 'offset': 13},
    {'city': 'Apia', 'country': 'Samoa', 'timeZone': 'Pacific/Apia', 'offset': 13},
  ];

  void _showAddCityDialog() {
    // Get cities not already in the list
    final availableToAdd = _availableCities.where((city) => 
      !_timeZones.any((existing) => existing['city'] == city['city'])
    ).toList();

    String searchQuery = '';
    List<Map<String, dynamic>> filteredCities = List.from(availableToAdd);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Add City',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search cities...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          searchQuery = value.toLowerCase();
                          filteredCities = availableToAdd.where((city) {
                            final cityName = city['city'].toString().toLowerCase();
                            final countryName = city['country'].toString().toLowerCase();
                            return cityName.contains(searchQuery) || 
                                   countryName.contains(searchQuery);
                          }).toList();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Results count
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filteredCities.length} cities available',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // City list
                    Expanded(
                      child: filteredCities.isEmpty
                          ? Center(
                              child: Text(
                                searchQuery.isEmpty 
                                    ? 'All available cities have been added.' 
                                    : 'No cities found matching "$searchQuery"',
                                style: const TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Theme(
                              data: Theme.of(context).copyWith(
                                scrollbarTheme: ScrollbarThemeData(
                                  thumbColor: WidgetStateProperty.all(Colors.orange),
                                  trackColor: WidgetStateProperty.all(Colors.grey[800]),
                                  thickness: WidgetStateProperty.all(6),
                                  radius: const Radius.circular(3),
                                ),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                thickness: 6,
                                radius: const Radius.circular(3),
                                trackVisibility: true,
                                child: ListView.builder(
                                  itemCount: filteredCities.length,
                                  itemBuilder: (context, index) {
                                    final city = filteredCities[index];
                                    return ListTile(
                                      leading: const Icon(Icons.public, color: Colors.orange),
                                      title: Text(
                                        city['city'],
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        '${city['country']} • UTC${city['offset'] >= 0 ? '+' : ''}${city['offset']}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _timeZones.add(city);
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteCity(int index) {
    setState(() {
      _timeZones.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getFormattedTime(dynamic offset) {
    final offsetDouble = (offset is double) ? offset : (offset as num).toDouble();
    final now = DateTime.now().toUtc();
    final hours = offsetDouble.floor();
    final minutes = ((offsetDouble - hours) * 60).round();
    final localTime = now.add(Duration(hours: hours, minutes: minutes));
    
    final hour = localTime.hour;
    final minute = localTime.minute;
    
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _getTimeDifference(dynamic offset) {
    final offsetDouble = (offset is double) ? offset : (offset as num).toDouble();
    final now = DateTime.now();
    final localOffset = now.timeZoneOffset.inHours + (now.timeZoneOffset.inMinutes % 60) / 60.0;
    final difference = offsetDouble - localOffset;
    
    if (difference == 0) {
      return 'Today, 0hrs';
    } else if (difference > 0) {
      return 'Today, +${difference.abs().toStringAsFixed(difference == difference.floor() ? 0 : 1)}hrs';
    } else {
      return 'Today, ${difference.toStringAsFixed(difference == difference.floor() ? 0 : 1)}hrs';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 6,
      radius: const Radius.circular(3),
      trackVisibility: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        itemCount: _timeZones.length,
        itemBuilder: (context, index) {
          final timeZone = _timeZones[index];
          final time = _getFormattedTime(timeZone['offset']);
          final timeDiff = _getTimeDifference(timeZone['offset']);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Globe icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.public,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // City and time difference
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeDiff,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeZone['city'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Time display
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                
                // Delete button
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () {
                    _deleteCity(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
