#import "../diagrams.typ": graph, memory, tree
#show raw.where(block: true): set block(breakable: false)

= Midterm 0: Review of Prerequisite Material

Midterm 0 is your first CBTF exam in CS 225. It checks the prerequisite material: discrete math and graph theory from *CS 173/MATH 213*, and C++ from *CS 128/ECE 220*. On the course side it leans on modules 1-2 (course intro and C++ review) plus the tree definitions from module 8

== Topics Covered

- Course Policies
- Mathematical Foundations
  - Be able to give a closed form solution to a recurrence relation
  - Be able to indicate the big-O running time of common algorithms (eg: binary search, merge sort, etc)
  - Be able to understand basic graph terminology
  - Be familiar with Trees
  - Be able to understand a standard proof and proof by induction
- C++ Topics
  - Classes in C++
    - Public member functions
    - Private helper functions
    - Private variables
    - Constructors
      - Automatic default constructor
      - Custom constructors (default and non-default)
    - Copy constructor
      - Automatic copy constructor
      - Custom copy constructor
    - Inheritance
  - Namespaces in C++
    - Creating a class that is part of a namespace (eg: `Cube` is part of the `cs225` namespace)
    - Using a class from a namespace (eg: `cs225::Cube`)
    - Purpose and usefulness of namespaces
  - Variables
    - Four properties: name, type, location (in memory), and value
    - Primitive vs. user-defined
  - Memory
    - Indirection in C++:
      - Reference variables
      - Pointers
      - Differences and trade-offs between each type
    - Stack memory
    - Heap memory
  - Functions: Calling and Returning
    - Pass by value, by reference, and by pointer
    - Return by value, by reference, and by pointer

== Course Policies

- *Prereqs* - credit in CS 173/MATH 213 and CS 128 (ECE students can use ECE 220 instead of CS 128)
- *Grade split* - 36% MPs (6% each), 12% labs, 36% midterms (6% each), 16% final. Every exam runs in the CBTF

== Recurrences

*Key ideas*

- *Recurrence* - a formula where each term is built from earlier terms, plus a base case like $T(0)$ or $T(1)$
- *Closed form* - an expression for $T(n)$ that doesn't need the earlier terms
- *Unrolling* - plug the recurrence into itself a few times, spot the pattern after $k$ steps, then pick $k$ so the argument hits the base case
- Two sums that keep showing up: $sum_(i = 1)^n i = (n(n + 1))/2$ and $sum_(i = 0)^(k - 1) 2^i = 2^k - 1$

*Recurrences to recognize*

#table(
  columns: (auto, auto, 1fr),
  table.header([*Recurrence*], [*Closed form / growth*], [*Where you see it*]),
  [$T(n) = T(n - 1) + c$], [$T(0) + c n$, so $O(n)$], [walking a list one element at a time],
  [$T(n) = T(n - 1) + n$], [$O(n^2)$], [selection or insertion sort],
  [$T(n) = T(n\/2) + c$], [$O(log n)$], [binary search],
  [$T(n) = 2T(n\/2) + n$], [$O(n log n)$], [merge sort],
  [$T(n) = 2T(n - 1) + c$], [$O(2^n)$], [two recursive calls on $n - 1$],
)

*Worked template*. With $T(n) = 2T(n - 1) + 3$ and $T(1) = 1$:

$
  T(n) &= 2T(n - 1) + 3 = 4T(n - 2) + 2 dot 3 + 3 = dots \
  &= 2^k T(n - k) + 3 sum_(i = 0)^(k - 1) 2^i = 2^k T(n - k) + 3(2^k - 1)
$

The base case shows up when $n - k = 1$, so $k = n - 1$ and $T(n) = 2^(n - 1) + 3(2^(n - 1) - 1) = 2^(n + 1) - 3$. Check: $T(2) = 2 dot 1 + 3 = 5 = 2^3 - 3$

*Common mistakes*

- Not checking the closed form against a small value like $T(1)$ or $T(2)$, which is the fastest way to catch an off-by-one
- Losing the base case value: $T(n) = T(n - 1) + 2$ with $T(0) = 5$ is $5 + 2n$, not $2n$
- Solving for $k$ the wrong way on halving recurrences: $n\/2^k = 1$ means $k = log_2 n$

== Proof by Induction

*Key ideas*

- *Base case* - show the claim for the smallest $n$ (usually $0$ or $1$)
- *Inductive hypothesis* - assume the claim holds for $n = k$ (strong induction assumes it for every value below $k + 1$)
- *Inductive step* - use the hypothesis to prove the claim for $n = k + 1$
- Write the $k + 1$ case as the $k$ case plus one more piece, so the hypothesis can replace the $k$ part

