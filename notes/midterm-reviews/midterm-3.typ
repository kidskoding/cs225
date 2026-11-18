#import "../diagrams.typ": btree, steps, tree

= Midterm 3: AVL Trees and BTrees

Midterm 3 covers modules 8-14, 17, and 18. It goes back over trees and BSTs from Midterm 2, then adds balance, AVL trees, and BTrees

== Topics Covered

- Trees
  - Basic tree terminology (CS 173)
  - Tree Property: Binary
  - Tree Property: Height
  - Tree Property: Full
  - Tree Property: Perfect
  - Tree Property: Complete (as defined in data structures)
  - Tree Property: `NULL` pointers in a BST, including proof
  - Traversal: Pre-Order, In-Order, and Post-Order
  - Traversal: Level-Order
  - Search Strategy: BFS, DFS
- Binary Search Tree
  - Difference between a "Tree" and a "BST"
  - Operation `find`, including running times in terms of $h$ and $n$
  - Operation `insert`, including running times in terms of $h$ and $n$
  - Operation `delete`, including running times in terms of $h$ and $n$
  - A clear understanding of `delete` (particularly two-child `delete`)
  - BST Property: Min/max nodes in a tree of a given $h$, and properties
  - BST Property: Height balance factor, $b$
- AVL
  - Difference between a "Tree", "BST", and an "AVL"
  - Operation `find`, including running times in terms of $h$ and $n$
  - Operation `insert`, including running times in terms of $h$ and $n$
  - Operation `delete`, including running times in terms of $h$ and $n$
  - Strategy for a 2-child `delete`
  - AVL Tree Rotations
  - Minimum/maximum nodes in an AVL tree
- BTree
  - Difference between a key and a node in a BTree
  - The order of a BTree
  - Structural properties of a BTree
  - BTree insertion and find algorithms (NOT remove!)

== Trees

=== Key Ideas

- *Tree*: a connected graph with no cycles. $n$ nodes means $n - 1$ edges, and there's exactly one path between any two nodes
- *Root*, *parent* and *child*, *sibling* (same parent), *leaf* (no children), *internal node* (at least one child), *ancestor* and *descendant*, *subtree* (a node plus everything below it), *level* or *depth* (edges from the root, so the root is level 0)
- *Binary tree*: either empty ($T = emptyset$) or $T = (r, T_L, T_R)$ where both subtrees are binary trees. At most 2 children per node
- *Height*: edges on the longest root-to-leaf path. $"height"(emptyset) = -1$ and $"height"(T) = 1 + max("height"(T_L), "height"(T_R))$, so a single node has height 0
- *Full*: every node has 0 or 2 children (never exactly 1)
- *Perfect*: $P_(-1) = emptyset$, $P_h = (r, P_(h - 1), P_(h - 1))$. Every level is full, so it has $2^(h + 1) - 1$ nodes
- *Complete*: every level is full except possibly the last, and the last level is pushed left. Formally $C_h = (r, T_L, T_R)$ with either $T_L = C_(h - 1), T_R = P_(h - 2)$ or $T_L = P_(h - 1), T_R = C_(h - 1)$
- Every perfect tree is full and complete. The reverse isn't true (see @m3-full-perfect-complete)

#figure(
  grid(
    columns: 3,
    column-gutter: 3em,
    row-gutter: 0.8em,
    scale(70%, reflow: true, tree((1, 2, (3, 4, 5)))),
    scale(70%, reflow: true, tree((1, (2, 4, 5), (3, 6, 7)))),
    scale(70%, reflow: true, tree((1, (2, 4, 5), (3, 6, none)))),
    [Full], [Perfect ($P_2$)], [Complete ($C_2$)],
  ),
  caption: [The full tree isn't complete (its last level isn't pushed left), and the complete tree isn't full (3 has one child)],
) <m3-full-perfect-complete>

=== `NULL` Pointers

*Claim*: a binary tree with $n$ nodes has $n + 1$ null pointers (an empty tree has 1, the `root` pointer)

