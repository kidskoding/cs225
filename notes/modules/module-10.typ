#import "../diagrams.typ": tree

= Tree Searching and Dictionaries

A *traversal* is an algorithm that goes through every single node in a tree and visits it ($O(n)$ time)

A *search* is an algorithm that finds a node in a tree of value $v$ if it exists (worst case is when $v in.not T$, where $T$ represents any tree; this involves running the full traversal, so it is in $O(n)$ time)

Previously, we discussed two types of search *Breadth First* and *Depth First* (*BFS* and *DFS*)

*BFS* is the same as level order traversal, where its overhead (or space complexity) is the maximum number of nodes in a queue (can also be seen as the width of a tree)

*DFS* involves any of the three traversals that descend into the tree's children: pre order traversal, in order traversal, and post order traversal. Its overhead is the maximum depth in the tree (or simply height)

BFS is more *reliable* than DFS. This is because it will eventually find a solution to a valid search if one exists, even if the tree is infinite in depth. Since BFS explores nodes level by level, this guarantees that all nodes at depth $d$ are visited before any node at depth $d + 1$. So if the solution lies at a shallow depth, BFS will find it eventually.

In contrast, DFS can get *"stuck"* going down an infinite branch of a tree, especially if the solution lies on a different, shallower path. Therefore, DFS might never return a proper solution, even if it does exist. You can already see this cost on a finite tree in @dict-dfs-vs-bfs: when searching for 3, DFS wanders through the whole left branch while BFS finds it after one level.

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: bottom + center,
    tree((1, (2, (4, 7, 8), 5), 3), highlight: (1, 2, 4, 7, 8, 5, 3)),
    tree((1, (2, (4, 7, 8), 5), 3), highlight: (1, 2, 3)),
    [DFS (pre-order): 1, 2, 4, 7, 8, 5, 3], [BFS: 1, 2, 3],
  ),
  caption: [Example: searching for 3, which sits at depth 1. DFS exhausts the whole left branch first; BFS reaches 3 after visiting only one level],
) <dict-dfs-vs-bfs>

BFS will always find a solution if one exists, even in infinite-depth trees, but it may require an infinite amount of memory. This is because BFS stores all nodes at a given depth (one full level of the tree) in a queue before moving on to the next level. If the tree is very wide, this means the queue can grow extremely large, consuming a lot of memory.

In contrast, DFS typically uses less memory, since it only needs to store the current path from the root to a leaf, which depends on the depth of the tree, not its width.

Therefore, in any practical application, memory is going to be the forefront problem. Since DFS uses less memory, that will often be the best approach. But, if there are infinite trees, DFS wouldn't work. There is a solution that solves this problem and it is known as *iterative deepening*

*Iterative Deepening* runs DFS with a *maximum depth limit* of $k$, meaning it will not explore any nodes beyond depth $k$ (starting at $k = 0$). When DFS reaches that depth, it stops descending and backtracks up the tree. This approach is useful because the maximum memory used when doing DFS is proportional to $k$ (simply the overhead cost - $O(k)$). If no solution is found at depth $k$, the algorithm restarts DFS with a new depth limit $k + 1$, and this process repeats until a solution is found.

This effectively simulates BFS for DFS and will always find the solution because it explores each node at every level by using bounded memory (as deep as depth $k$ with overhead cost of $O(k)$).

These are the two basic searching strategies, but they aren't that effective, since they can be slow in both time and memory. But what if there was a data structure that put searching at its forefront, which is essentially what a *map* or *dictionary* does

== Dictionaries

Dictionaries store *key-value* pairs, just like a regular dictionary, which stores words to definitions. If I had a word, I can use a dictionary to look up its definition! This could be done most optimally using binary search, where I start from the middle and then slowly go left or right based on whether the word I'm looking for comes before or after the middle word alphabetically.

This is just one example of a dictionary though, we can use it to look up students using their unique ID numbers (UIUC UIN) or by looking at a Flight number (*key*) for its departure time/arrival time (*value*).

In fact, an array really is just a dictionary, because we use an index (*key*) to lookup the value of an element that is present in the array (*value*)

=== Dictionary Interface (ADT)

- `insert(key, value)` - insert a key and value into the dictionary
- `remove(key)` - remove a key value mapping from the dictionary via passing in the key
- `std::optional<value> find(key)` - return the value associated with the key (C++ has an `std::optional` type that you could use to return nothing if no value is found for the key!)

And then there's the obvious things like a constructor, destructor, and an iterator, but at the end of the day, this is what we want with a dictionary.

And with this, we solve our problems with searching in Computer Science. A lot of other data structures, like Hash Tables and Tries, will rely on dictionaries to provide fast and efficient key-based access, which is essential for everything from caching to autocomplete and spell checking

The code below is a sample header file for our dictionary, backed by a `std::unordered_map`

```cpp
// Dictionary.h

#pragma once
#include <unordered_map>

template <class K, class V>
class Dictionary {
public:
    using Iterator = typename std::unordered_map<K, V>::iterator;

    /** Inserts a key-value pair into the dictionary
     * Runtime: expected O(1)
     */
    void insert(const K key, const V value);

    /** Removes the mapping for `key` and returns its value
     * Runtime: expected O(1)
     */
    V remove(const K& key);

    /** Returns an iterator to the pair with `key`, or `end()` if it is missing
     * Runtime: expected O(1)
     */
    Iterator find(const K& key);

    /** Returns an iterator to the first key-value pair
     * Runtime: O(1)
     */
    Iterator begin();

    /** Returns an iterator one past the last key-value pair
     * Runtime: O(1)
     */
    Iterator end();

private:
    // the underlying map that stores every key-value pair
    std::unordered_map<K, V> data;
};
```

Our custom dictionary implements an iterator by leveraging C++'s standard library iterator from the underlying data structure of `std::unordered_map`. This allows us to avoid writing a custom iterator from scratch, while still providing full iterator functionality like `begin()`, `end()`, and `find()`.

== Using Binary Trees as a Search Structure

In the context of a tree, these three functionalities of a dictionary, `insert`, `remove`, and `find`, are reflected below

#table(
  columns: (auto, auto, 1fr),
  table.header([*Dictionary Operation*], [*Runtime*], [*Explanation*]),
  [`insert`], [$O(1)$], [Similar to a LinkedList; put a new pointer to head and point the tree's head to this new node, which is constant time],
  [`remove`], [$O(n)$], [Need to first find the item by scanning the tree, and then shift elements to fill the gap],
  [`find`], [$O(n)$], [Searches nodes one by one, traversing the tree until it finds the key or uses all nodes],
)

This sets up the foundation for many other types of trees including, BSTs, BBSTs, and AVL trees, which will be covered later on

To preview why ordering the keys matters for `find`, compare the two trees in @dict-binary-tree-vs-bst: the plain binary tree visits all 7 nodes to find 7, while the BST only visits 3.

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: bottom + center,
    tree((5, (1, 3, 6), (2, 4, 7)), highlight: (5, 1, 3, 6, 2, 4, 7)),
    tree((4, (2, 1, 3), (6, 5, 7)), highlight: (4, 6, 7)),
    [Plain binary tree: 7 nodes visited], [BST: 3 nodes visited],
  ),
  caption: [Example: finding 7 among the same keys. A plain binary tree gives no hint where 7 is, so the search scans every node; a BST orders its keys so the search follows a single path 4, 6, 7],
) <dict-binary-tree-vs-bst>
