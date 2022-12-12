import 'dart:collection';

V identity<V>(V) {
  return V;
}

bool emptyOnEntry<V, A, M>(
    Frame<V, A> sourceFrame, Frame<V, A> vertexFrame, M memory) {
  return false;
}

bool emptyOnKnown<V, A, M>(
    Frame<V, A> sourceFrame, V vertex, A reducedVertex, M memory) {
  return false;
}

bool emptyOnExit<V, A, M>(
    Frame<V, A> sourceFrame, Frame<V, A> vertexFrame, M memory) {
  return false;
}

M graphPreorderDepthFirstTraversal<V, M>(
  Iterable<V> Function() initial,
  Iterable<V> Function(V) next,
  bool Function(V? source, V vertex, M memory) onEntry,
  M memory,
) {
  return graphDepthFirstTraversal(
      initial, next, onEntry, (s, v, m) => false, (v, m) => false, memory);
}

M graphDepthFirstTraversal<V, M>(
  Iterable<V> Function() initial,
  Iterable<V> Function(V) next,
  bool Function(V? source, V vertex, M memory) onEntry,
  bool Function(V? source, V vertex, M memory) onKnown,
  bool Function(V vertex, M memory) onExit,
  M memory,
) {
  return reducedGraphDepthFirstTraversal(
      initial,
      next,
      identity,
      (sf, vf, m) => onEntry(sf.vertex, vf.vertex as V, m),
      (f, v, rv, m) => onKnown(f.vertex, v, m),
      (sf, vf, m) => onExit(vf.vertex as V, m),
      memory);
}

typedef ReductionFunction<V, A> = A Function(V);
typedef ReducedOnEntryFunction<V, A, M> = bool Function(
    Frame<V, A> sourceFrame, Frame<V, A> vertexFrame, M memory);

typedef ReducedOnKnownFunction<V, A, M> = bool Function(
    Frame<V, A> sourceFrame, V vertex, A reducedVertex, M memory);

typedef ReducedOnExitFunction<V, A, M> = bool Function(
    Frame<V, A> sourceFrame, Frame<V, A> vertexFrame, M memory);

M reducedGraphDepthFirstTraversal<V, A, M>(
  Iterable<V> Function() initial,
  Iterable<V> Function(V) next,
  ReductionFunction<V, A> reduce,
  ReducedOnEntryFunction<V, A, M> onEntry,
  ReducedOnKnownFunction<V, A, M> onKnown,
  ReducedOnExitFunction<V, A, M> onExit,
  M memory,
) {
  final known = HashSet<A>();
  final stack = ListQueue<Frame<V, A>>();

  bool addIfAbsent(V vertex, A reducedVertex) {
    return known.add(reducedVertex);
  }

  return datalessReducedGraphDepthFirstTraversal(initial, next, reduce, onEntry,
      onKnown, onExit, memory, addIfAbsent, stack);
}

M datalessReducedGraphDepthFirstTraversal<V, A, M>(
  Iterable<V> Function() initial,
  Iterable<V> Function(V) next,
  ReductionFunction<V, A> reduce,
  ReducedOnEntryFunction<V, A, M> onEntry,
  ReducedOnKnownFunction<V, A, M> onKnown,
  ReducedOnExitFunction<V, A, M> onExit,
  M memory,
  bool Function(V vertex, A reducedVertex) addIfAbsent,
  Queue<Frame<V, A>> stack,
) {
  stack.addLast(Frame.initial(initial().iterator));
  while (stack.isNotEmpty) {
    Frame<V, A> sourceFrame = stack.last;

    if (sourceFrame.neighbours.moveNext()) {
      var neighbour = sourceFrame.neighbours.current;
      var reducedNeighbour = reduce(neighbour);

      if (addIfAbsent(neighbour, reducedNeighbour)) {
        Frame<V, A> vertexFrame =
            Frame(neighbour, reducedNeighbour, next(neighbour).iterator);
        stack.addLast(vertexFrame);
        var terminate = onEntry(sourceFrame, vertexFrame, memory);
        if (terminate) return memory;
        continue;
      }
      var terminate = onKnown(sourceFrame, neighbour, reducedNeighbour, memory);
      if (terminate) return memory;
      continue;
    }
    var vertexFrame = stack.removeLast();
    //vertexFrame.vertex is null only for the 'invisible' pseudo-root, we do not call any callbacks on it.
    if (vertexFrame.vertex == null) continue;
    var terminate = onExit(stack.last, vertexFrame, memory);
    if (terminate) return memory;
  }
  return memory;
}

class Frame<V, A> {
  V? vertex;
  A? reducedVertex;
  Iterator<V> neighbours;
  dynamic payload;

  Frame.initial(this.neighbours);
  Frame(this.vertex, this.reducedVertex, this.neighbours);

  set setPayload(load) => payload = load;
}