*Proof* (induction on $n$). Let $"NULLS"(n)$ be the number of null pointers in a binary tree with $n$ nodes

+ *Base case*: $n = 0$. Only the `root` pointer exists and it's null, so $"NULLS"(0) = 1$
+ *Inductive hypothesis*: any binary tree with $n - 1$ nodes has $n$ null pointers
+ *Inductive step*: take a tree with $n >= 1$ nodes and remove a leaf. The smaller tree has $n - 1$ nodes, so it has $n$ nulls. Put the leaf back: it fills one null pointer ($-1$) and brings two null children of its own ($+2$). Total $n - 1 + 2 = n + 1$ $qed$

=== Traversals and Search

A traversal visits every node, so it's always $O(n)$. The three depth-first ones only differ in when the node gets visited

#figure(
  grid(
    columns: 2,
    column-gutter: 1.5em,
    align: horizon,
    scale(70%, reflow: true, tree((4, (2, 1, 3), (6, 5, 7)))),
    table(
      columns: 3,
      table.header([*Traversal*], [*Order*], [*Result*]),
      [Pre-order], [Node, Left, Right], [4, 2, 1, 3, 6, 5, 7],
      [In-order], [Left, Node, Right], [1, 2, 3, 4, 5, 6, 7],
      [Post-order], [Left, Right, Node], [1, 3, 2, 5, 7, 6, 4],
      [Level-order], [Level by level], [4, 2, 6, 1, 3, 5, 7],
    ),
  ),
  caption: [Example: all four traversals on the same tree. Mnemonics: NLR, LNR, LRN],
) <m3-traversals>

- *DFS*: pre/in/post-order. Goes down one path fully before backing up. Uses recursion (a stack), extra memory is about the height
- *BFS*: level-order. Uses a *queue*, extra memory is the widest level. It always finds a node that exists, even in an infinitely deep tree, where DFS can get stuck down one branch

*Code you should be able to write*

```cpp
template <typename T>
void BinaryTree<T>::inOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }
    inOrderTraversal(curr->left);
    std::cout << curr->data << " ";    // move this line for pre/post-order
    inOrderTraversal(curr->right);
}

template <typename T>
void BinaryTree<T>::levelOrderTraversal() {
    std::queue<TreeNode*> q;
    q.push(root);
    while(!q.empty()) {
        TreeNode* n = q.front();
        q.pop();
        if(n != nullptr) {
            std::cout << n->data << " ";
            q.push(n->left);
            q.push(n->right);
        }
    }
}
```

*Common mistakes*

- Counting height in nodes instead of edges. A single node is height 0, and an empty tree is $-1$
- Calling a tree complete when the last level has a gap on the left. Also, CS 173's "complete" (all leaves on one level) is our *perfect*
- Using a stack for level-order. BFS needs a FIFO queue
- Forgetting the empty-tree base case in the `NULL` proof. That's the case where the `root` pointer itself is the one null

== Binary Search Trees

=== Key Ideas

- *BST*: a binary tree where every key in the left subtree is smaller than the node and every key in the right subtree is larger. It has to hold for the *whole* subtree, not just the direct children. We assume no duplicates
- A plain binary tree gives you no clue where a key is, so `find` checks every node. A BST lets you follow one path down
- In-order on a BST gives the keys in sorted order
- `_find` returns a *reference to the pointer* (`TreeNode*&`) at the key, or the null pointer where the key would go. `insert` assigns a new node into that null pointer, so new nodes are always leaves
- `remove` has three cases once the node is found
  + *Leaf*: delete it, and the parent's pointer becomes null
  + *One child*: the parent points at the only child instead
  + *Two children*: swap with the *in-order predecessor* (IOP), the largest key in the left subtree (go left once, then right until you can't). Then remove from the left subtree. The IOP has no right child, so that second remove is always case 1 or 2
- *Height bounds* for $n$ nodes - fewest nodes for height $h$ is $h + 1$ (a stick), most is $2^(h + 1) - 1$ (perfect). Flip those around and $log_2(n + 1) - 1 <= h <= n - 1$
- Height depends on *insertion order*. Sorted inserts make a stick of height $n - 1$, and random inserts average $O(log n)$
- *Balance factor*: $b = "height"(T_R) - "height"(T_L)$. $b < 0$ means left-heavy, $b > 0$ means right-heavy. A tree is *height balanced* when $abs(b) <= 1$ at *every* node

=== Runtimes

#table(
  columns: 3,
  table.header([*Operation*], [*In terms of $h$*], [*In terms of $n$ (worst case)*]),
  [`find`], [$O(h)$], [$O(n)$],
  [`insert`], [$O(h)$], [$O(n)$],
  [`remove`], [$O(h)$], [$O(n)$],
  [Traversal], [$O(n)$], [$O(n)$],
)

