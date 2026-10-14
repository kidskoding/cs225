#import "../diagrams.typ": array-cells, plane, tree

#let kd-points = ((2, 3), (5, 4), (9, 6), (4, 7), (8, 1), (7, 2), (9, 8))
#let kd-splits = (((7, 0), (7, 10)), ((0, 4), (7, 4)), ((7, 6), (10, 6)))
#let kd-tree = ("(7,2)", ("(5,4)", "(2,3)", "(4,7)"), ("(9,6)", "(8,1)", "(9,8)"))

= BBST Range Search and KD Trees

So far, we've used balanced BSTs as dictionaries that answer one question: is this key in the dictionary? But what makes a balanced BST special is that it also finds things that are *near* a key, not just the key itself

That makes BBSTs useful for *range-based* searches (e.g. finding every key that falls between $[11, 42]$) and *nearest-neighbor* searches (finding the closest point to some query point)

== Range Searches in a BBST

*Range queries* are a search to find all keys that fall within a given range, typically written as $[x, y]$, where $x$ is the lowest possible value (lower bound) and $y$ is the highest possible value (upper bound)

Since a BBST keeps its keys in sorted order, a range query is just a `find` followed by an in-order traversal

+ Search the tree for $x$. If $x$ is in the tree, we stop at it. Otherwise, we stop at the last node we visited before falling off the tree
+ Do an in-order traversal starting from that node, collecting every key that is in $[x, y]$
+ Stop as soon as the traversal reaches the first key larger than $y$

Take the tree in @kd-bst-range and the range $[11, 42]$. We search down and find `11`, then walk the tree in order: 11, 19, 25, 33, 42. The next key is 44, which is past the range, so we stop. If we searched for $[10, 42]$ instead, the search for `10` would end at `6`, since 10 is not in the tree. We'd start the traversal there, just leave `6` out because it's less than 10, and get the exact same answer

#figure(
  tree((25, (11, 6, 19), (42, 33, 44)), highlight: (11, 19, 25, 33, 42)),
  caption: [Example: a range search for $[11, 42]$ returns the highlighted keys. The traversal stops at 44, the first key past the range],
) <kd-bst-range>

The runtime is $O(log n + k)$, where $n$ is the number of keys in the tree and $k$ is the number of keys in the answer. The $log n$ is the initial search down the tree, and the $k$ is the traversal. We can never do better than $k$ anyways, since we have to actually return every key in the answer!

=== BBSTs vs. Sorted Lists

A sorted list and a balanced BST are very, very similar things. We could do the same range search on a sorted list with binary search followed by a linear scan

If we only build the structure once and then query it, they cost the same: sorting a list takes $O(n log n)$ time, and inserting $n$ things into a BBST takes $O(log n)$ time each, or $O(n log n)$ total

The difference shows up when the data keeps changing. A sorted list may need to be re-sorted before every query, whereas a BBST maintains its sorted order with only $O(log n)$ work per change

== `lower_bound` and `upper_bound`

Previously, we discussed how C++'s STL map is implemented via a red-black tree under the hood. So, in one dimension, `std::map` already does range searches for us!

`std::map` includes a `lower_bound` and an `upper_bound` function, which allow efficient logarithmic-time range queries by returning iterators

- `lower_bound` - The smallest element greater than or equal to (not less than) the argument
- `upper_bound` - The smallest element strictly greater than the argument

For the keys in @kd-bst-range, `lower_bound(11)` returns 11, since 11 is the smallest key not less than 11. `lower_bound(10)` also returns 11, because the next smallest key, 6, is less than 10

`upper_bound(42)` returns 44, the key *after* 42. `upper_bound(41)` returns 42. So `lower_bound` includes the key if it's in the map, but `upper_bound` never does

