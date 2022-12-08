import 'package:obp2_graph_algorithms/src/search/depth_first_search.dart';
import 'package:obp2_graph_algorithms/src/traversals/graph_depth_first_traversal.dart';
import 'package:test/test.dart';

void main() {
  final graph = {
    0: [1, 3],
    1: [2],
    2: [0],
    3: [4],
    4: [2]
  };
  ini() => [0];
  next(v) => graph[v]!;

  final Map<int, List<int>> dag = {
    0: [1, 2],
    1: [3],
    2: [3],
    3: []
  };

  final Map<int, List<int>> tree = {
    0: [1, 2],
    1: [3],
    2: [4],
    3: [],
    4: []
  };

  group('dfs traversal and order', () {
    test('dfs graph preorder', () {
      List<int> order = graphDepthFirstTraversal(ini, next, (s, v, m) {
        m.add(v);
        return false;
      }, (s, v, m) => false, (v, m) => false, []);

      expect(order, equals([0, 1, 2, 3, 4]));
    });

    test('dfs graph postorder', () {
      List<int> order = graphDepthFirstTraversal(
          ini, next, (s, v, m) => false, (s, v, m) => false, (v, m) {
        m.add(v);
        return false;
      }, []);

      expect(order, equals([2, 1, 4, 3, 0]));
    });

    test('dfs graph known', () {
      List<int> known =
          graphDepthFirstTraversal(ini, next, (s, v, m) => false, (s, v, m) {
        m.add(v);
        return false;
      }, (v, m) => false, []);

      expect(known, equals([0, 2]));
    });

    test('dfs dag known', () {
      List<int> known = graphDepthFirstTraversal(
          () => [0], (v) => dag[v]!, (s, v, m) => false, (s, v, m) {
        m.add(v);
        return false;
      }, (v, m) => false, []);

      expect(known, equals([3]));
    });

    test('dfs tree known', () {
      List<int> known = graphDepthFirstTraversal(
          () => [0], (v) => tree[v]!, (s, v, m) => false, (s, v, m) {
        m.add(v);
        return false;
      }, (v, m) => false, []);

      expect(known, equals([]));
    });
  });

  group('reduced traversal', () {
    test('dfs n++', () {
      var count = reducedGraphDepthFirstTraversal(
          () => [0],
          (v) => [v + 1, v + 2],
          (v) => v.hashCode % 1000,
          (sf, vf, m) => m[0]++ < 0,
          emptyOnKnown,
          emptyOnExit,
          [0]);
      expect(count[0], lessThanOrEqualTo(1000));
    });
  });

  group('dfs search', () {
    test('dfs search missing', () {
      var node = depthFirstSearch(ini, next, (v) => v == 42);
      expect(node, isNull);
    });
    test('dfs search 0', () {
      var node = depthFirstSearch(ini, next, (v) => v == 0);
      expect(node, equals(0));
    });

    test('dfs search 1', () {
      var node = depthFirstSearch(ini, next, (v) => v == 1);
      expect(node, equals(1));
    });
    test('dfs search 2', () {
      var node = depthFirstSearch(ini, next, (v) => v == 2);
      expect(node, equals(2));
    });
    test('dfs search 3', () {
      var node = depthFirstSearch(ini, next, (v) => v == 3);
      expect(node, equals(3));
    });
    test('dfs search 4', () {
      var node = depthFirstSearch(ini, next, (v) => v == 4);
      expect(node, equals(4));
    });
  });

  group('dfs search path', () {
    test('dfs search missing', () {
      var res = depthFirstSearchPath(ini, next, (v) => v == 42);
      expect(res.hasTrace, false);
    });
    test('dfs search 0', () {
      var res = depthFirstSearchPath(ini, next, (v) => v == 0);
      expect(res.hasTrace, true);
      expect(res.trace.length, equals(1));
      expect(res.numberOfExploredVertices, equals(1));
    });

    test('dfs search path 1', () {
      var res = depthFirstSearchPath(ini, next, (v) => v == 1);
      expect(res.hasTrace, true);
      expect(res.trace.length, equals(2));
      expect(res.numberOfExploredVertices, equals(2));
    });
    test('dfs search path 2', () {
      var res = depthFirstSearchPath(ini, next, (v) => v == 2);
      expect(res.hasTrace, true);
      expect(res.trace.length, equals(3));
      expect(res.numberOfExploredVertices, equals(3));
    });
    test('dfs search path 3', () {
      var res = depthFirstSearchPath(ini, next, (v) => v == 3);
      expect(res.hasTrace, true);
      expect(res.trace.length, equals(2));
      expect(res.numberOfExploredVertices, equals(4));
    });
    test('dfs search path 4', () {
      var res = depthFirstSearchPath(ini, next, (v) => v == 4);
      expect(res.hasTrace, true);
      expect(res.trace.length, equals(3));
      expect(res.numberOfExploredVertices, equals(5));
    });
  });
}