*Example*: $1 + 2 + dots + n = (n(n + 1))/2$ for $n >= 1$. The base case $n = 1$ gives $1 = (1 dot 2)/2$. Assume $1 + 2 + dots + k = (k(k + 1))/2$. Then $(1 + dots + k) + (k + 1) = (k(k + 1))/2 + (k + 1) = ((k + 1)(k + 2))/2$, which is the formula at $n = k + 1$

*Common mistakes*

- Starting from the $k + 1$ statement and working backwards as if it were true. Start from the left side and transform it until you reach the right side
- Skipping the base case or proving it for a value smaller than the claim's starting point
- Never actually using the hypothesis. If it doesn't appear in your step, the step is wrong

== Big-O

*Key ideas*

- $O(f(n))$ is an *upper bound* on growth as $n$ gets large, so it is what you quote for the worst case
- Drop constants and lower order terms: $3n^2 + 5n + 7$ is $O(n^2)$
- Ordering to memorize: $O(1) < O(log n) < O(n) < O(n log n) < O(n^2) < O(2^n) < O(n!)$
- A loop that halves (or doubles) its counter runs $O(log n)$ times. Nested loops multiply

*Runtimes of common algorithms*

#table(
  columns: (auto, auto, 1fr),
  table.header([*Algorithm*], [*Worst case*], [*Why*]),
  [Linear search], [$O(n)$], [may check every element],
  [Binary search], [$O(log n)$], [throws away half of a sorted range each step],
  [Bubble/insertion/selection], [$O(n^2)$], [nested passes over the array],
  [Merge sort], [$O(n log n)$], [$log n$ levels of splitting, $O(n)$ merging per level],
  [Quick sort], [$O(n^2)$], [a bad pivot leaves $n - 1$ on one side (average $O(n log n)$)],
  [Heap sort], [$O(n log n)$], [$n$ heap removals at $O(log n)$ each],
)

*Common mistakes*

- Calling quick sort $O(n log n)$ worst case. That is its average; the worst case is $O(n^2)$
- Forgetting binary search only works on *sorted* data
- Adding nested loop counts instead of multiplying them

== Graphs

*Key ideas*

- *Graph* $G = (V, E)$ - a set of vertices and a set of edges, each edge joining two vertices. Joined vertices are *adjacent* (neighbors)
- *Directed* edges go one way (arrows); *undirected* edges go both ways
- *Loop* - an edge from a vertex to itself. *Multiple edges* - more than one edge between the same pair. *Simple* graph - neither
- *Complete graph* on $n$ vertices - every pair is joined, so it has $(n(n - 1))/2$ edges
- *Walk* - sequence of vertices joined by edges, repeats allowed. *Path* - a walk with no repeated vertices. *Cycle* - closes back on its start without repeating anything else
- *Wheel* - a cycle plus one center vertex joined to every cycle vertex. *Subgraph* - pick some of the vertices and edges
- *Degree* $deg(v)$ - number of edges touching $v$; a loop adds 2
- *Handshaking theorem* - $sum_(v in V) deg(v) = 2|E|$, so the number of odd-degree vertices is always even
- *Isomorphic* - there is a bijection $f: V_1 -> V_2$ with $u v$ an edge exactly when $f(u) f(v)$ is an edge. Same vertex count, edge count and degree list are necessary, not enough on their own
- *Connected* - a walk exists between every pair of vertices. *Cut edge* - removing it disconnects the graph
- *Euler circuit* - closed walk using every edge exactly once. A connected graph has one exactly when every degree is even
- *Bipartite* - vertices split into $V_1$ and $V_2$ with every edge going across; same as being 2-colorable, so an odd cycle rules it out

*Common mistakes*

- Counting a loop as 1 toward degree
- Calling two graphs isomorphic because the degree lists match. You still need an edge-preserving bijection
- Mixing up walks and paths. A path can't revisit a vertex

== Trees

*Key ideas*

