#import "../diagrams.typ": tree

= Trees

A *tree* comprises of two things:

+ It's an acyclic graph (has no cycles)
+ It is connected, meaning that there is a unique path from the root to every other node

A *binary tree*, $T$, is either

+ A tree composed of a tuple containing the *root*, *left subtree*, and *right subtree*, $T = (r, T_L, T_R)$, where $r$, $T_L$, and $T_R$ represent the root, left subtree, and right subtree respectively
+ A *null* tree (there are no nodes in the tree)

A data structure should be able to contain nothing because that is how we tend to start evolving and adding elements/nodes into it. In the context of a tree, we would like to be able to start it off with nothing. Therefore, it makes sense to define a binary tree as a *null* tree, where it has no vertices

A tree's *height*, height($T$), is the longest path from the root to a leaf. However, this changes a little bit for a binary tree

In a binary tree, it is equal to maximum subtree of the left and right plus 1, or simply

$ "height"(T) = max("height"(T_L), "height"(T_R)) + 1 $

This makes sense because if $T_L = 5$ and $T_R = 3$, then the whole tree can go at most 5 levels deep through the left. The maximum of the two tells you the *deepest path* from the current node to a leaf. We add 1 because we add the *edge of the root node*. Let's try this on the tree in @tree-height-example, where the left subtree rooted at $B$ is the taller one, so it decides the height of the whole tree.

#figure(
  grid(
    columns: 3,
    column-gutter: 3em,
    row-gutter: 0.8em,
    align: bottom + center,
    tree(("A", ("B", ("D", "G", none), "E"), ("C", none, "F")), highlight: ("G", "E", "F")),
    tree(("B", ("D", "G", none), "E"), highlight: ("G", "E")),
    tree(("C", none, "F"), highlight: ("F",)),
    [$T$, root $A$], [$T_L$, height 2], [$T_R$, height 1],
  ),
  caption: [Example: the leaves (no children) are highlighted. The longest path from $A$ is $A, B, D, G$, so $"height"(T) = max(2, 1) + 1 = 3$],
) <tree-height-example>

The height of a null tree is simply -1, because all the math and recursion will work out. Most of the time, the base case in tree recursion occurs when there are no nodes to choose from

A tree is *full* if and only if

+ The tree is empty (has no nodes, or simply $F = emptyset$)
+ $F = (r, F_L, F_R)$ where either $F_L = F_R = emptyset$ or $F_L != emptyset$ and $F_R != emptyset$
  - in code, this simply means checking whether the two nodes both have null pointers or neither have null pointers

A *perfect* tree, $P$, is defined in terms of a tree's height (simply because either everything exists at the tree's height or nothing exists).

If $P_h$ represents a perfect tree with height $h$, then

+ $P_(-1) = emptyset$
+ $P_h = (r, P_(h - 1), P_(h - 1))$, meaning that the height of the left and right subtrees are *equal*

However, if I wanted to build a perfect tree with only 4 nodes, that wouldn't be possible since we have an odd number of nodes remaining after expending 1 for the root node

A *complete* tree is a binary tree where all levels are completely filled except for the last level, which is filled from left to right

More specially, complete trees

+ A perfect tree for every level except the last, where the last level is "pushed to the left"
+ For all levels $k$ in $[0, h - 1]$, $k$ has $2^k$ nodes. For level $h$, all nodes are "pushed to the left"

A complete tree of height $h$, $C_h$

+ $C_(-1) = {}$
+ $C_h$ (where $h >= 0$) $= {r, T_L, T_R}$ and either:
  - $T_L$ is $C_(h - 1)$ and $T_R$ is $P_(h - 2)$ - given a complete tree with a height $h$, its left subtree must be complete with height $h - 1$ and its right subtree must be perfect with height $h - 2$
  - $T_L$ is $P_(h - 1)$ and $T_R$ is $C_(h - 1)$ - given a complete tree with a height $h$, its left subtree must be perfect with height $h - 1$ and its right subtree must be complete with height $h - 1$

This just mathematically explains the definition of a complete tree, which is simply a perfect tree where every level is filled except the last, which is filled with nodes towards its left subtree

If you compare the three trees in @tree-full-perfect-complete, the complete tree is just the perfect tree with its rightmost leaf (7) missing.

#figure(
  grid(
    columns: 3,
    column-gutter: 3em,
    row-gutter: 0.8em,
    tree((1, 2, (3, 4, 5))),
    tree((1, (2, 4, 5), (3, 6, 7))),
    tree((1, (2, 4, 5), (3, 6, none))),
    [Full], [Perfect ($P_2$)], [Complete ($C_2$)],
  ),
  caption: [A full, a perfect, and a complete binary tree],
) <tree-full-perfect-complete>

== Tree ADT

