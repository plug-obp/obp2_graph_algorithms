import 'dart:collection';

import 'package:obp2_graph_algorithms/obp2_graph_algorithms.dart';

/// buchiCVWY92A2 is the algorithm 2 from [1].
/// The recursive pseudocode seems to be:
/// ```
/// dfs₁(s, k₁ = ∅, k₂ = ∅)
///     k₁ = k₁ ∪ { s }
///     for t ∈ next(s) do
///         if t ∉ k₁ then
///             dfs₁(t, k₁, k₂)
///         end if
///     end for
///     if s ∈ accepting then
///         dfs₂(s, s, k₂)
///     end if
/// dfs₂(s, seed, k₂)
///     k₂ = k₂ ∪ { s }
///     if seed ∈ next(s) then
///         report violation
///     end if
///     for t ∈ next(s) do
///         if t ∉ k₂ then
///             dfs₂ (t, k₂)
///         end if
///     end for
/// ```
/// [1] Courcoubetis, Costas, Moshe Vardi, Pierre Wolper, and Mihalis Yannakakis.
/// "Memory-efficient algorithms for the verification of temporal properties."
/// Formal methods in system design 1, no. 2 (1992): 275-288.
///
BuchiSearchResult<V> buchiCVWY92A2<V, A>(
  Iterable<V> Function() initial,
  Iterable<V> Function(V) next,
  VertexPredicate<V> acceptingPredicate,
) {
  return buchiReducedCVWY92A2(initial, next, acceptingPredicate, identity);
}

///buchiReducedCVWY92A2 is a version of the buchiCVWY92A2 which allows a reduction function
///the first DFS checks the accepting predicate in postorder (on_exit)
BuchiSearchResult<V> buchiReducedCVWY92A2<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    VertexPredicate<V> acceptingPredicate,
    ReductionFunction<V, A> reduce) {
  final Set<A> known = HashSet();
  bool addIfAbsent(V vertex, A reducedVertex) {
    return known.add(reducedVertex);
  }

  final ListQueue<Frame<V, A>> stack = ListQueue<Frame<V, A>>();

  bool onEntry(Frame<V, A> sourceFrame, Frame<V, A> vertexFrame,
      BuchiSearchResult<V> memory) {
    if (vertexFrame.vertex == null) return false;
    memory.numberOfExploredVertices++;
    return false;
  }

  bool onExit(_, Frame<V, A> vertexFrame, BuchiSearchResult<V> memory) {
    if (!acceptingPredicate(vertexFrame.vertex as V)) return false;
    //the second DFS checks the accepting predicate in preorder (on_entry)
    var cycleSearchResult = reducedDepthFirstSearchPath(
        () => [vertexFrame.vertex as V],
        next,
        reduce,
        (v) => next(v).contains(vertexFrame.vertex));
    if (!cycleSearchResult.hasTrace) return false;

    //set the prefix
    memory.trace = stackToTrace(stack);

    //set the witness
    memory.witness = vertexFrame.vertex;

    //set the suffix
    memory.suffix = cycleSearchResult.trace;
    memory.numberOfExploredVertices +=
        cycleSearchResult.numberOfExploredVertices;
    return true;
  }

  return datalessReducedGraphDepthFirstTraversal<V, A, BuchiSearchResult<V>>(
      initial,
      next,
      reduce,
      onEntry,
      emptyOnKnown,
      onExit,
      BuchiSearchResult<V>([], [], null, 0),
      addIfAbsent,
      stack);
}