- *Tree* - connected and acyclic; $n$ vertices means $n - 1$ edges, and there is exactly one path between any two vertices
- *Vocabulary* - parent, child, sibling (same parent), leaf (no children), internal (at least one child), ancestor (on the path up to the root), descendant
- *Level* (depth) - edges from the root; the root is level 0
- *Height* - edges on the longest root-to-leaf path. One node has height 0 and the empty tree has height $-1$, so $"height"(T) = max("height"(T_L), "height"(T_R)) + 1$
- *$m$-ary* tree - every node has at most $m$ children (binary means $m = 2$)
- *Full* - every node has 0 or $m$ children. A full $m$-ary tree with $i$ internal nodes has $m i + 1$ nodes
- *Perfect* - every level is completely filled, so the tree is both full and complete
- *Complete* - every level is full except maybe the last, which is filled from the left
- *Balanced* - at *every* node, the left and right subtree heights differ by at most 1
- Binary tree of height $h$: at most $2^L$ nodes on level $L$, at most $2^(h + 1) - 1$ nodes total (perfect), at least $h + 1$ nodes (a single chain)

*Common mistakes*

- Measuring height in nodes instead of edges. In this class a single node has height 0
- Using $m i + 1$ on a tree that isn't full
- Checking balance only at the root. Every node has to pass

== Classes in C++

*Key ideas*

- *Public member functions* - the interface anyone can call. *Private variables* and *private helper functions* - only the class's own code can use them
- `class` members default to `private`; `struct` members default to `public`. That is the only difference
- `protected` - like private, but derived classes can see it too
- *Constructor* - same name as the class, no return type. Initialize members in the *initializer list* (`: m_x{ x }`), not by assigning in the body
- *Default constructor* takes no arguments; a *non-default* one takes some. Constructors can be overloaded
- *Automatic default constructor* - the compiler writes `Foo()` for you *only if you declare no constructors at all*. Declare any constructor (even a copy constructor) and it is gone unless you write `Foo() = default;`
- *Copy constructor* `Foo(const Foo& other)` - builds a new object from an existing one, as in `Foo b = a;` or when an object is passed by value
- *Automatic copy constructor* - copies each member. For a pointer member that copies the address only (a *shallow copy*), so both objects share one heap block
- A *custom copy constructor* does a *deep copy*: allocate new memory and copy the pointed-to data
- *Destructor* `~Foo()` - no return type, no arguments, runs when the object goes out of scope or is `delete`d. Use it to free what the class owns
- *Rule of three* - define a destructor, copy constructor or copy assignment operator, and you should define all three
- *Inheritance* - `class Derived : public Base` gets Base's public and protected members (private ones exist but Derived can't touch them). The base constructor runs first, and you can pick which one in the initializer list

*Code you should be able to write*

```cpp
// Cube.h
#pragma once
namespace cs225 {
  class Cube {
    public:
      Cube();                    // custom default constructor
      Cube(double length);       // non-default constructor
      Cube(const Cube& other);   // custom copy constructor
      double getVolume() const;  // public member function
    private:
      double length_;            // private variable
      double faceArea_() const;  // private helper function
  };
}
```

```cpp
// Cube.cpp
#include "Cube.h"
namespace cs225 {
  Cube::Cube() : length_{ 1 } { }
  Cube::Cube(double length) : length_{ length } { }
  Cube::Cube(const Cube& other) : length_{ other.length_ } { }
  double Cube::faceArea_() const { return length_ * length_; }
  double Cube::getVolume() const { return faceArea_() * length_; }
}
```

```cpp
class RubikCube : public cs225::Cube {
  public:
    RubikCube(double length) : Cube(length) { }  // pick the base constructor
};
```

A deep copy constructor for a class that owns `int* data` and `int size`:

```cpp
Foo(const Foo& other) : size{ other.size } {
    data = other.data ? new int(*other.data) : nullptr;
}
```

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    memory(stack: (a: "->h", b: "->h"), heap: (h: 42)), memory(stack: (a: "->h1", b: "->h2"), heap: (h1: 42, h2: 42)),
    [Shallow (automatic)], [Deep (custom)],
  ),
  caption: [Example: the `data` pointers of `a` and `b` after `Foo b = a;`],
) <m0-shallow-deep-copy>

#block(sticky: true)[*Common mistakes*]

- Writing `Cube c;` when the class only declares `Cube(double)`. There is no default constructor anymore, so it won't compile
- Relying on the automatic copy constructor for a class that owns heap memory. After `Foo b = a;` both destructors `delete` the same block (double free). The fix is the rule of three: deep copy constructor, copy assignment operator and destructor
- Giving a constructor a return type, even `void`
- Accessing a base class's `private` member from a derived class

== Namespaces

*Key ideas*

- A *namespace* groups related names (classes, functions, variables) so they can't clash with someone else's names
- Put a class in one by wrapping its declaration *and* its definitions in `namespace cs225 { ... }`
- Use it from outside with the full name `cs225::Cube`, the same way you write `std::cout`
- `using namespace std;` dumps every name into scope, which brings collisions back if you define your own `cout`. Never put it in a header

