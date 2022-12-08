import 'dart:collection';

import 'package:obp2_graph_algorithms/obp2_graph_algorithms.dart';

typedef VertexPredicate<V> = bool Function(V);

class SearchResult<V> {
  Iterable<V> trace = [];
  int numberOfExploredVertices = 0;
  V? witness;

  bool get hasTrace => trace.isNotEmpty;
}

bool countingOnEntry<V, A>(Frame<V, A> sF, Frame<V, A> vF, SearchResult<V> m) {
  m.numberOfExploredVertices++;
  return false;
}

class BuchiSearchResult<V> extends SearchResult<V> {
  BuchiSearchResult(Iterable<V> prefix, this.suffix, V? witness,
      int numberOfExploredVertices) {
    super.trace = prefix;
    super.witness = witness;
    super.numberOfExploredVertices = numberOfExploredVertices;
  }
  Iterable<V> suffix;
  Iterable<V> get prefix => trace;
  @override
  bool get hasTrace => super.hasTrace || suffix.isNotEmpty;
}

Iterable<V> stackToTrace<V, A>(Queue<Frame<V, A>> stack) {
  return (stack
      .where((element) => element.vertex != null) //removes the empty root
      .map((Frame<V, A> e) => e.vertex!));
}
