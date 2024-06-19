import 'package:flutter/material.dart';
import 'package:maasapp/core/widgets/AppBar/appBar.dart';
import 'package:maasapp/core/widgets/sideBar.dart';
import 'package:maasapp/features/Lines/viewmodels/busRoutes.dart';

class LinesScreen extends StatefulWidget {
  @override
  _LinesScreenState createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
  TextEditingController _searchController = TextEditingController();
  List<String> _allLines = ['Cairo Lines'];
  List<String> _filteredLines = [];

  @override
  void initState() {
    super.initState();
    _filteredLines = _allLines;
    _searchController.addListener(_filterLines);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLines);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLines() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLines = _allLines
          .where((line) => line.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Arabni'),
      drawer: CommonSideBar(), // Use the CommonSideBar
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Line',
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
            child: _buildLinesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesList() {
    if (_filteredLines.isEmpty) {
      return Center(child: Text('No lines found'));
    }

    return ListView.builder(
      itemCount: _filteredLines.length,
      itemBuilder: (context, index) {
        final lineName = _filteredLines[index];
        return ListTile(
          title: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusRoutes(selectedLine: lineName),
                ),
              );
            },
            child: Text(lineName),
          ),
        );
      },
    );
  }
}