That's exactly what a standard range-based loop wants: `lower_bound` is our `begin`, and `upper_bound` is our `end`, which is one past the last key we care about. Looping from `lower_bound(x)` to `upper_bound(y)` covers $[x, y]$, inclusive at the bottom and exclusive at the top, just like `begin()` and `end()`. You can see this in @kd-bounds, where the loop for $[10, 42]$ runs from index 1 up to, but not including, index 6

#figure(
  array-cells(6, 11, 19, 25, 33, 42, 44, marks: ("lower_bound(10)": 1, "upper_bound(42)": 6), highlight: (1, 2, 3, 4, 5)),
  caption: [The sorted keys of a `std::map`. A loop from `lower_bound(10)` to `upper_bound(42)` visits exactly the highlighted keys],
) <kd-bounds>

In code, this looks like

```cpp
std::map<int, std::string> m = {
    {6, "f"}, {11, "k"}, {19, "s"}, {25, "y"}, {33, "g"}, {42, "p"}, {44, "r"}
};

// every key in [10, 42]
for(auto it = m.lower_bound(10); it != m.upper_bound(42); ++it) {
    std::cout << it->first << " ";
}
// prints 11 19 25 33 42
```

== Range Searches in Two Dimensions

One dimension is easy because we can sort. But what if our data is points in two dimensions, and we want to find every point inside a rectangle, like the one in @kd-rectangle?

#figure(
  plane(..kd-points, region: ((3, 0.5), (8.5, 5))),
  caption: [Example: which points are inside the dashed rectangle?],
) <kd-rectangle>

If we sort the points by $x$, we can tell whether a point is between the left and right sides of the rectangle, but not whether it's between the top and bottom. If we sort by $y$, we get the opposite problem. We could do both and then look at which points show up in both answers, but that means sorting the data twice (or building two complete trees), which is inefficient

This kind of query happens all the time in real code

- *Computer graphics* - We only want to draw the things in front, but to skip drawing what's hidden, we first have to detect what's behind
- *Collision detection* - Only check objects that are near each other
- *Computer vision* and *sensor data* - Only process the points in a region of interest

The other common question is *nearest neighbor*: given some point, which point in our data set is closest to it? The naive way is to check every point, because a point can be farther away in one dimension but so much closer in the other that it more than makes up for it

== KD Trees

A *$k$-dimensional tree*, or *KD Tree*, is a binary tree that stores points in $k$-dimensional space, organizing them so that large portions of space can be skipped entirely during range and nearest-neighbor queries

The idea is to split the world in half, one dimension at a time. The root splits the points by $x$, its children split their halves by $y$, their children split by $x$ again, and so on. Every level of the tree cuts the space into smaller and smaller regions

=== Building a KD Tree

To build a KD tree from $k$-D space

+ Start with one dimension (doesn't matter which one)
+ Find the *median* point along that dimension. It becomes the current root
+ Split the data set into two parts: points less than the median in that dimension go in the left subtree, and points greater than the median go in the right subtree
+ Recursively build the left and right subtrees, moving to the next dimension (e.g., if you split by $x$ at this level, split by $y$ at the next)
+ When a subtree has only one point left, that point is a leaf

Instead of fully sorting at every level, we find the median with *quickselect*, which you can think of as a "one-handed quicksort". It partitions the array just like quicksort does, but only recurses into the side that contains the index we care about. When it finishes, the median is at the middle index, everything smaller in that dimension is to its left (in no particular order), and everything larger is to its right. That takes linear time per level instead of $O(n log n)$

Quickselect takes a comparison function, so we call it with one that compares points only by $x$ at the first level, only by $y$ at the next, and so on. We have to cycle through the dimensions evenly ($x, y, x, y, ...$ in 2D, or $x, y, z, x, y, z, ...$ in 3D). If we split by $x$ twice in a row, the second split might not shrink the regions at all

@kd-tree-build shows the KD tree built from seven points. $(7, 2)$ is the median by $x$, so it splits the whole plane with a vertical line. On the left, $(5, 4)$ is the median of the remaining points by $y$, so it splits that half with a horizontal line, and $(9, 6)$ does the same on the right

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    align: horizon,
    plane(..kd-points, splits: kd-splits),
    tree(kd-tree),
  ),
  caption: [Example: the KD tree built from (2,3), (5,4), (9,6), (4,7), (8,1), (7,2), (9,8). The root splits on $x$ and its children split on $y$],
) <kd-tree-build>

