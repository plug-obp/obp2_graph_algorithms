<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# A collection of graph algorithms in Dart

## Features

- Generic depth-first traversal
- Depth-first search (DFS)
- Depth-first search path : returns a path from one of the sources to the target vertex
- Acceptance cycle detection in Büchi automata
  - A naive nested DFS
  - CVWY92 [1]: CVWY92 is the algorithm 2 from [1].
  - GS09 [2]: The improved nested DFS algorithm from [2], Figure 1.
  - GS09_CDLP05: The improved nested DFS algorithm from [2], Figure 1 with the optimization from [3] (Sec. 4.2).

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.

## References

1. Courcoubetis, Costas, Moshe Vardi, Pierre Wolper, and Mihalis Yannakakis. "Memory-efficient algorithms for the verification of temporal properties." Formal methods in system design 1, no. 2 (1992): 275-288.
2. Gaiser, Andreas, and Stefan Schwoon. "Comparison of algorithms for checking emptiness on Büchi automata." arXiv preprint arXiv:0910.3766 (2009). [arXiv](https://arxiv.org/pdf/0910.3766.pdf).
3. Couvreur, Jean-Michel, Alexandre Duret-Lutz, and Denis Poitrenaud. "On-the-fly emptiness checks for generalized Büchi automata." In International SPIN Workshop on Model Checking of Software, pp. 169-184. Springer, Berlin, Heidelberg, 2005.
