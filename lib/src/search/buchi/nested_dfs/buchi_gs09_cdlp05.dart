import 'dart:collection';

import 'package:obp2_graph_algorithms/obp2_graph_algorithms.dart';

/// The improved nested DFS algorithm from [1], Figure 1 with the optimization from [2] (Sec. 4.2).
/// The number of accepting states accumulated from the source to the current node is associated with all nodes on the stack.
/// This way dfs blue can detect all recursive loops with accepting states.
/// Dfs red is used only to analyze cross(sharing) links.
/// [1] Gaiser, Andreas, and Stefan Schwoon.
/// "Comparison of algorithms for checking emptiness on Büchi automata."
/// arXiv preprint arXiv:0910.3766 (2009).
/// https://arxiv.org/pdf/0910.3766.pdf
///
/// [2] Couvreur, Jean-Michel, Alexandre Duret-Lutz, and Denis Poitrenaud.
/// "On-the-fly emptiness checks for generalized Büchi automata."
/// In International SPIN Workshop on Model Checking of Software,
/// pp. 169-184. Springer, Berlin, Heidelberg, 2005.
///

BuchiSearchResult<V> buchiGS09CDLP05<V>(
  Iterable<V> Function() initial,
  Iterable<V> Function(V) next,
  VertexPredicate<V> acceptingPredicate,
) {
  return buchiReducedGS09CDLP05(initial, next, acceptingPredicate, identity);
}

///TODO: diagnosis trace should be interpreted better. to clearly separate prefix from cyclic suffix

///buchiReducedGS09CDLP05 is a version of the buchiGS09CDLP05 which allows a reduction function
///we need a map to store the colors
/// - configuration is white ⟺ never touched by dfs_blue
/// - configuration is cyan ⟺ if its invocation of dfs_blue is still running (in on the stack_blue) and every cyan
/// config can reach s, for the currently active instance of dfs_blue(s)
/// - configuration is blue ⟺ it is non-accepting and its invocation of dfs_blue has terminated (it was popped from the stack_blue)
/// - configuration is red ⟺ its invocation of dfs_blue has terminated (is was popped from the stack_blue, and is not part of any counterexample)
/// possible transitions: (white ⟶ cyan), (cyan ⟶ blue), (blue ⟶ red), (cyan ⟶ red)
BuchiSearchResult<V> buchiReducedGS09CDLP05<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    VertexPredicate<V> acceptingPredicate,
    ReductionFunction<V, A> reduce) {
  final known = HashMap<A, _VertexData>();
  final stackBlue = ListQueue<Frame<V, A>>();
  final stackRed = ListQueue<Frame<V, A>>();
  return _dfsBlue(
      initial, next, acceptingPredicate, reduce, known, stackBlue, stackRed);
}

enum _Color { cyan, red, blue }

class _VertexData {
  _VertexData(this.color, this.weight);
  _Color color;
  int weight;
}

BuchiSearchResult<V> _dfsBlue<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    VertexPredicate<V> acceptingPredicate,
    ReductionFunction<V, A> reduce,
    Map<A, _VertexData> known,
    ListQueue<Frame<V, A>> stackBlue,
    ListQueue<Frame<V, A>> stackRed) {
  onKnown(sF, v, rv, m) =>
      _onKnownBlue<V, A>(known, acceptingPredicate, stackBlue, sF, v, rv, m);
  onExit(sF, vF, m) => _onExitBlue<V, A>(
      next, acceptingPredicate, known, stackBlue, stackRed, reduce, sF, vF, m);
  Memory<V> mem = Memory(BuchiSearchResult([], [], null, 0), 0);
  var r = datalessReducedGraphDepthFirstTraversal<V, A, Memory<V>>(
      initial,
      next,
      reduce,
      _onEntryBlue,
      onKnown,
      onExit,
      mem,
      (v, rv) => _addIfAbsentBlue(known, v, rv, mem, acceptingPredicate),
      stackBlue);
  return r.result;
}