All three operations walk a single path down (the two-child remove keeps going down to the IOP), so they're $O(h)$. A BST can be a stick, so $O(h) equiv O(n)$ in the worst case

=== Code You Should Be Able to Write

```cpp
template <typename K, typename V>
typename BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {
    if(root == nullptr || root->key == key) { return root; }
    if(root->key > key) { return _find(root->left, key); }
    return _find(root->right, key);
}

template <class K, class V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
    _find(root, key) = new TreeNode(key, value);
}
```

```cpp
template <typename K, typename V>
void BST<K, V>::_remove(TreeNode*& node, const K& key) {
    if(node == nullptr) { return; }
    if(key < node->key) { _remove(node->left, key); }
    else if(key > node->key) { _remove(node->right, key); }
    else {
        if(node->left == nullptr && node->right == nullptr) {  // leaf
            delete node;
            node = nullptr;
        } else if(node->left == nullptr) {    // only a right child
            TreeNode* tmp = node; node = node->right; delete tmp;
        } else if(node->right == nullptr) {   // only a left child
            TreeNode* tmp = node; node = node->left; delete tmp;
        } else {                              // two children
            K iop_key = node->key;
            TreeNode* iop = _iop(node);
            _swap(iop, node);
            _remove(node->left, iop_key);
        }
    }
}
```

#figure(
  grid(
    columns: 5,
    column-gutter: 1.5em,
    row-gutter: 0.8em,
    align: horizon + center,
    scale(70%, reflow: true, tree((15, (8, 4, (12, 10, none)), 25), highlight: (15, 12))),
    $->$,
    scale(70%, reflow: true, tree((12, (8, 4, (15, 10, none)), 25), highlight: (15,))),
    $->$,
    scale(70%, reflow: true, tree((12, (8, 4, 10), 25))),
    [IOP of 15 is 12], [], [Swap], [], [Remove 15 (one child)],
  ),
  caption: [Example: removing 15, which has two children. After swapping with its IOP 12, the node holding 15 only has a left child],
) <m3-bst-remove>

*Common mistakes*

- Checking the BST property only against the parent. A node deep in the left subtree still has to be smaller than the root
- Picking the IOP from the right subtree. The IOP is the *largest in the left* subtree (the IOS is the smallest in the right)
- Writing `TreeNode* loc = _find(...)` without the `&`. That's a copy, so assigning to it doesn't change the tree
- Saying BST operations are $O(log n)$. That's only true when the tree is balanced. The worst case is $O(n)$
- Using 0 for an empty subtree's height when computing $b$. It's $-1$, so a leaf has $b = 0$

== AVL Trees

=== Key Ideas

- *Tree vs. BST vs. AVL*: a BST adds the ordering rule to a binary tree. An AVL tree is a BST that also keeps $abs(b) <= 1$ at every node, so its height is always $O(log n)$
- Each node stores its own `height` so $b$ can be found in $O(1)$. A null child counts as height $-1$
- A *rotation* reshapes a subtree without breaking the BST property. It only rewires a few pointers, so it's $O(1)$, and nothing outside that subtree changes
- *L rotation*: the right child moves up and its old left subtree becomes the old root's right subtree. *R* is the mirror. Update the old root's height first, then the new root's
- *LR* = L about the left child, then R about the node. *RL* = R about the right child, then L about the node

