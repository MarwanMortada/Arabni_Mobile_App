import 'package:flutter/material.dart';
import 'package:maasapp/core/widgets/AppBar/appBar.dart';
import 'package:maasapp/core/widgets/sideBar.dart';

class RouteStops extends StatefulWidget {
  final String route;
  final List<String> stops;

  const RouteStops({
    required this.route,
    required this.stops,
  });

  @override
  _RouteStopsState createState() => _RouteStopsState();
}

class _RouteStopsState extends State<RouteStops> {
  late List<String> _filteredStops;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStops = widget.stops;
    _searchController.addListener(_filterStops);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStops);
    _searchController.dispose();
    super.dispose();
  }

  void _filterStops() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStops = widget.stops
          .where((stop) => stop.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Arabni'),
      drawer: CommonSideBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFC486E),
                borderRadius: BorderRadius.circular(20),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    widget.route,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Stop',
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
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStops.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (index != 0)
                        Expanded(
                          child: VerticalDivider(
                            color: Color(0xFFFC486E),
                            thickness: 2,
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFC486E),
                        ),
                        width: 10,
                        height: 10,
                      ),
                      if (index != _filteredStops.length - 1)
                        Expanded(
                          child: VerticalDivider(
                            color: Color(0xFFFC486E),
                            thickness: 2,
                          ),
                        ),
                    ],
                  ),
                  title: Text(_filteredStops[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