*Common mistakes*

- Wrapping the header in `namespace cs225` but not the `.cpp`. Then `Cube::Cube` looks for a global `Cube`, finds none, and won't compile
- Writing `Cube c;` outside the namespace without `cs225::` or a `using` declaration

== Variables and Memory

*Key ideas*

- Every variable has four properties - *name*, *type*, *location* in memory, and *value*
- *Primitive* types are built in (`int`, `char`, `double`, `bool`, pointers). *User-defined* types are classes and structs you (or a library) write, like `Cube`
- *Reference* `int& r = x;` - another name for `x`. Must be initialized, can never be null, can never be reseated to a different variable
- *Pointer* `int* p = &x;` - its own variable holding an address. `*p` dereferences it; it can be `nullptr` and can be pointed elsewhere
- Prefer references when something always exists; use pointers when it might be missing or you need to change what you point at
- *Stack* - local variables and parameters, one frame per active call. Freed automatically when the function returns. Fast, but small
- *Heap* - memory from `new`, which lives until you `delete` it. Slower and only reachable through a pointer, but it outlives the function and fits large data
- `new` allocates and runs the constructor; `delete` runs the destructor and frees. Match `new[]` with `delete[]`
- *Memory leak* - heap memory nothing points to anymore, so it can never be freed
- *Dangling pointer or reference* - still refers to memory that was freed or went out of scope. Using it is undefined behavior. Set pointers to `nullptr` after `delete`

#figure(
  memory(stack: (p: "->h", a: 3), heap: (h: 4)),
  caption: [Example: `int a = 3; int* p = new int(4);` puts `a` and the pointer `p` on the stack, and only the `int` that `p` points to on the heap],
) <m0-stack-heap>

*Common mistakes*

- Thinking the pointer itself is on the heap. In `int* p = new int(4);` the pointer `p` is a stack variable
- Using `delete` on an array from `new[]`, or deleting the same block twice
- Using a pointer after `delete`, or copying a pointer and then deleting through the copy

== Functions: Calling and Returning

*Key ideas*

#table(
  columns: (auto, 1fr, 1fr),
  table.header([*Style*], [*Passing in*], [*Returning*]),
  [By value `T`], [function gets a copy; caller's variable can't change], [caller gets a copy; always safe],
  [By reference `T&`], [function gets an alias; changes hit the caller's variable], [caller gets an alias; the object must outlive the call],
  [By pointer `T*`], [function gets a copy of the address; `*p = ...` changes the caller's variable], [caller gets an address (may be null); must not point at a local],
)

- Pass by `const T&` to skip copying a big object you don't plan to change
- Passing a class object by value runs its copy constructor

*Common mistakes*

- Returning a reference or pointer to a local variable. The local dies when the function returns, so the caller holds a dangling reference
- Assigning to the pointer parameter (`p = nullptr;`) and expecting the caller's pointer to change. Only `*p = ...` reaches the caller

== Practice Problems

+ Find a closed form for $T(n) = T(n - 1) + 2n$ with $T(0) = 0$

  *Answer:* Unrolling gives $T(n) = T(n - k) + 2(n + (n - 1) + dots + (n - k + 1))$. At $k = n$ this is $T(0) + 2(1 + 2 + dots + n) = 2 dot (n(n + 1))/2 = n(n + 1)$. Check: $T(1) = 2 = 1 dot 2$ and $T(2) = 2 + 4 = 6 = 2 dot 3$

+ Find a closed form for $T(n) = T(n\/2) + 1$ with $T(1) = 1$, where $n$ is a power of 2. What algorithm has this shape?

  *Answer:* After $k$ steps $T(n) = T(n\/2^k) + k$. The base case is $n\/2^k = 1$, so $k = log_2 n$ and $T(n) = 1 + log_2 n$, which is $O(log n)$. That is binary search: one comparison, then recurse on half the range. Check: $T(4) = T(2) + 1 = T(1) + 2 = 3 = 1 + log_2 4$

+ Prove by induction that $sum_(i = 0)^n 2^i = 2^(n + 1) - 1$ for all $n >= 0$

  *Answer:* Base case $n = 0$: the left side is $2^0 = 1$ and the right side is $2^1 - 1 = 1$. Hypothesis: $sum_(i = 0)^k 2^i = 2^(k + 1) - 1$. Step: $sum_(i = 0)^(k + 1) 2^i = (sum_(i = 0)^k 2^i) + 2^(k + 1) = 2^(k + 1) - 1 + 2^(k + 1) = 2^(k + 2) - 1$, which is the formula at $n = k + 1$. (This is why a perfect binary tree of height $h$ has $2^(h + 1) - 1$ nodes)

+ What is the big-O runtime of this code in terms of $n$?

  ```cpp
  int count = 0;
  for (int i = 1; i < n; i *= 2)
      for (int j = 0; j < n; j++)
          count++;
  ```

  *Answer:* $O(n log n)$. The outer loop doubles `i`, so it runs about $log_2 n$ times, and the inner loop runs $n$ times for each of those

+ Use the graph in @m0-practice-graph. (a) Give every degree and check the handshaking theorem. (b) Does it have an Euler circuit? (c) Name a cut edge. (d) Is it bipartite?

  #figure(
    graph(
      (a: (0, 0), b: (0, -1.4), c: (1.2, -0.7), d: (2.6, -0.7), e: (3.8, 0), f: (3.8, -1.4)),
      ("a-b", "a-c", "b-c", "c-d", "d-e", "d-f", "e-f"),
    ),
    caption: [Graph for practice problem 5],
  ) <m0-practice-graph>

  *Answer:* (a) $deg(a) = deg(b) = deg(e) = deg(f) = 2$ and $deg(c) = deg(d) = 3$. The sum is $14 = 2 dot 7$, matching the 7 edges. (b) No. It is connected, but `c` and `d` have odd degree. (c) `c-d`; removing it leaves ${a, b, c}$ and ${d, e, f}$. (d) No. The triangle $a, b, c$ is an odd cycle, so two colors aren't enough

