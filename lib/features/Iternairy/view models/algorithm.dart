// graph.dart
/*class Stop {
  final String name;
  final List<Route> routes;
  
  Stop(this.name) : routes = [];
}

class Route {
  final Stop destination;
  final int travelTime; // You can also use distance or cost

  Route(this.destination, this.travelTime);
}

// Create a graph of stops and routes
Map<String, Stop> stops = {
  "Abbasiya": Stop("Abbasiya"),
  "Al-TeseenStreet": Stop("Al-TeseenStreet"),
  // Add more stops as needed...
};

// Add routes between stops
void setupRoutes() {
  stops["Abbasiya"]?.routes.add(Route(stops["Al-TeseenStreet"]!, 15));
  // Add more routes as needed...
}

List<Stop> dijkstra(Stop start, Stop goal) {
  Map<Stop, int> distances = {};
  Map<Stop, Stop?> previous = {};
  Set<Stop> visited = {};

  // Initialize distances and previous nodes
  for (var stop in stops.values) {
   distances[stop] = int.maxFinite;
    previous[stop] = null;
  }
  distances[start] = 0;

  while (true) {
    Stop current = _getClosestUnvisited(distances, visited);
    if (current == goal || distances[current] == double.infinity.toInt()) {
      break;
    }
    visited.add(current);

    for (var route in current.routes) {
      int alt = distances[current]! + route.travelTime;
      if (alt < distances[route.destination]!) {
        distances[route.destination] = alt;
        previous[route.destination] = current;
      }
    }
  }

  return _buildPath(previous, start, goal);
}

Stop _getClosestUnvisited(Map<Stop, int> distances, Set<Stop> visited) {
  Stop? closest;
  int minDistance = double.infinity.toInt();

  for (var entry in distances.entries) {
    if (!visited.contains(entry.key) && entry.value! < minDistance) {
      closest = entry.key;
      minDistance = entry.value!;
    }
  }

  return closest!;
}

List<Stop> _buildPath(Map<Stop, Stop?> previous, Stop start, Stop goal) {
  List<Stop> path = [];
  Stop? current = goal;

  while (current != null) {
    path.add(current);
    current = previous[current];
  }

  path = path.reversed.toList();
  return path[0] == start ? path : [];
}

*/
