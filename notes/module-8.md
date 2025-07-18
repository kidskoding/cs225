
# Module 8 - Trees

A **tree** comprises of two things:
1. Its an acyclic graph (has no cycles)
2. It is connected, meaning that there is a unique path from the root to every other node 

A **binary tree**, $T$, is either 
1. A tree composed of a tuple containing the **root**, **left subtree**, and **right subtree**, $T = (r, T_L, T_R)$, where $r, T_L,$ and $T_R$ represent the root, left subtree, and right subtree respectively
2. A **null** tree (there are no nodes in the tree)

A data structure should be able to contain nothing because that is how we tend to start evolving and adding elements/nodes into it. In the context of a tree, we would like to be able to start it off with nothing. Therefore, it makes sense to define a binary tree as a **null** tree, where it has no vertices

A tree's **height**, height($T$), is the shortest path from the root to a leaf. However, this changes a little bit for a binary tree

In a binary tree, it is equal to maximum subtree of the left and right plus 1, or simply 

$$
height(T) = max(height(T_L), height(T_R)) + 1
$$

This makes sense because if $T_L = 5$ and $T_R = 3$, then the whole tree can go at most 5 levels deep through the left. The maximum of the two tells you the **deepest path** from the current node to a leaf. We add 1 because we add the **edge of the root node**.

The height of a null tree is simply -1, because all the math and recursion will work out. Most of the time, the base case in tree recursion occurs when there are no nodes to choose from

A tree is **full** if and only if
1. The tree is empty (has no nodes, or simply $F = \empty$
2. $F = (r, F_L, F_R)$ where either $F_L = F_R = \empty$ or $F_L \neq \empty$ and $F_R \neq \empty$
	- in code, this simply means checking whether the two nodes both have null pointers or neither have null pointers

A **perfect** tree, $P$, is defined in terms of a tree's height (simply because either everything exists at the tree's height or nothing exists). 

If $P_h$ represents a perfect tree with height $h$, then
1. $P_{-1} = \empty$
2. $P_h = (r, P_{h - 1}, P_{h - 1})$, meaning that the height of the left and right subtrees are **equal**

However, if I wanted to build a perfect tree with only 4 nodes, that wouldn't be possible since we have an odd number of nodes remaining after expending 1 for the root node

A **complete** tree is a binary tree where all levels are completely filled except for the last level, which is filled from left to right

More specially, complete trees
1. A perfect tree for every level except the last, where the last level is "pushed to the left"
2. For all levels $k$ in $[0, h - 1]$, $k$ has $2^k$ nodes. For level $h$, all nodes are "pushed to the left"

A complete tree of height $h$, $C_h$
1. $C_{-1}$ = { }
2. $C_h$ (where $h \geq 0$) = {$r, T_L, T_R$} and either:
	- $T_L$ is $C_{h - 1}$ and $T_R$ is $P_{h - 2}$ - given a complete tree with a height $h$, its left subtree must be complete with height $h - 1$ and its right subtree must be perfect with height $h - 2$
	- $T_L$ is $P_{h - 1}$ and $C_{h - 1}$ - given a complete tree with a height $h$, its left subtree must be perfect with height $h - 1$ and its right subtree must be perfect with height $h - 2$

This just mathematically explains the definition of a complete tree, which is simply a perfect tree where every level is filled except the last, which is filled with nodes towards its left subtree

## Tree ADT

Tree ADT involves 3 primary functionalities

1. `insert`, inserts an element to the tree - into a location in structure
2. `remove`, removes an element from a tree - from a location in structure
3. `access`, access elements from a tree - from a location in structure

A list has a fixed structure and order, but a tree has varied structure depending on how it is used. The tree's structure may not matter because many algorithms may still work the same regardless of the tree’s shape, as long as the structure still preserves the necessary relationships.

Therefore, lets think about how we code a `BinaryTree`. An example header file that defines a `BinaryTree` is shown below

```
#pragma once  
template <class T>
class BinaryTree {
public:
	
private:
			
};
```

The first thing we need is a way to store the tree's root. In a `LinkedList`, the way we did it was by having a `ListNode` class to store each node of a list. Trees are similar to lists as well. They also have data stored in nodes, but are in hierarchal order rather than sequential

Therefore, we will also want to use a `struct` here to store each individual `TreeNode`, which will have 3 fields
1. `data` - the data the `TreeNode` holds
2. `left` - a **pointer** to another `TreeNode` that represents the left child (or `nullptr` if no left child)
3. `right` - a **pointer** to another `TreeNode` that represents the right child (or `nullptr` if no right child)

With this, it makes sense for our root to also be a **pointer** to a `TreeNode` as well. By making the left/right children nodes and root nodes pointers, it allows for efficient memory access and avoids copying data unecessarily, allowing the tree to grow dynamically in memory without using too much overhead

In memory, each tree node is created on the heap, and the `root` pointer (on the stack) points to the first node. Each node's `left` and `right` fields store pointers to other nodes on the heap, linking them together without copying any data. This allows the tree to grow dynamically, using memory only when needed.
<!--stackedit_data:
eyJoaXN0b3J5IjpbNjUzNTgxOTM3LC02NTQ3NTEzNiwtMzk1Mj
AwODc4LDEwMTQxNDA5MywxNDk3MDIwMTQyLDQ1MTgyNTM4OSwt
ODQyNDY0MjE3LDM1Nzg2ODQ3OSwyMTI1MDA2MjUsLTI5MTg4ND
E3N119
-->