#table(
  columns: 4,
  table.header([*Shape*], [*$b$ of node*], [*$b$ of the taller child*], [*Rotation*]),
  [Right stick], [$+2$], [right child $>= 0$], [L],
  [Right elbow], [$+2$], [right child $-1$], [RL],
  [Left stick], [$-2$], [left child $<= 0$], [R],
  [Left elbow], [$-2$], [left child $+1$], [LR],
)

The child can only have $b = 0$ after a `remove`. It gets a single rotation, which is why the code checks $>= 0$ and $<= 0$ instead of exactly $plus.minus 1$

#figure(
  scale(70%, reflow: true, steps((6, (4, (2, 1, 3), 5), 7), (4, (2, 1, 3), (6, 5, 7)), highlight: (5,))),
  caption: [Example: an R rotation about 6. 4 rises, 6 drops to its right, and 5 (the old right subtree of 4) is handed over to 6 as its left subtree],
) <m3-rotation>

=== Operations

- `find`: exactly BST `find`. It never changes the tree
- `insert`: BST insert, then on the way back up the recursion call `_ensureBalance` on every node of the path. That checks $b$, rotates when $abs(b) = 2$, and updates the height. An insert needs *at most one* rotation (single or double)
- `delete`: BST `remove` first. Then, just like `_insert`, `_remove` calls `_ensureBalance` on each node as the recursion unwinds, because removing a node can unbalance *every* ancestor up to the root. So one delete may rotate at several of those nodes, up to $O(log n)$ rotations
- *2-child delete*: same strategy as the BST: swap with the IOP, remove from the left subtree (now an easy case), then rebalance every node on the path back up. The child $b = 0$ case from the table can show up here

*Runtimes*: `find`, `insert`, and `delete` are all $O(h)$, since each walks one path down and back up with $O(1)$ work per node. An AVL tree always has $h = O(log n)$, so all three are $O(log n)$

=== Code You Should Be Able to Write

```cpp
template <typename K, typename V>
void AVL<K, V>::_rotateLeft(TreeNode*& root) {
    TreeNode* newRoot = root->right;
    root->right = newRoot->left;
    newRoot->left = root;
    _updateHeight(root);       // old root is lower now, so it goes first
    _updateHeight(newRoot);
    root = newRoot;
}
```

```cpp
template <typename K, typename V>
void AVL<K, V>::_ensureBalance(TreeNode*& curr) {
    int balance = height(curr->right) - height(curr->left);
    if(balance == -2) {
        int leftBalance = height(curr->left->right) - height(curr->left->left);
        if(leftBalance <= 0) { _rotateRight(curr); }     // left stick
        else { _rotateLeftRight(curr); }                 // left elbow
    } else if(balance == 2) {
        int rightBalance = height(curr->right->right) - height(curr->right->left);
        if(rightBalance >= 0) { _rotateLeft(curr); }     // right stick
        else { _rotateRightLeft(curr); }                 // right elbow
    }
    _updateHeight(curr);
}
```

`_insert` is BST insert with `_ensureBalance(curr);` as its last line, so it runs on every node on the way back up

=== Minimum/Maximum Nodes

- *Max nodes* for height $h$ - $2^(h + 1) - 1$, a perfect tree (which is balanced)
- *Min nodes*, $N(h)$ - a root, the smallest AVL tree of height $h - 1$ on one side, and the smallest of height $h - 2$ on the other

$ N(h) = 1 + N(h - 1) + N(h - 2), quad N(-1) = 0, quad N(0) = 1 $

#table(
  columns: 8,
  table.header([$h$], [$-1$], [$0$], [$1$], [$2$], [$3$], [$4$], [$5$]),
  [Min, $N(h)$], [$0$], [$1$], [$2$], [$4$], [$7$], [$12$], [$20$],
  [Max, $2^(h + 1) - 1$], [$0$], [$1$], [$3$], [$7$], [$15$], [$31$], [$63$],
)

