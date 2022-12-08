import 'package:obp2_graph_algorithms/obp2_graph_algorithms.dart';

import 'package:test/test.dart';

void main() {
  final Map<int, List<int>> graph = {
    0: [1, 3],
    1: [2],
    2: [0],
    3: [4],
    4: [2, 5],
    5: []
  };
  ini() => [0];
  next(v) => graph[v]!;

  group('naive buchi acceptance cycle', () {
    naive(int n) {
      return buchiNaive(ini, next, (v) => v == n);
    }

    test('no accepting', () {
      var res = buchiNaive(
        ini,
        next,
        (v) => false,
      );
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting not reachable', () {
      var res = naive(42);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 0', () {
      var res = naive(0);
      expect(res.hasTrace, true);
      expect(res.prefix, [0]);
      expect(res.suffix, [1, 2, 0]);
      expect(res.numberOfExploredVertices, equals(4));
      expect(res.witness, 0);
    });

    test('accepting 1', () {
      var res = naive(1);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1]);
      expect(res.suffix, [2, 0, 1]);
      expect(res.numberOfExploredVertices, equals(5));
      expect(res.witness, 1);
    });

    test('accepting 2', () {
      var res = naive(2);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1, 2]);
      expect(res.suffix, [0, 1, 2]);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, 2);
    });

    test('accepting 3', () {
      var res = naive(3);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3]);
      expect(res.suffix, [4, 2, 0, 3]);
      expect(res.numberOfExploredVertices, equals(9));
      expect(res.witness, 3);
    });
    test('accepting 4', () {
      var res = naive(4);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3, 4]);
      expect(res.suffix, [2, 0, 3, 4]);
      expect(res.numberOfExploredVertices, equals(10));
      expect(res.witness, 4);
    });

    test('accepting 5', () {
      var res = naive(5);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 5 self-loop', () {
      var graph1 = Map.from(graph);
      graph1[5] = [5];
      var res = buchiNaive(ini, (v) => graph1[v]!, (v) => v == 5);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3, 4, 5]);
      expect(res.suffix, [5]);
      expect(res.numberOfExploredVertices, equals(7));
      expect(res.witness, 5);
    });
  });

  group("GS09 buchi acceptance cycle", () {
    emptinessCheck(int n) {
      return buchiGS09(ini, next, (v) => v == n);
    }

    test('no accepting', () {
      var res = buchiGS09(
        ini,
        next,
        (v) => false,
      );
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting not reachable', () {
      var res = emptinessCheck(42);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 0', () {
      var res = emptinessCheck(0);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1, 2]);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(3));
      expect(res.witness, 0);
    });

    test('accepting 1', () {
      var res = emptinessCheck(1);
      expect(res.hasTrace, true);
      expect(res.prefix, [0]);
      expect(res.suffix, [1, 2, 0]);
      expect(res.numberOfExploredVertices, equals(4));
      expect(res.witness, 1);
    });

    test('accepting 2', () {
      var res = emptinessCheck(2);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1, 2]);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(3));
      expect(res.witness, 2);
    });

    test('accepting 3', () {
      var res = emptinessCheck(3);
      expect(res.hasTrace, true);
      expect(res.prefix, [0]);
      expect(res.suffix, [3, 4, 2, 0]);
      expect(res.numberOfExploredVertices, equals(8));
      expect(res.witness, 3);
    });
    test('accepting 4', () {
      var res = emptinessCheck(4);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3]);
      expect(res.suffix, [4, 2, 0]);
      expect(res.numberOfExploredVertices, equals(7));
      expect(res.witness, 4);
    });

    test('accepting 5', () {
      var res = emptinessCheck(5);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 5 self-loop', () {
      var graph1 = Map.from(graph);
      graph1[5] = [5];
      var res = buchiGS09(ini, (v) => graph1[v]!, (v) => v == 5);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3, 4, 5]);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, 5);
    });
  });

  group("GS09CLDP05 buchi acceptance cycle", () {
    emptinessCheck(int n) {
      return buchiGS09CDLP05(ini, next, (v) => v == n);
    }

    test('no accepting', () {
      var res = buchiGS09CDLP05(
        ini,
        next,
        (v) => false,
      );
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting not reachable', () {
      var res = emptinessCheck(42);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 0', () {
      var res = emptinessCheck(0);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1, 2]);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(3));
      expect(res.witness, 0);
    });

    test('accepting 1', () {
      var res = emptinessCheck(1);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1, 2]);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(3));
      expect(res.witness, 0);
    });

    test('accepting 2', () {
      var res = emptinessCheck(2);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1, 2]);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(3));
      expect(res.witness, 0);
    });

    test('accepting 3', () {
      var res = emptinessCheck(3);
      expect(res.hasTrace, true);
      expect(res.prefix, [0]);
      expect(res.suffix, [3, 4, 2, 0]);
      expect(res.numberOfExploredVertices, equals(8));
      expect(res.witness, 3);
    });
    test('accepting 4', () {
      var res = emptinessCheck(4);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3]);
      expect(res.suffix, [4, 2, 0]);
      expect(res.numberOfExploredVertices, equals(7));
      expect(res.witness, 4);
    });

    test('accepting 5', () {
      var res = emptinessCheck(5);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 5 self-loop', () {
      var graph1 = Map.from(graph);
      graph1[5] = [5];
      var res = buchiGS09CDLP05(ini, (v) => graph1[v]!, (v) => v == 5);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3, 4, 5]);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, 5);
    });
  });

  group("CVWY'92 A2 buchi acceptance cycle", () {
    cvwy92(int n) {
      return buchiCVWY92A2(ini, next, (v) => v == n);
    }

    test('no accepting', () {
      var res = buchiCVWY92A2(
        ini,
        next,
        (v) => false,
      );
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting not reachable', () {
      var res = cvwy92(42);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 0', () {
      var res = cvwy92(0);
      expect(res.hasTrace, true);
      expect(res.prefix, []);
      expect(res.suffix, [0, 1, 2]);
      expect(res.numberOfExploredVertices, equals(9));
      expect(res.witness, 0);
    });

    test('accepting 1', () {
      var res = cvwy92(1);
      expect(res.hasTrace, true);
      expect(res.prefix, [0]);
      expect(res.suffix, [1, 2, 0]);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, 1);
    });

    test('accepting 2', () {
      var res = cvwy92(2);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 1]);
      expect(res.suffix, [2, 0, 1]);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, 2);
    });

    test('accepting 3', () {
      var res = cvwy92(3);
      expect(res.hasTrace, true);
      expect(res.prefix, [0]);
      expect(res.suffix, [3, 4, 2, 0]);
      expect(res.numberOfExploredVertices, equals(10));
      expect(res.witness, 3);
    });
    test('accepting 4', () {
      var res = cvwy92(4);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3]);
      expect(res.suffix, [4, 2, 0, 3]);
      expect(res.numberOfExploredVertices, equals(11));
      expect(res.witness, 4);
    });

    test('accepting 5', () {
      var res = cvwy92(5);
      expect(res.hasTrace, false);
      expect(res.prefix, []);
      expect(res.suffix, []);
      expect(res.numberOfExploredVertices, equals(6));
      expect(res.witness, null);
    });

    test('accepting 5 self-loop', () {
      var graph1 = Map.from(graph);
      graph1[5] = [5];
      var res = buchiCVWY92A2(ini, (v) => graph1[v]!, (v) => v == 5);
      expect(res.hasTrace, true);
      expect(res.prefix, [0, 3, 4]);
      expect(res.suffix, [5]);
      expect(res.numberOfExploredVertices, equals(7));
      expect(res.witness, 5);
    });
  });
}