Tree ADT involves 3 primary functionalities

+ `insert`, inserts an element to the tree - into a location in structure
+ `remove`, removes an element from a tree - from a location in structure
+ `access`, access elements from a tree - from a location in structure

A list has a fixed structure and order, but a tree has varied structure depending on how it is used. The tree's structure may not matter because many algorithms may still work the same regardless of the tree's shape, as long as the structure still preserves the necessary relationships.

Therefore, let's think about how we code a `BinaryTree`. An example header file that defines a `BinaryTree` is shown below

```cpp
// BinaryTree.h

#pragma once
template <class T>
class BinaryTree {
public:

private:

};
```

The first thing we need is a way to store the tree's root. In a `LinkedList`, the way we did it was by having a `ListNode` class to store each node of a list. Trees are similar to lists as well. They also have data stored in nodes, but are in hierarchical order rather than sequential

Therefore, we will also want to use a `struct` here to store each individual `TreeNode`, which will have 3 fields

+ `data` - the data the `TreeNode` holds
+ `left` - a *pointer* to another `TreeNode` that represents the left child (or `nullptr` if no left child)
+ `right` - a *pointer* to another `TreeNode` that represents the right child (or `nullptr` if no right child)

The code for a `TreeNode` is reflected below

```cpp
struct TreeNode {
    // the data each tree node holds
    T data;

    // a pointer to the left child `TreeNode` (or `nullptr` if non-existent)
    TreeNode* left;

    // a pointer to the right child `TreeNode` (or `nullptr` if non-existent)
    TreeNode* right;
};
```

With this, it makes sense for our root to also be a *pointer* to a `TreeNode` as well. By making the left/right children nodes and root nodes pointers, it allows for efficient memory access and avoids copying data unnecessarily, allowing the tree to grow dynamically in memory without using too much overhead. The `BinaryTree` class is reflected below

```cpp
// BinaryTree.h

template <class T>
class BinaryTree {
private:
    struct TreeNode {
        // the data each tree node holds
        T data;

        // a pointer to the left child `TreeNode` (or `nullptr` if non-existent)
        TreeNode* left;

        // a pointer to the right child `TreeNode` (or `nullptr` if non-existent)
        TreeNode* right;
    };

    // a pointer to the root node of a tree
    TreeNode* root;
};
```

In memory, each tree node is created on the heap, and the `root` pointer (on the stack) points to the first node. Each node's `left` and `right` fields store pointers to other nodes on the heap, linking them together without copying any data. This allows the tree to grow dynamically, using memory only when needed.

When we create a tree in memory, there is often wasted space because child pointers in many nodes can point to `null`, meaning they don't reference any actual node. Knowing *how many nodes store these null pointers* helps us understand the *memory overhead* and measure how *efficient* our tree data structure is.

In contrast, with a `LinkedList`, we only had to worry about one pointer per node possibly being null (the `next` pointer), so the overhead was much simpler and easier to quantify (it was always 1)

Therefore, it makes sense to *prove how many null pointers exist in a tree* to analyze and optimize its memory usage and better understand the structure's efficiency.

There will always be $n + 1$ `NULL` pointers for $n$ nodes in our binary tree. But why?

Prove that if there are $n$ data items in our representation of a binary tree, then there are $n + 1$ `NULL` pointers (Hint: use induction on $n$)

+ Let $"NULLS"(n)$ be defined as the number of null pointers in a tree of size $n$
+ *Base Case(s)*
  - $n = 0: 1$ null pointer; ($n + 1 = 0 + 1 = 1$) (the tree is empty so the `root` pointer is null)
  - $n = 1: 2$ null pointers; ($n + 1 = 1 + 1 = 2$) (there is only the root node and both `left` and `right` child pointers are null)
  - $n = 2: 3$ null pointers; ($n + 1 = 2 + 1 = 3$) (One node has two children - one child node and one null child - and the child node has two null pointers, totaling 3)
+ *Induction Hypothesis*: Suppose $"NULLS"(n) = n + 1$ for all $0 <= n < k$
+ *Inductive Step*: Prove for $n = k + 1$ nodes
  - Consider any binary tree with $k + 1$ nodes
  - Remove a leaf node (or any node that can be removed while keeping a valid binary tree structure), resulting in a tree with $k$ nodes
  - By the inductive hypothesis, this smaller tree has $k + 1$ null pointers
  - When adding back the removed node:
    - One null pointer (where the node was attached) is replaced by a new node, so we lose 1 null pointer
    - The newly added node has two child pointers, both null, so we add two null pointers
  - Therefore, the *total null pointers* = $(k + 1) - 1 + 2 = k + 2$
  - Which equals: $(k + 1) + 1$
  - Therefore, by induction this statement holds true for $n >= 0$
