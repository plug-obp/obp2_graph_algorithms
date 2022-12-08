import 'dart:collection';

import 'package:obp2_graph_algorithms/obp2_graph_algorithms.dart';

///
/// The improved nested DFS algorithm from [1], Figure 1.
/// [1] Gaiser, Andreas, and Stefan Schwoon.
/// "Comparison of algorithms for checking emptiness on Büchi automata."
/// arXiv preprint arXiv:0910.3766 (2009).
/// https://arxiv.org/pdf/0910.3766.pdf
///
/// the pseudocode:
/// ```
/// dfs₁(s, k = ∅)
///     k = k ∪ { s→cyan }
///     allRed = true
///     for t ∈ next(s) do
///         t.color = k @ t
///         if t.color = cyan ∧ (s ∈ A ∨ t ∈ A) then
///             report cycle
///         end if
///         if t ∉ k then
///             dfs₁(t, k)
///         end if
///         if t.color ≠ red then
///             allRed = false
///         end if
///     end for
///     if allRed then
///         k = k ∪ { s→red}
///     else if s ∈ A then
///         dfs₂(s, k)
///         k = k ∪ { s→red}
///     else
///         k = k ∪ { s→blue}
///     end if
/// dfs₂(s, k)
///     for t ∈ next(s) do
///         t.color = k @ t
///         if t.color = cyan then
///             report cycle
///         if t.color = blue then
///             k = k ∪ { t→red}
///             dfs₂ (t, k)
///         end if
///     end for
/// ```

BuchiSearchResult<V> buchiGS09<V>(
  Iterable<V> Function() initial,
  Iterable<V> Function(V) next,
  VertexPredicate<V> acceptingPredicate,
) {
  return buchiReducedGS09(initial, next, acceptingPredicate, identity);
}

///TODO: diagnosis trace should be interpreted better. to clearly separate prefix from cyclic suffix

///buchiReducedGS09 is a version of the buchiGS09 which allows a reduction function
BuchiSearchResult<V> buchiReducedGS09<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    VertexPredicate<V> acceptingPredicate,
    ReductionFunction<V, A> reduce) {
  final known = HashMap<A, _Color>();
  final stackBlue = ListQueue<Frame<V, A>>();
  final stackRed = ListQueue<Frame<V, A>>();
  return _dfsBlue(
      initial, next, acceptingPredicate, reduce, known, stackBlue, stackRed);
}

enum _Color { cyan, red, blue }

BuchiSearchResult<V> _dfsBlue<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    VertexPredicate<V> acceptingPredicate,
    ReductionFunction<V, A> reduce,
    Map<A, _Color> known,
    ListQueue<Frame<V, A>> stackBlue,
    ListQueue<Frame<V, A>> stackRed) {
  onKnown(sF, v, rv, m) =>
      _onKnownBlue<V, A>(known, acceptingPredicate, stackBlue, sF, v, rv, m);
  onExit(sF, vF, m) => _onExitBlue<V, A>(
      next, acceptingPredicate, known, stackBlue, stackRed, reduce, sF, vF, m);

  return datalessReducedGraphDepthFirstTraversal(
      initial,
      next,
      reduce,
      _onEntryBlue,
      onKnown,
      onExit,
      BuchiSearchResult([], [], null, 0),
      (v, rv) => _addIfAbsentBlue(known, v, rv),
      stackBlue);
}

bool _addIfAbsentBlue(Map known, v, rv) {
  if (known.containsKey(rv)) return false;
  known[rv] = _Color.cyan;
  return true;
}

bool _onEntryBlue<V, A>(sF, Frame<V, A> vF, SearchResult<V> m) {
  //add an allRed field to the current frame
  //the payload variable stored the allRed flag
  vF.payload = true;
  m.numberOfExploredVertices++;
  return false;
}

bool _onKnownBlue<V, A>(
    Map<A, _Color> known,
    isAccepting,
    Queue<Frame<V, A>> stack,
    Frame<V, A> sF,
    V v,
    A rv,
    BuchiSearchResult<V> m) {
  final sIsA = isAccepting(sF.vertex);
  final vIsA = isAccepting(v);
  if (known[rv] == _Color.cyan && (sIsA || vIsA)) {
    m.witness = vIsA ? v : sF.vertex;
    m.trace = stackToTrace<V, A>(stack);
    return true;
  }

  //if (n) is not red,
  //the tell its parent (sF.vertex) it has at least one non red child
  if (known[rv] != _Color.red) {
    sF.payload = false;
  }
  return false;
}

bool _onExitBlue<V, A>(next, acceptingPredicate, known, stackBlue, stackRed,
    reduce, Frame<V, A> sF, Frame<V, A> vF, BuchiSearchResult<V> m) {
  //if all my children are red, make myself red
  if (vF.payload) {
    known[vF.reducedVertex] = _Color.red;
    return false;
  }
  //if v is an accepting state dfs_red
  if (acceptingPredicate(vF.vertex)) {
    final result =
        _dfsRed<V, A>(() => next(vF.vertex), next, reduce, known, stackRed);
    if (!result.hasTrace) {
      known[vF.reducedVertex] = _Color.red;
      return false;
    }
    //I found a counter-example
    m.trace = stackToTrace(stackBlue);
    m.suffix = [vF.vertex as V] + result.trace.toList() + [result.witness as V];
    m.witness = vF.vertex;
    m.numberOfExploredVertices += result.numberOfExploredVertices;
    return true;
  }
  known[vF.reducedVertex] = _Color.blue;
  //if i'm not red, tell my parent that i'm not
  //The parent allRed flag is false, which is encoded in the payload field of the parent frame
  sF.payload = false;
  return false;
}

bool _addIfAbsentRed<V, A>(Map<A, _Color> known, V v, A rv) {
  if (known[rv] != _Color.blue) return false;
  known[rv] = _Color.red;
  return true;
}

SearchResult<V> _dfsRed<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    ReductionFunction<V, A> reduce,
    known,
    Queue<Frame<V, A>> stack) {
  onKnown(Frame<V, A> sF, V v, A rv, m) {
    if (known[rv] != _Color.cyan) return false;
    m.trace = stackToTrace(stack);
    m.witness = v;
    return true;
  }

  return datalessReducedGraphDepthFirstTraversal(
      initial,
      next,
      reduce,
      countingOnEntry,
      onKnown,
      emptyOnExit,
      SearchResult<V>(),
      (v, rv) => _addIfAbsentRed(known, v, rv),
      stack);
}
