import 'package:obp2_graph_algorithms/src/search/depth_first_search.dart';
import 'package:obp2_graph_algorithms/src/search/search_common.dart';
import 'package:obp2_graph_algorithms/src/traversals/graph_depth_first_traversal.dart';

BuchiSearchResult<V> buchiNaive<V, A>(Iterable<V> Function() initial,
    Iterable<V> Function(V) next, VertexPredicate<V> acceptingPredicate) {
  return buchiReducedNaive(initial, next, acceptingPredicate, identity);
}

BuchiSearchResult<V> buchiReducedNaive<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    VertexPredicate<V> acceptingPredicate,
    ReductionFunction<V, A> reduce) {
  var suffix = SearchResult<V>();

  bool acceptanceCyclePredicate(V vertex) {
    if (!acceptingPredicate(vertex)) return false;
    predicate(v) => v == vertex;
    suffix = reducedDepthFirstSearchPath(
        () => next(vertex), next, reduce, predicate);
    return suffix.hasTrace;
  }

  final prefix = reducedDepthFirstSearchPath(
      initial, next, reduce, acceptanceCyclePredicate);
  return BuchiSearchResult(prefix.trace, suffix.trace, suffix.witness,
      prefix.numberOfExploredVertices + suffix.numberOfExploredVertices);
}