*Why $h = O(log n)$*: $N(h - 1) > N(h - 2)$, so $N(h) > 2 N(h - 2)$. The minimum at least doubles every two levels. Induction (base cases $N(1) = 2 >= 2^(1/2)$ and $N(2) = 4 >= 2^1$, step $N(h) > 2 dot 2^((h - 2)/2) = 2^(h/2)$) gives $n >= N(h) >= 2^(h/2)$, so $h <= 2 log_2 n$

*Common mistakes*

- Rotating about the wrong node. Fix the *lowest* unbalanced node on the path back up, not the root
- Using a single rotation on an elbow. If the taller child leans the other way, you need LR or RL
- Forgetting to update heights after a rotation, or updating the new root before the old root
- Saying a delete needs at most one rotation. That's only true for insert. Delete can rotate at $O(log n)$ nodes, but it's still $O(log n)$ total

== BTrees

=== Key Ideas

- *Why*: when following a pointer is a disk *seek* or a network trip, each one costs millions of instructions. A BTree packs many keys into each node so the tree is very short. We only count seeks
- *Key vs. node*: a *key* is one value. A *node* is one block fetched with a single seek, holding several sorted keys plus child pointers. If an internal node holds $k$ keys, it has $k + 1$ children
- *Order $m$*: an $m$-way tree. Each node has at most $m$ children and at most $m - 1$ keys (a preallocated array). A node with $m$ keys is *overfilled* and splits. $m$ is chosen so a node fills one disk block or network packet
- *Structural properties*
  - Keys in a node are sorted
  - All leaves are on the same level. The tree only grows when the root splits
  - The root can have just 1 key, so it's a leaf or has 2 to $m$ children
  - A non-root internal node needs $ceil(m / 2)$ or more children, which means any non-root node holds $ceil(m / 2) - 1$ or more keys
- *Height*: with $b = ceil(m / 2)$, the fewest keys a tree of height $h$ can have is $2 b^h - 1$. So $n >= 2 ceil(m / 2)^h - 1$ and $h = O(log_m n)$
- `find`: in each node, find the first key not smaller than the target. If it matches, done. If the node is a leaf, it isn't there. Otherwise fetch that child (left of that key) and repeat
- `insert`: always goes into a *leaf*. If the leaf hits $m$ keys, the *middle* key goes up to the parent (or becomes a new root) and the rest split into a left and right node. Splits can cascade up. Even $m$ has two middle keys and either works, which is why odd $m$ is usual
- `remove` isn't covered

*Runtimes*: `find` and `insert` both take $O(log_m n)$ seeks, plus $O(m)$ work inside each node they touch

=== Code You Should Be Able to Write

```cpp
template <typename K>
bool BTree<K>::_exists(BTreeNode& node, const K& key) {
    unsigned i;
    for(i = 0; i < node.keys_ct_ && key > node.keys_[i]; i++) { }

    if(i < node.keys_ct_ && key == node.keys_[i]) { return true; }
    if(node.isLeaf()) { return false; }

    BTreeNode nextChild = node._fetchChild(i);    // the seek
    return _exists(nextChild, key);
}
```

#figure(
  grid(
    columns: 3,
    column-gutter: 1em,
    row-gutter: 0.6em,
    align: horizon + center,
    scale(80%, reflow: true, btree(("23 42", "10", "30", "43 55 79"))),
    $->$,
    scale(80%, reflow: true, btree(("23 42 55", "10", "30", "43", "79"))),
    [Leaf overfills], [], [55 goes up],
    grid.cell(colspan: 3, scale(80%, reflow: true, btree(("42", ("23", "10", "30"), ("55", "43", "79"))))),
    grid.cell(colspan: 3)[42 goes up],
  ),
  caption: [Example: inserting 79 into a BTree of order 3. The leaf overfills and 55 goes up, which overfills the root, so 42 becomes a new root],
) <m3-btree-cascade>

*Common mistakes*

- Mixing up keys and nodes. Order $m$ limits *children* to $m$, so keys max out at $m - 1$
- Inserting into an internal node. New keys always land in a leaf; only splits push keys up
- Splitting when a node reaches $m - 1$ keys. That's full but legal. It only splits at $m$
- Using $floor(m / 2)$ for the minimum children. It's $ceil(m / 2)$, and that rule doesn't apply to the root