bool _addIfAbsentBlue<V, A>(
    Map<A, _VertexData> known, V v, A rv, Memory<V> m, pred) {
  if (known.containsKey(rv)) return false;
  m.weight += pred(v) ? 1 : 0;
  known[rv] = _VertexData(_Color.cyan, m.weight);
  return true;
}

bool _onEntryBlue<V, A>(sF, Frame<V, A> vF, Memory<V> m) {
  //add an allRed field to the current frame
  //the payload variable stored the allRed flag
  vF.payload = true;
  m.result.numberOfExploredVertices++;
  return false;
}

bool _hasLoop<V>(
    isAccepting, V s, _VertexData? sourceData, V v, _VertexData vertexData) {
  // if n is not on the stack continue;
  if (vertexData.color != _Color.cyan) return false;
  //the sourceData == null only for the pseudo-root
  if (sourceData == null) return false;
  //n is on the stack, check if there is an accepting state between s and n
  if (sourceData.weight - vertexData.weight != 0 ||
      isAccepting(s) ||
      isAccepting(v)) {
    return true;
  }
  return false;
}

bool _onKnownBlue<V, A>(Map<A, _VertexData> known, isAccepting,
    Queue<Frame<V, A>> stack, Frame<V, A> sF, V v, A rv, Memory<V> m) {
  //rv is necessarily in the known, we are in the onKnown callback
  final vertexData = known[rv]!;
  //sF.reducedVertex might not be in the known, for the pseudo-root
  final sourceData = known[sF.reducedVertex];
  if (_hasLoop(isAccepting, sF.vertex, sourceData, v, vertexData)) {
    m.result.trace = stackToTrace(stack);
    //TODO: the witness v is not necessarily an accepting state,
    //for this algorithm it is only a state in the loop
    m.result.witness = v;
    return true;
  }

  //if (n) is not red,
  //the tell its parent (sF.vertex) it has at least one non red child
  if (vertexData.color != _Color.red) {
    sF.payload = false;
  }
  return false;
}

bool _onExitBlue<V, A>(next, acceptingPredicate, Map<A, _VertexData> known,
    stackBlue, stackRed, reduce, Frame<V, A> sF, Frame<V, A> vF, Memory<V> m) {
  m.weight -= acceptingPredicate(vF.vertex!) ? 1 : 0;
  //if all my children are red, make myself red
  if (vF.payload) {
    known[vF.reducedVertex]!.color = _Color.red;
    return false;
  }
  //if v is an accepting state dfs_red
  if (acceptingPredicate(vF.vertex!)) {
    final result =
        _dfsRed<V, A>(() => next(vF.vertex), next, reduce, known, stackRed);
    if (!result.hasTrace) {
      known[vF.reducedVertex]!.color = _Color.red;
      return false;
    }
    //I found a counter-example
    m.result.trace = stackToTrace(stackBlue);
    m.result.suffix =
        [vF.vertex as V] + result.trace.toList() + [result.witness as V];
    m.result.witness = vF.vertex;
    m.result.numberOfExploredVertices += result.numberOfExploredVertices;
    return true;
  }
  known[vF.reducedVertex]!.color = _Color.blue;
  //if i'm not red, tell my parent that i'm not
  //The parent allRed flag is false, which is encoded in the payload field of the parent frame
  sF.payload = false;
  return false;
}

bool _addIfAbsentRed<V, A>(Map<A, _VertexData> known, V v, A rv) {
  _VertexData? entry = known[rv];
  if (entry == null || entry.color != _Color.blue) return false;
  entry.color = _Color.red;
  return true;
}

SearchResult<V> _dfsRed<V, A>(
    Iterable<V> Function() initial,
    Iterable<V> Function(V) next,
    ReductionFunction<V, A> reduce,
    Map<A, _VertexData> known,
    Queue<Frame<V, A>> stack) {
  onKnown(Frame<V, A> sF, V v, A rv, m) {
    _VertexData? entry = known[rv];
    if (entry == null || entry.color != _Color.cyan) return false;
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

class Memory<V> {
  BuchiSearchResult<V> result;
  int weight; // the number of accepting states from the source to the top of the stack

  Memory(this.result, this.weight);
}