+ True or false: a graph can have exactly three vertices of odd degree

  *Answer:* False. By the handshaking theorem the degrees sum to $2|E|$, which is even. The even-degree vertices add an even amount, so the odd-degree ones must also add to an even number, which takes an even count of them

+ Use the tree in @m0-practice-tree. Give its height, its leaves, the level of `G`, and say whether it is full, complete and balanced

  #figure(
    tree(("A", ("B", "D", "E"), ("C", none, ("F", "G", none)))),
    caption: [Tree for practice problem 7],
  ) <m0-practice-tree>

  *Answer:* Height 3 (path `A`, `C`, `F`, `G`). Leaves: `D`, `E`, `G`. `G` is on level 3. Not full, since `C` and `F` each have one child. Not complete, since level 2 is missing `C`'s left child but has `F` to its right. Not balanced: at `C` the left subtree is empty (height $-1$) and the right subtree has height 1, a difference of 2

+ A binary tree has height 4. What are the fewest and most nodes it can have? A full binary tree has 10 internal nodes. How many nodes and leaves does it have?

  *Answer:* Fewest is $h + 1 = 5$ (a chain). Most is $2^(h + 1) - 1 = 31$ (perfect). The full tree has $2 dot 10 + 1 = 21$ nodes, so $21 - 10 = 11$ leaves

+ What are `x`, `y`, `z` and `*q` after this runs?

  ```cpp
  void f(int a, int& b, int* c) {
      a = 1;
      b = 2;
      *c = 3;
      c = nullptr;
  }
  int x = 0, y = 0, z = 0;
  int* q = &z;
  f(x, y, q);
  ```

  *Answer:* `x = 0` (passed by value, so only the copy `a` changed), `y = 2` (`b` is an alias of `y`), `z = 3` (written through the pointer). `q` still points at `z`, so `*q = 3`. Setting `c = nullptr` changed only the function's own copy of the address

+ What is wrong with each snippet?

  ```cpp
  int* p = new int(3);    // (a)
  int* q = p;
  delete p;
  *q = 4;

  int& g() {              // (b)
      int x = 5;
      return x;
  }
  ```

  *Answer:* (a) `p` and `q` hold the same address. After `delete p;` that memory is freed, so `q` is a dangling pointer and `*q = 4` is undefined behavior. (b) `x` is a local on `g`'s stack frame and is gone once `g` returns, so the caller gets a dangling reference. Return by value (`int g()`) instead

+ `Cube` declares only `Cube(double length);` and has no other constructors. Which lines compile, and which constructor does each one call?

  ```cpp
  cs225::Cube a(3);
  cs225::Cube b;
  cs225::Cube c = a;
  ```

  *Answer:* Line 1 compiles and calls `Cube(double)`. Line 2 does *not* compile: declaring `Cube(double)` stopped the compiler from generating a default constructor. Line 3 compiles and calls the automatic copy constructor, which still exists because no copy constructor was declared