A KD tree stays balanced simply because of the median: at each step we split the data set using the median point along the current dimension, ensuring that half the points go to the left subtree and half go to the right subtree

The same idea works in any number of dimensions. That might seem ridiculous for physical space, but machine learning often describes data points with hundreds or thousands of *features* (color, shape, size, ...), and each feature is just another dimension

=== Range Search in a KD Tree

To find every point inside a rectangle, we start at the root and work our way down

+ If the current point is inside the rectangle, add it to the answer
+ If the rectangle extends to the *smaller* side of the current split, search the left subtree
+ If the rectangle extends to the *larger* side of the current split, search the right subtree

In @kd-range-walk, the rectangle crosses the root's split at $x = 7$, so we search both sides, and $(7, 2)$ itself is in the box. On the left, the rectangle crosses $y = 4$, so we check both $(2, 3)$ and $(4, 7)$. On the right, though, the rectangle is entirely below $y = 6$, so we only check $(8, 1)$ and never even look at $(9, 8)$

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    align: horizon,
    plane(..kd-points, splits: kd-splits, region: ((3, 0.5), (8.5, 5)), highlight: ((5, 4), (7, 2), (8, 1))),
    tree(kd-tree, highlight: ("(5,4)", "(7,2)", "(8,1)")),
  ),
  caption: [Example: a range search for the dashed rectangle finds the highlighted points. The rectangle never reaches above $y = 6$ on the right side, so the subtree at $(9, 8)$ is skipped],
) <kd-range-walk>

With a small tree, the savings don't look like much, but imagine a tree with thousands of points and a box that is small compared to the whole space. We'd only have to search a small number of the points

== Nearest Neighbor Search

Given a query point $q$, we want the point in the tree that is closest to it, using the standard (Euclidean) sense of distance. The query point doesn't have to be in the tree, and usually isn't

We never actually take the square root when computing distances. The square root preserves order, so comparing squared distances gives the same answer, and skipping it has two benefits: square roots take work, and floating point math has errors, so we want to do as little of it as possible. Squaring integers doesn't even need floating point at all

To find the nearest neighbor of $q$

+ Start at the root and move down the tree, choosing the child subtree that would contain $q$ based on the current splitting dimension (just like `find`)
+ When we can't descend any further, the point we stopped at becomes our first *best guess*
+ Backtrack up the tree. At each node on the way back up
  + If the node is closer to $q$ than our best guess, it becomes the new best guess
  + If the *other* side of the node's split could still hold a closer point, search that subtree too
+ Return the best guess once we're back at the root

How do we know whether the other side could hold a closer point? Any closer point has to be inside the circle around $q$ whose radius is the distance to our best guess. Checking a circle (or a *hypersphere* in more than 3 dimensions) against a split is annoying, so we use the square around $q$ instead (a *hyperrectangle*). The square contains the whole circle, so we never miss a point, and the check becomes a single comparison: does the square cross the splitting line in the current dimension? In other words, is $(q_d - s_d)^2$ no more than the best squared distance so far, where $s$ is the node's point and $d$ is its splitting dimension?

Let's find the nearest neighbor of $q = (6, 3)$ in the tree from @kd-tree-build

