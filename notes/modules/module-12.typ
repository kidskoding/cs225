#import "../diagrams.typ": tree

= BST Balance

Previously, we discussed that $O(h) equiv O(n)$ in the worst case scenario. When comparing our BST runtime analysis to our runtime analysis of a `LinkedList`, it's not actually any better, and is in fact almost the same.

*The height of a BST depends on the order in which its nodes were inserted into it*

Take a look at @balance-insertion-order, where the same seven keys are inserted in two different orders: the mixed order gives a tree of height 2, but the sorted order gives a stick of height 6.

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: bottom + center,
    tree((4, (2, 1, 3), (6, 5, 7))),
    tree((1, none, (2, none, (3, none, (4, none, (5, none, (6, none, 7))))))),
    [Insert 4, 2, 6, 1, 3, 5, 7: height 2], [Insert 1, 2, 3, 4, 5, 6, 7: height 6],
  ),
  caption: [Example: the same seven keys. Inserted in a mixed order they form a balanced tree of height $approx log_2 n$; inserted in sorted order every node gets only a right child, giving a "stick" of height $n - 1$ that behaves like a linked list],
) <balance-insertion-order>

Therefore, a BST can still outperform a linked list because its best-case scenario occurs when the tree is *balanced*, resulting in a height that grows *logarithmically* with the number of nodes. In contrast, a `LinkedList`'s best-case scenario still involves traversing a length that grows *linearly* with the number of elements

This means BST operations can be done in $O(log(n))$ time only when *balanced*, whereas a linked list requires $O(n)$ time even in the best case.

For all BST's:

- Its *lower bound* (best case scenario) occurs when $h >= O(log n) equiv h >= O(log_2 n)$
- Its *upper bound* (worst case scenario) occurs when $h <= O(n)$

Previously, we discussed why the upper bound must be at most $O(n)$. But, why is the lower bound at least $O(log n)$?

To explain this, we must understand the structure of a perfect BST, which occurs when each level has twice the number of nodes as the previous level

- Level $0$ (root) has $1$ node
- Level $1$ has $2$ nodes
- Level $2$ has $4$ nodes
- $dots.v$
- Level $h$ has $2^h$ nodes

This also means that level $l$ has $2^l$ nodes

This forms a geometric series, where the number of nodes at level $l$, $n_l$, occurs as a sum of the geometric series of all nodes up to level $l$, where

$ n_l = 1 + 2 + 4 + dots.c + 2^l = sum_(i = 0)^l 2^i $

Since $h = l$ at the maximum level of a tree, the total number of nodes in a BST, $n$, is $2^h$, which can also be represented as a sum of the geometric series of all nodes up to level $h$, where

$ n = 1 + 2 + 4 + dots.c + 2^h = sum_(i = 0)^h 2^i $

The sum of a geometric series is

$ 1 + r + r^2 + dots.c + r^n = sum_(i = 0)^n r^i = (r^(n + 1) - 1) / (r - 1) $

Since $r = 2$,

$ (2^(n + 1) - 1) / (2 - 1) = 2^(n + 1) - 1 $

Solving for $h$,

$
  n &= 2^(h + 1) - 1 \
  n + 1 &= 2^(h + 1) \
  log_2(n + 1) &= h + 1 \
  h &= log_2(n + 1) - 1
$

Ignoring constants, the best case scenario of a BST occurs at a runtime of $O(log n)$

Therefore, BSTs can run faster, only if their height remains close to $O(log n)$

As discussed earlier, a BST's height depends on the number of nodes inserted into it.

If we assume that we have random numbers being inserted into our BST, and choose those random numbers, how many different ways are there?

The simple answer is that there is a lot. Mathematically speaking, if we put $n$ random numbers into our tree, that means we have $n$ choices to choose from for the first number to insert, $n - 1$ for the second (since the first number is now gone), and so on. This means that we have $n!$ sequences to insert into our BST, which results in $n$ unique numbers.

If we looked at every possible sequence and computed its height, its average is $O(log n)$

This is because inserting keys in a random order splits the tree roughly in half at each step, where the tree's height grows the number of times you can halve the keys, which is about $log_2(n) equiv log(n)$

This is delving into the average case runtime of a BST because the time complexity depends on the tree's height, and since the average height of a BST built from random insertions is about $O(log n)$, the average case runtime for these operations is also $O(log n)$

The table below summarizes BST analysis with the average case

#table(
  columns: 5,
  table.header([*Operation*], [*BST Average Case*], [*BST Worst Case*], [*Sorted List*], [*Unsorted List*]),
  [`find`], [$O(log n)$], [$O(h) equiv O(n)$], [$O(log n)$], [$O(n)$],
  [`insert`], [$O(log n)$], [$O(h) equiv O(n)$], [$O(n)$], [$O(1)$],
  [`remove`], [$O(log n)$], [$O(h) equiv O(n)$], [$O(n)$], [$O(n)$],
  [`traverse`], [$O(n)$], [$O(n)$], [$O(n)$], [$O(n)$],
)

We discussed the BST average cases, which make sense when thinking about it in context of permutations.

Some other things to note

+ `find` - Sorted List `find` is $O(log n)$. This is basically performing binary search, since binary search is a more optimal search when a list is sorted. Similarly, unsorted list `find` is $O(n)$, which is simply linear search, which the worst case occurs when the element is found after traversing $n$ times
+ `insert` - Unsorted is $O(1)$, since we can just append an element to the back of a list without maintaining an order, while sorted is $O(n)$ since we have to first insert the element to the back and then shift elements up to $n$ times to make space for the new element
+ `remove` and `traverse` are $O(n)$ for both sorted and unsorted lists since the worst case scenario occurs when having to traverse a maximum of $n$ times

This explains the notion of *balancing* a BST. We want to balance a BST so that its operations come with a cheaper cost of $O(log n)$

To achieve this, we aim for a tree where the number of nodes in the left and right subtrees of every node is roughly equal. This ensures that the height of the tree remains logarithmic in terms of the number of nodes, preventing degeneration into a `LinkedList`

But how??

To *find the balance of a BST node*, you use the concept of a *balance factor* ($b$), where

$ b = "height"(T_R) - "height"(T_L) $

When $b < 0$, the left subtree is taller; when $b > 0$, the right subtree is taller; and when $b = 0$, the tree is perfectly balanced

If $abs(b) > 1$, then the tree is unbalanced

Therefore, a tree is height balanced if $abs(b) <= 1$ or $abs(b) < 2$ at every node. Comparing the two trees in @balance-height-balanced, every node on the left passes this check, but the highlighted 8 on the right has $b = -2$.

#figure(
  grid(
    columns: 2,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: bottom + center,
    tree((8, (4, 2, 6), (10, none, 12))),
    tree((8, (4, (2, 1, none), 6), 10), highlight: (8,)),
    [Height balanced], [Not height balanced],
  ),
  caption: [Example: on the left, 8 has $b = 1 - 1 = 0$ and 10 has $b = 0 - (-1) = 1$, so every $abs(b) <= 1$. On the right, 8 has $b = 0 - 2 = -2$, so the tree is unbalanced even though every other node is fine],
) <balance-height-balanced>
