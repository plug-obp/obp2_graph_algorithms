import 'package:obp2_graph_algorithms/obp2_graph_algorithms.dart';

void main() {
  var awesome =
      depthFirstSearch(() => [0], (v) => [(v + 1) % 5], (v) => v == 3);
  print('found: $awesome');
  var result =
      depthFirstSearchPath(() => [1, 5], (v) => [(v + 1) % 5], (v) => v == 0);
  print('witness: ${result.witness}, path: ${result.trace}');
}