+ At the root $(7, 2)$, we split by $x$. Since $6 < 7$, we go left
+ At $(5, 4)$, we split by $y$. Since $3 < 4$, we go left
+ $(2, 3)$ is a leaf, so it's our first best guess, with a squared distance of $(6 - 2)^2 + (3 - 3)^2 = 16$. The big square on the left of @kd-nn-search shows every point that could still be closer

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    row-gutter: 0.8em,
    plane(..kd-points, splits: kd-splits, query: (6, 3), region: ((2, 0), (10, 7)), highlight: ((2, 3),)),
    plane(..kd-points, splits: kd-splits, query: (6, 3), region: ((4.59, 1.59), (7.41, 4.41)), highlight: ((5, 4),)),
    [First guess $(2, 3)$], [Better guess $(5, 4)$],
  ),
  caption: [Searching for the nearest neighbor of $q = (6, 3)$. Each dashed square holds every point that could still beat the current best guess, so it shrinks as the guess improves],
) <kd-nn-search>

4. Back up at $(5, 4)$, the squared distance is $1 + 1 = 2$, which beats 16, so $(5, 4)$ becomes our best guess and the square shrinks (right of @kd-nn-search). The square still crosses the split at $y = 4$, so we have to check the other side, $(4, 7)$. Its squared distance is 20, so no luck
+ Back up at the root $(7, 2)$, the squared distance is also 2: a tie with $(5, 4)$. Ties are broken by a fixed tie-break rule (the MP tells you which), and here we keep $(5, 4)$. The square crosses $x = 7$, so we have to search the right subtree
+ On the right, $q$ is below $y = 6$, so we first descend to $(8, 1)$ (squared distance 8), then check $(9, 6)$ (squared distance 18). Neither beats 2. The square never reaches $y = 6$, so we skip $(9, 8)$ entirely

The nearest neighbor is $(5, 4)$, and we never looked at $(9, 8)$. In a bigger tree, every subtree we can rule out like this saves a lot of work

=== Ties

When two points are the same distance away, we need some way to choose. Analysis usually assumes no two distances are ever equal, which just makes the math easier. In code, we add a tie-break rule instead, which acts like adding a tiny $epsilon$ to one of the distances so there's never really a tie. Checking both on a tie would never find anything better anyways, so we just need to choose consistently

=== Implementation Tips

The search is the hardest part of MP Mosaics, mostly because of knowing what you have to backtrack into and what you don't

- One way to start is with an exhaustive search of the whole tree. It always finds the right point, but it will fail the tests, since some of the points are booby-trapped: if you ever look at them, you didn't follow the algorithm. In @kd-nn-search, $(9, 8)$ would be one of those points. You have to look at $(9, 6)$, but only to figure out whether you need to look at $(9, 8)$
- Your first guess *must* be a point that actually exists in the tree. It's really easy to accidentally initialize the best guess to $(0, 0, ...)$ before descending. That point usually isn't in the tree, and it might even be closer to $q$ than any real point. Your code will work most of the time, but a few points of your mosaic will come out the wrong color

=== Analysis

The full analysis of KD trees is beyond the scope of this course. We usually think of a search as $O(log n)$, but that would require a fixed amount of backtracking work, and there's no guarantee of that. If someone carefully arranges the points (for example, in a narrow spiral where every point is almost the same distance from $q$), the splits end up as very inconvenient slices, and a search can end up checking every point

Even so, it is the best data structure and algorithm we know for nearest neighbor search in an arbitrary number of dimensions, on a query point that isn't necessarily in the data set

== $k$-Nearest Neighbor ($k$-NN)

*$k$-Nearest Neighbors (k-NN)* is a simple algorithm used in machine learning and data analysis to find the $k$ closest points to a given query point in a dataset

It is used very often in *Machine Learning*, specifically classification and regression

- *Classification* - Assign the query point the most common class among its k nearest neighbors.
- *Regression* - Predict the query point’s value as the average of its k nearest neighbors’ values.

It becomes very efficient with a constructed KD Tree because it avoids brute force checking each point. Instead, it narrows the search by recursively exploring only those regions of space that could contain points closer than the current best candidates, ignoring irrelevant subtrees, to make nearest neighbor searches much faster