== Runtime Summary

#table(
  columns: 4,
  table.header([*Operation*], [*BST*], [*AVL*], [*BTree (seeks)*]),
  [`find`], [$O(h) = O(n)$], [$O(log n)$], [$O(log_m n)$],
  [`insert`], [$O(h) = O(n)$], [$O(log n)$], [$O(log_m n)$],
  [`delete`], [$O(h) = O(n)$], [$O(log n)$], [Not covered],
  [Traversal], [$O(n)$], [$O(n)$], [$O(n)$],
)

== Practice Problems

+ Insert 50, 30, 70, 20, 40, 60, 80, 35 into an empty BST (no balancing). Give the pre-order, in-order, post-order, and level-order traversals. What is the height? Is the tree full, perfect, or complete?

  *Answer:* 35 goes left of 50, right of 30, then left of 40, so the tree is 50 (30 (20, 40 (35, -)), 70 (60, 80)). Pre-order: 50, 30, 20, 40, 35, 70, 60, 80. In-order: 20, 30, 35, 40, 50, 60, 70, 80. Post-order: 20, 35, 40, 30, 60, 80, 70, 50. Level-order: 50, 30, 70, 20, 40, 60, 80, 35. The height is 3 (path 50, 30, 40, 35). It's not full (40 has one child), not perfect, and not complete (35 is on the last level but the spots under 20 to its left are empty)

+ For the tree in problem 1, give $b$ for every node. Is it an AVL tree?

  *Answer:* Leaves 20, 35, 60, 80 have $b = 0$. 40: $-1 - 0 = -1$. 30: $"height"(40) - "height"(20) = 1 - 0 = +1$. 70: $0 - 0 = 0$. 50: $"height"(70) - "height"(30) = 1 - 2 = -1$. Every $abs(b) <= 1$ and it's a BST, so yes, it's a valid AVL tree

+ Remove 50 from the tree in problem 1 using the IOP. Draw the result

  *Answer:* 50 has two children. Its IOP is the rightmost node of the left subtree: from 30 go right to 40, and 40 has no right child, so the IOP is 40. Swap 50 and 40, then remove 50 from the left subtree. It now sits where 40 was with only the left child 35, so 30's right pointer goes to 35. Result:

  #align(center, scale(70%, reflow: true, tree((40, (30, 20, 35), (70, 60, 80)))))

+ True or false? Justify each
  - (a) A binary tree with 1000 nodes always has 1001 null pointers, no matter its shape
  - (b) BST `find` is $O(log n)$
  - (c) An in-order traversal of an AVL tree is $O(log n)$
  - (d) An AVL `insert` can need rotations at more than one node
  - (e) An AVL `delete` is still $O(log n)$ even though it can rotate at several nodes

  *Answer:* (a) True, it's $n + 1$ for every binary tree (proved above). (b) False, it's $O(h)$, and a stick has $h = n - 1$, so the worst case is $O(n)$. (c) False, a traversal visits all $n$ nodes, so it's $O(n)$ for any tree. (d) False, an insert needs at most one rotation (single or double). A delete is the one that can need several. (e) True. A delete is BST remove plus one `_ensureBalance` call per node on the path back up, and each call is $O(1)$ even when it rotates. The path has $O(h) = O(log n)$ nodes

+ What are the fewest and most nodes in a BST of height 4? In an AVL tree of height 4? What is the tallest possible AVL tree with 12 nodes? With 11? What are the smallest and largest heights of a BST with 100 nodes?

  *Answer:* BST: fewest $h + 1 = 5$ (a stick), most $2^5 - 1 = 31$. AVL: fewest $N(4) = 1 + N(3) + N(2) = 1 + 7 + 4 = 12$, most 31. With 12 nodes the height can be 4, since $N(4) = 12$, but not 5, since $N(5) = 20$. With 11 nodes the height is at most 3, since even height 4 needs 12 nodes. A BST with 100 nodes is at most $n - 1 = 99$ tall (a stick). For the shortest, height 5 holds at most $2^6 - 1 = 63$ nodes and height 6 holds 127, so the smallest height is 6

