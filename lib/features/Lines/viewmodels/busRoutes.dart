import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:maasapp/core/widgets/AppBar/appBar.dart';
import 'package:maasapp/core/widgets/sideBar.dart';
import 'package:maasapp/features/Lines/viewmodels/busStops.dart';

class BusRoutes extends StatefulWidget {
  final String selectedLine;

  const BusRoutes({required this.selectedLine});

  @override
  _BusRoutesState createState() => _BusRoutesState();
}

class _BusRoutesState extends State<BusRoutes> {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();
  List<Map<dynamic, dynamic>> _allRoutes = [];
  List<Map<dynamic, dynamic>> _filteredRoutes = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedTransportType = 'Bus';

  @override
  void initState() {
    super.initState();
    _selectedTransportType = widget.selectedLine; // Set initial transport type
    _fetchRoutes();
    _searchController.addListener(_filterRoutes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterRoutes);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoutes() async {
    try {
      final snapshot = await _ref.once();
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        print('Data fetched from Firebase: $data');
        List<Map<dynamic, dynamic>> routesList = [];
        data.forEach((key, value) {
          final routeData = Map<dynamic, dynamic>.from(value);
          routesList.add(routeData);
        });
        setState(() {
          _allRoutes = routesList;
          _filterRoutes();
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print('Error fetching routes: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterRoutes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRoutes = _allRoutes.where((routeData) {
        final route = routeData['Route']?.toString().toLowerCase() ?? '';
        final type = routeData['Type']?.toString() ?? '';
        return route.contains(query) &&
            (type == _selectedTransportType ||
                (_selectedTransportType == 'Bus' &&
                    (type == 'Bus (CTA)' || type == 'Bus (Mwaslat Misr)')));
      }).toList();
    });
  }

  void _onTransportTypeSelected(String type) {
    setState(() {
      _selectedTransportType = type;
      _filterRoutes();
    });
  }

  Color _getRouteColor(String route) {
    switch (route) {
      case 'Helwan - El Marg':
        return const Color.fromARGB(255, 249, 19, 3);
      case 'Shubra El-Kheima - Giza':
        return Colors.green;
      case 'Attaba - Ain Sokhna (operational), New Administrative Capital (planned)':
        return Color(0xFF489BFC);
      default:
        return Color(0xFFFC486E); // Default color
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Arabni'),
      drawer: CommonSideBar(), // Use the common drawer widget
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Route',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: Colors.black),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTransportTypeButton(
                    'Bus', _selectedTransportType == 'Bus'),
                _buildTransportTypeButton(
                    'Metro', _selectedTransportType == 'Metro'),
                _buildTransportTypeButton(
                    'Train', _selectedTransportType == 'Train'),
                _buildTransportTypeButton(
                    'Light Rail', _selectedTransportType == 'Light Rail'),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _selectedTransportType, // Display selected transport type here
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Adjust font size as needed
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildRoutesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportTypeButton(String text, bool selected) {
    return ElevatedButton(
      onPressed: () => _onTransportTypeSelected(text),
      child: Text(text),
      style: ElevatedButton.styleFrom(
        foregroundColor: selected ? Colors.white : Colors.black,
        backgroundColor: selected ? Color(0xFFFC486E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: Colors.grey),
      ),
    );
  }

  Widget _buildRoutesList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(child: Text('Error loading routes. Please try again.'));
    }

    if (_filteredRoutes.isEmpty) {
      return Center(child: Text('No routes found'));
    }

    return ListView.builder(
      itemCount: _filteredRoutes.length,
      itemBuilder: (context, index) {
        final routeData = _filteredRoutes[index];
        final route = routeData['Route'] ?? 'Unknown Route';
        final stops = routeData['Stops'] ?? [];
        final type = routeData['Type'] ?? 'Unknown Type';
        final routeColor = _getRouteColor(route);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            color: routeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                route,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                type,
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.arrow_forward, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteStops(
                      route: route,
                      stops: List<String>.from(stops),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
