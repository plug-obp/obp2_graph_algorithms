import 'dart:collection';

import 'package:obp2_graph_algorithms/src/search/search_common.dart';
import 'package:obp2_graph_algorithms/src/traversals/graph_depth_first_traversal.dart';

V? depthFirstSearch<V, M>(Iterable<V> Function() initial,
    Iterable<V> Function(V) next, VertexPredicate<V> predicate) {
  return reducedDepthFirstSearch(initial, next, identity, predicate);
}

V? reducedDepthFirstSearch<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    ReductionFunction<V, A> reduce,
    VertexPredicate<V> predicate) {
  List<V?> memory = List.filled(1, null, growable: false);
  reducedGraphDepthFirstTraversal<V, A, List<V?>>(initial, next, reduce,
      (sourceFrame, vertexFrame, memory) {
    if (predicate(vertexFrame.vertex as V)) {
      memory[0] = vertexFrame.vertex;
      return true;
    }
    return false;
  }, emptyOnKnown, emptyOnExit, memory);
  return memory[0];
}

SearchResult<V> depthFirstSearchPath<V, M>(Iterable<V> Function() initial,
    Iterable<V> Function(V) next, VertexPredicate<V> predicate) {
  return reducedDepthFirstSearchPath(initial, next, identity, predicate);
}

SearchResult<V> reducedDepthFirstSearchPath<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    ReductionFunction<V, A> reduce,
    VertexPredicate<V> predicate) {
  final Set<A> known = HashSet();
  bool addIfAbsent(V vertex, A reducedVertex) {
    return known.add(reducedVertex);
  }

  final ListQueue<Frame<V, A>> stack = ListQueue<Frame<V, A>>();
  final memory = SearchResult<V>();
  bool onEntry(Frame<V, A> sourceFrame, Frame<V, A> vertexFrame,
      SearchResult<V> memory) {
    if (vertexFrame.vertex == null) return false;
    memory.numberOfExploredVertices++;
    if (predicate(vertexFrame.vertex as V)) {
      memory.trace = stackToTrace(stack);
      memory.witness = vertexFrame.vertex;
      return true;
    }
    return false;
  }

  return datalessReducedGraphDepthFirstTraversal<V, A, SearchResult<V>>(
      initial,
      next,
      reduce,
      onEntry,
      emptyOnKnown,
      emptyOnExit,
      memory,
      addIfAbsent,
      stack);
}