+ Insert 30, 10, 20, 40, 50, 35 into an empty AVL tree. Name each rotation and draw the final tree

  *Answer:*
  - After 20: 30 has $b = -2$ and its left child 10 has $b = +1$, a left elbow. *LR about 30* gives 20 (10, 30)
  - After 40: 30 has $b = +1$, 20 has $b = +1$. No rotation
  - After 50: 30 has $b = +2$ and its right child 40 has $b = +1$, a right stick. *L about 30* gives 20 (10, 40 (30, 50))
  - After 35 (left of 40, right of 30): 30 has $b = +1$ and height 1, 40 has $b = 0 - 1 = -1$ and height 2, and 20 has $b = 2 - 0 = +2$. The right child leans left, a right elbow, so *RL about 20*: R about 40 gives 30 (-, 40 (35, 50)), then L about 20 gives the tree below. Final balances: 20 is $-1$, 40 is 0, 30 is 0

  #align(center, scale(70%, reflow: true, tree((30, (20, 10, none), (40, 35, 50)))))

+ The AVL tree 20 (10, 30 (25, 35)) is valid (heights: leaves 0, 30 is 1, 20 is 2, $b(20) = +1$). Remove 10. Which rotation does `_ensureBalance` do, and what is the result?

  *Answer:* 10 is a leaf, so it's just deleted. Back at 20, $b = "height"(30) - "height"(emptyset) = 1 - (-1) = +2$. The right child 30 has $b = 0 - 0 = 0$, and since `rightBalance >= 0`, it's a single *L rotation about 20*. 30 moves up, 30's old left child 25 becomes 20's right child, and 20 goes under 30 on the left. New heights: 25 and 35 are 0, 20 is $1 + max(-1, 0) = 1$, 30 is $1 + max(1, 0) = 2$. Balances: 20 is $+1$, 30 is $-1$. This child $b = 0$ case can't come from an insert

  #align(center, scale(70%, reflow: true, tree((30, (20, none, 25), 35))))

+ Insert 10, 20, 30, 40, 50, 60, 70 into an empty BTree of order 3. Draw the final tree. How many keys and how many nodes does it have?

  *Answer:* Order 3 means at most 2 keys, so a node splits when it gets 3. Inserting 30 splits [10 20 30], and 20 becomes the root. 40 joins [30]. 50 splits [30 40 50], and 40 goes up to make the root [20 40]. 60 joins [50]. 70 splits [50 60 70] and 60 goes up, which makes the root [20 40 60] overfill, so 40 becomes a new root. It ends up with 7 keys in 7 nodes, height 2

  #align(center, scale(70%, reflow: true, btree(("40", ("20", "10", "30"), ("60", "50", "70")))))

+ For a BTree of order 7, give the range of keys in a non-root node and of children in a non-root internal node. What is the fewest keys a tree of height 2 can have?

  *Answer:* Keys go from $ceil(7 / 2) - 1 = 3$ to $7 - 1 = 6$. Children go from $ceil(7 / 2) = 4$ to 7. With $b = 4$, the fewest keys is $2 dot 4^2 - 1 = 31$. Checking by levels: the root has 1 key and 2 children, those have 3 keys each (6 keys) and 4 children each, and those 8 leaves have 3 keys each (24 keys). $1 + 6 + 24 = 31$

+ Write `bool isFull(TreeNode* curr)`, which returns whether the tree is full. What is its runtime?

  *Answer:* A node with exactly one null child breaks the rule. Otherwise check both subtrees. It can visit every node, so it's $O(n)$

  ```cpp
  bool isFull(TreeNode* curr) {
      if(curr == nullptr) { return true; }
      if((curr->left == nullptr) != (curr->right == nullptr)) { return false; }
      return isFull(curr->left) && isFull(curr->right);
  }
  ```
