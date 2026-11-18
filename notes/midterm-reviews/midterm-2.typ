#import "../diagrams.typ": array-cells, tree

= Midterm 2: Trees and Binary Search Trees

Midterm 2 covers modules 1-11. Expect pointers and references, the two list implementations, stacks and queues, tree properties and traversals, and a lot of Binary Search Tree `find`, `insert`, and `remove`

== Topics Covered

- Pointers and References in C++
- Pass by value, by reference, and by pointer
- Lists
  - ADT
  - Linked
  - Array
- Stacks and Queues
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

== Pointers and References

=== Key ideas

- *Reference* (`int& r = x;`) - another name for `x`. Same box in memory, so writing to `r` writes to `x`
- *Pointer* (`int* p = &x;`) - its own variable whose value is the address of `x`
- `&x`: the address of `x`. `*p`: follow the address and get the value there
- `nullptr`: a pointer to nothing. Dereferencing it is undefined behavior (usually a segfault)
- *Dangling pointer*: still holds the address of memory that was `delete`d. Set it to `nullptr` after `delete`
- `TreeNode*& node`: a *reference to a pointer*. Assigning to `node` changes the actual pointer stored in the parent (or `root`), not a copy. Every list and BST helper that rewires links uses this

#table(
  columns: 3,
  table.header([], [*Reference*], [*Pointer*]),
  [Can be null], [No], [Yes (`nullptr`)],
  [Can be re-pointed], [No, bound once], [Yes, assign a new address],
  [Must be initialized], [Yes], [No (but an uninitialized one is garbage)],
  [Read the value], [`r`], [`*p`],
)

=== Passing arguments

#table(
  columns: 3,
  table.header([*Style*], [*Signature*], [*Does `x = 10` / `*x = 10` change the caller's `n`?*]),
  [By value], [`void foo(int x)`], [No, `x` is a copy],
  [By reference], [`void foo(int& x)`], [Yes, `x` is `n`],
  [By pointer], [`void foo(int* x)`, called as `foo(&n)`], [Yes through `*x = 10`. But `x = nullptr` only changes the local copy of the pointer],
)

=== Common mistakes

- Thinking a pointer parameter is passed by reference. The *address* is copied, so re-pointing the parameter does nothing to the caller. Only `*x = ...` reaches the caller's variable
- Storing the result of a `T*&` function in a plain `T*`. You get a copy, and assigning to it never touches the structure
- Using a pointer after `delete` (dangling) or dereferencing `nullptr` without checking

== Lists

=== Key ideas

- *List ADT*: an ordered collection with `insertAtFront`, `insert(data, index)`, `remove(index)`, `find`/`operator[]`, `size`, `isEmpty`. The ADT says *what*, not *how*
- *Linked list*: each `ListNode` holds `data` and a `next` pointer, with `head` pointing at the first node and the last node's `next` set to `nullptr`
- *Array list*: elements sit next to each other in one buffer, tracked by `size` (elements used) and `capacity` (buffer length)
- `find(index)` returns `ListNode*&`, the pointer that points *at* the node at that index. `insert` and `remove` reassign that pointer
- When the buffer is full, `pushBack` copies everything into a bigger buffer, $O(n)$ for that one call
  - *Doubling* the capacity - total copying over $n$ pushes is about $2n$, so `pushBack` is $O(1)$ amortized
  - *Adding 2* to the capacity - total copying grows like $n^2/4$, so the amortized cost is $O(n)$ per push
- *Amortized*: the average cost per operation over a long sequence, not the cost of one call

=== Runtimes

#table(
  columns: 3,
  table.header([*Operation*], [*Singly Linked List*], [*Array*]),
  [Insert/Remove at front], [$O(1)$], [$O(n)$ (shift everything)],
  [Insert at back], [$O(1)$ with a `tail` pointer, else $O(n)$], [$O(1)^*$ amortized],
  [Insert/Remove given a pointer to the spot], [$O(1)$], [$O(n)$],
  [Insert/Remove at a given index], [$O(n)$], [$O(n)$],
  [Access index $i$], [$O(n)$], [$O(1)$],
  [Find a value], [$O(n)$], [$O(n)$],
  [Find a value in a sorted list], [$O(n)$], [$O(log n)$ (binary search)],
)

=== Code you should be able to write

`insertAtFront` is three lines: `new` a node, set its `next` to `head`, then move `head` to it. `remove(index)` reuses `find`

```cpp
template <typename T>
T List<T>::remove(int index) {
    ListNode<T>*& toRemove = find(index);   // the pointer that points AT the node
    ListNode<T>* temp = toRemove;
    T val = temp->data;
    toRemove = toRemove->next;              // unlink by rewiring that pointer
    delete temp;
    return val;
}
```

=== Common mistakes

- Forgetting `&` in `ListNode<T>*& toRemove = find(index);`. Without it, `remove` rewires a copy and the list is unchanged (and then the node gets deleted while still linked)
- Setting `head = newNode` *before* `newNode->next = head`. The order matters, or the rest of the list is lost
- Calling `pushBack` "$O(1)$" without the word *amortized*. A single resize call is $O(n)$

== Stacks and Queues

=== Key ideas

- *Queue*: FIFO. `enqueue` adds at the back, `dequeue` removes from the front. Both $O(1)$
- *Stack*: LIFO. `push` and `pop` both work at the top. Both $O(1)$
- *Circular queue* (array) - keeps `items`, `start`, `size`, `capacity`
  - `enqueue` writes `items[(start + size) % capacity]`, then `size++`
  - `dequeue` reads `items[start]`, then `start = (start + 1) % capacity` and `size--`
  - The dequeued value stays in memory, but the queue no longer counts it
  - Full (`size == capacity`) - double the buffer and copy in *queue order* starting at `start`, so the front lands at index 0

#figure(
  grid(
    columns: 3,
    column-gutter: 1.5em,
    align: horizon,
    array-cells(3, 4, 5, 6, marks: (start: 2)),
    $stretch(->)^"enqueue(7)"$,
    array-cells(7, 4, 5, 6, marks: (start: 2), highlight: (0,)),
  ),
  caption: [Example: `start = 2`, `size = 2`, `capacity = 4`, so the queue is 5, 6. `enqueue(7)` goes to `(2 + 2) % 4 = 0`, on top of the old dequeued 3],
) <m2-circular-queue>

=== Common mistakes

- Writing to `items[size]` instead of `items[(start + size) % capacity]` once anything has been dequeued
- Resizing by copying `items[0..capacity)` straight across. A wrapped queue comes out in the wrong order
- Mixing up which end each structure removes from. Queue removes the *oldest*, stack removes the *newest*

== Trees

=== Terminology (CS 173)

- *Tree*: connected and acyclic, so $n$ nodes have $n - 1$ edges and any two nodes have exactly one path between them
- *Leaf*: no children. *Internal node*: at least one child. *Siblings* share a parent
- *Ancestors* sit on the path up to the root, *descendants* anywhere below. *Depth*: edges from the root (root is level 0)

=== Tree properties

- *Binary*: $T = emptyset$, or $T = (r, T_L, T_R)$ with $T_L$, $T_R$ binary trees. At most 2 children per node, and the empty tree is the recursion's base case (`nullptr`)
- *Height*: edges on the longest root to leaf path
  - $"height"(emptyset) = -1$, $"height"(T) = max("height"(T_L), "height"(T_R)) + 1$. A single node has height 0
- *Full*: every node has 0 or 2 children. In code, `left` and `right` are both null or both non-null
- *Perfect*: $P_(-1) = emptyset$, $P_h = (r, P_(h-1), P_(h-1))$. Every level is packed, all leaves on the same level, $2^(h+1) - 1$ nodes
- *Complete* (data structures version) - every level full except possibly the last, and the last level is pushed left
  - $C_(-1) = emptyset$, and $C_h = (r, T_L, T_R)$ where either $T_L = C_(h-1)$, $T_R = P_(h-2)$ or $T_L = P_(h-1)$, $T_R = C_(h-1)$
- Perfect implies full and complete. Full and complete do not imply each other

#figure(
  grid(
    columns: 3,
    column-gutter: 3em,
    row-gutter: 0.8em,
    scale(75%, reflow: true, tree((1, 2, (3, 4, 5)))),
    scale(75%, reflow: true, tree((1, (2, 4, 5), (3, 6, 7)))),
    scale(75%, reflow: true, tree((1, (2, 4, 5), (3, 6, none)))),
    [Full, not complete], [Perfect ($P_2$)], [Complete, not full],
  ),
  caption: [The complete tree is the perfect tree with its last leaf (7) removed, which leaves 3 with one child],
) <m2-full-perfect-complete>

```cpp
int height(TreeNode* curr) {
    if(curr == nullptr) { return -1; }
    return std::max(height(curr->left), height(curr->right)) + 1;
}
```

=== `NULL` pointers: $n$ nodes give $n + 1$ null pointers

*Claim*: a binary tree with $n >= 0$ nodes has exactly $n + 1$ `NULL` pointers (when $n = 0$, the null `root` pointer counts)

*Proof* (induction on $n$, the way the notes do it). Let $"NULLS"(n)$ be the number of null pointers in a binary tree with $n$ nodes

+ *Base case*: $n = 0$. The only pointer is `root`, and it is null, so $"NULLS"(0) = 1 = 0 + 1$
+ *Inductive hypothesis*: suppose $"NULLS"(j) = j + 1$ for every $0 <= j <= k$
+ *Inductive step*: take any binary tree with $k + 1$ nodes
  - Remove a leaf. What is left is a binary tree with $k$ nodes, which has $k + 1$ null pointers by the IH
  - Put the leaf back. The pointer it hangs from was null and now is not ($-1$), and the leaf brings two null child pointers ($+2$)
  - Net change is $+1$, so the count is $(k + 1) + 1$, which is $n + 1$ for $n = k + 1$
+ So by induction, every binary tree with $n >= 0$ nodes has $n + 1$ null pointers $qed$

=== Common mistakes

- Using the CS 173 meaning of "complete" (all leaves on one level). That is *perfect* here
- Saying a single node has height 1, or the empty tree has height 0. They are 0 and $-1$
- In the null-pointer induction, removing an *internal* node. Only a leaf can be pulled off and leave a valid smaller tree

== Tree Traversals and Search

=== Key ideas

- A *traversal* visits every node, so it is always $O(n)$
- *Pre-order* (node, left, right), *in-order* (left, node, right), *post-order* (left, right, node) - all DFS, all recursive with base case `curr == nullptr`
- *Level-order*: one level at a time, left to right, using a *queue*. This is BFS
- Pre-order lists the root first and post-order lists it last. In-order on a BST is sorted
- *Search*: look for one value. Worst case (value missing) still touches all $n$ nodes, $O(n)$
- *DFS* memory is the height, $O(h)$. *BFS* memory is the widest level. BFS finds the shallowest match first and works even on infinitely deep trees, while DFS can wander down a bad branch

#figure(
  grid(
    columns: 2,
    column-gutter: 2em,
    align: horizon,
    scale(80%, reflow: true, tree((4, (2, 1, 3), (6, 5, 7)))),
    table(
      columns: 3,
      table.header([*Traversal*], [*Order*], [*Result*]),
      [Pre-order], [N L R], [4, 2, 1, 3, 6, 5, 7],
      [In-order], [L N R], [1, 2, 3, 4, 5, 6, 7],
      [Post-order], [L R N], [1, 3, 2, 5, 7, 6, 4],
      [Level-order], [by level], [4, 2, 6, 1, 3, 5, 7],
    ),
  ),
  caption: [Example: all four traversals on the same tree],
) <m2-traversal-tree>

=== Code you should be able to write

```cpp
template <typename T>
void BinaryTree<T>::inOrder(TreeNode* curr) {
    if(curr == nullptr) { return; }
    inOrder(curr->left);
    std::cout << curr->data << " ";    // move this line for pre/post-order
    inOrder(curr->right);
}

template <typename T>
void BinaryTree<T>::levelOrder() {
    std::queue<TreeNode*> q;
    q.push(root);
    while(!q.empty()) {
        TreeNode* curr = q.front();
        q.pop();
        if(curr != nullptr) {
            std::cout << curr->data << " ";
            q.push(curr->left);
            q.push(curr->right);
        }
    }
}
```

=== Common mistakes

- Writing level-order with a stack. That gives a DFS order, not level order
- Doing post-order as "right, left, node". It is still left subtree first
- Assuming in-order is sorted for *any* binary tree. Only for a BST

== Binary Search Trees

=== Key ideas

- *Tree vs. BST*: a plain binary tree puts values anywhere. A BST requires every key in $T_L$ to be smaller than $r$ and every key in $T_R$ to be larger, recursively. No duplicate keys
- The rule is about the *whole subtree*, not just the two children (see Problem 10)
- One comparison per node picks a side, so `find`, `insert`, and `remove` each walk a single root to leaf path - $O(h)$
- *Height bounds*: $log_2 n - 1 < h <= n - 1$. Best case (complete) $h = O(log n)$. Worst case (keys inserted in sorted order, so the tree is a linked list) $h = n - 1$
- `_find` returns `TreeNode*&`: the pointer to the key's node, *or* the null pointer where the key would go
- `insert`: assign a new node into the null pointer `_find` stops on. New nodes are *always leaves*
- `remove`, by number of children
  + *Leaf*: delete it, set the parent's pointer to `nullptr`
  + *One child*: point the parent at that child, then delete the node. The child's whole subtree moves up
  + *Two children*: find the *IOP* (in-order predecessor, the largest key in the left subtree: go left once, then right until you can't). Swap keys/values, then remove the key from the *left subtree*. The IOP has no right child, so this second remove is always the leaf or one-child case. The IOS (smallest key on the right) works too, but the notes use the IOP

=== Runtimes

#table(
  columns: 4,
  table.header([*Operation*], [*In terms of $h$*], [*Worst case in $n$*], [*Balanced/complete tree*]),
  [`find`], [$O(h)$], [$O(n)$], [$O(log n)$],
  [`insert`], [$O(h)$], [$O(n)$], [$O(log n)$],
  [`remove`], [$O(h)$], [$O(n)$], [$O(log n)$],
  [Traversal], [$O(n)$], [$O(n)$], [$O(n)$],
)

"In terms of $n$" with no other info means the worst case, $O(n)$. Two-child `remove` is still $O(h)$ because finding the node and then its IOP is one downward path

=== Code you should be able to write

```cpp
template <typename K, typename V>
typename BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {
    if(root == nullptr || root->key == key) { return root; }
    if(key < root->key) { return _find(root->left, key); }
    return _find(root->right, key);
}

template <typename K, typename V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
    _find(root, key) = new TreeNode(key, value);
}

template <typename K, typename V>
typename BST<K, V>::TreeNode*& BST<K, V>::_iop(TreeNode*& root) {
    TreeNode** curr = &root->left;
    while((*curr)->right != nullptr) { curr = &(*curr)->right; }
    return *curr;
}
```

```cpp
template <typename K, typename V>
void BST<K, V>::_remove(TreeNode*& node, const K& key) {
    if(node == nullptr) { return; }
    if(key < node->key) { _remove(node->left, key); }
    else if(key > node->key) { _remove(node->right, key); }
    else if(node->left == nullptr && node->right == nullptr) {   // leaf
        delete node;
        node = nullptr;
    } else if(node->left == nullptr || node->right == nullptr) { // one child
        TreeNode* tmp = node;
        node = (node->left != nullptr) ? node->left : node->right;
        delete tmp;
    } else {                                                     // two children
        TreeNode* iop = _iop(node);
        _swap(node, iop);
        _remove(node->left, key);
    }
}
```

#figure(
  grid(
    columns: 5,
    column-gutter: 1.5em,
    row-gutter: 0.8em,
    align: horizon + center,
    scale(80%, reflow: true, tree((15, (8, 4, (12, 10, none)), 25), highlight: (15, 12))),
    $->$,
    scale(80%, reflow: true, tree((12, (8, 4, (15, 10, none)), 25), highlight: (15,))),
    $->$,
    scale(80%, reflow: true, tree((12, (8, 4, 10), 25))),
    [IOP of 15 is 12], [], [Swap 15 and 12], [], [Remove 15 (one child)],
  ),
  caption: [Example: removing 15. Left to 8, right to 12, so the IOP is 12. After the swap, 15 only has a left child (10), so the one-child case finishes it],
) <m2-two-child-remove>

=== Common mistakes

- Taking the IOP as "the left child". It is the *rightmost* node of the left subtree
- After the swap, removing from the right subtree or from the root again. The key now lives in the *left* subtree
- Assuming the IOP is always a leaf. It can have a left child, so it may be a one-child removal
- Giving $O(log n)$ for BST operations without being told the tree is balanced

== Practice Problems

+ What does this print?

  ```cpp
  int a = 3, b = 8;
  int* p = &a;
  int& r = b;
  *p = r + 1;
  p = &b;
  *p = *p * 2;
  r = a;
  std::cout << a << " " << b << " " << *p << std::endl;
  ```

  *Answer:* `9 9 9`. `*p = r + 1` sets `a = 9`. Then `p` points at `b`, and `*p = *p * 2` makes `b = 16`. `r` is `b`, so `r = a` sets `b = 9`, and `*p` reads `b`, which is 9

+ After `int a = 0, b = 0, c = 0; f(a, b, &c);`, what are `a`, `b`, `c`?

  ```cpp
  void f(int x, int& y, int* z) {
      x = 1;  y = 2;  *z = 3;  z = nullptr;
  }
  ```

  *Answer:* `a = 0`, `b = 2`, `c = 3`. `x` is a copy, `y` is `b`, and `*z = 3` writes through the address of `c`. `z = nullptr` only changes `f`'s local copy of the pointer, so it has no effect on the caller

+ A circular queue has `capacity = 4` and starts empty. Run `enqueue(1)`, `enqueue(2)`, `enqueue(3)`, `dequeue()`, `dequeue()`, `enqueue(4)`, `enqueue(5)`, `enqueue(6)`. Give `items`, `start`, `size`, and the queue from front to back. What happens on one more `enqueue`?

  *Answer:* After the three enqueues, `items` is `[1, 2, 3, _]`. The two dequeues return 1 and 2, leaving `start = 2`, `size = 1`. Then 4 goes to `(2 + 1) % 4 = 3`, 5 goes to `(2 + 2) % 4 = 0`, and 6 goes to `(2 + 3) % 4 = 1`. Final `items = [5, 6, 3, 4]`, `start = 2`, `size = 4`, and the queue is 3, 4, 5, 6. It is now full, so the next `enqueue` doubles to capacity 8 and copies in queue order (3, 4, 5, 6 at indices 0 to 3, `start = 0`) before writing the new value at index 4

+ For the tree in @m2-practice-tree, give the pre-order, in-order, post-order, and level-order traversals, the height, and whether it is full, complete, and a BST

  #figure(
    scale(70%, reflow: true, tree((8, (3, 1, (6, 4, 7)), (10, none, (14, 13, none))))),
    caption: [Tree for Problem 4],
  ) <m2-practice-tree>

  *Answer:*
  - Pre-order - 8, 3, 1, 6, 4, 7, 10, 14, 13
  - In-order - 1, 3, 4, 6, 7, 8, 10, 13, 14
  - Post-order - 1, 4, 7, 6, 3, 13, 14, 10, 8
  - Level-order - 8, 3, 10, 1, 6, 14, 4, 7, 13
  - Height 3 (for example 8, 3, 6, 4). Not full, since 10 and 14 each have one child. Not complete, since level 2 is missing 10's left child while the level below has nodes. It *is* a BST, and the sorted in-order output confirms it

+ Insert 50, 30, 70, 20, 40, 60, 80, 35, 45 into an empty BST in that order. Draw the result and give its height. How many nodes does `find(45)` visit?

  *Answer:* The tree is in @m2-practice-bst (left). Each key follows the search path and becomes a leaf, so 35 and 45 end up as the children of 40. Height 3 (50, 30, 40, 35). `find(45)` visits 50, 30, 40, 45, which is 4 nodes ($h + 1$ for a deepest key)

+ Starting from the tree in Problem 5, remove 30, then remove 50, using the IOP. Draw the tree after each removal

  *Answer:* Both are two-child removals, shown in @m2-practice-bst.
  - Remove 30: its left subtree is just 20, which has no right child, so the IOP is 20. Swap, and 30 now sits in 20's old spot as a leaf, so it is deleted. 20 is now the left child of 50 with only a right child, 40
  - Remove 50: go left to 20, then right to 40, then right to 45. The IOP is 45. Swap, and 50 is now a leaf where 45 was, so it is deleted. The root is 45

  #figure(
    grid(
      columns: 3,
      column-gutter: 2em,
      row-gutter: 0.8em,
      align: bottom + center,
      scale(80%, reflow: true, tree((50, (30, 20, (40, 35, 45)), (70, 60, 80)))),
      scale(80%, reflow: true, tree((50, (20, none, (40, 35, 45)), (70, 60, 80)), highlight: (20,))),
      scale(80%, reflow: true, tree((45, (20, none, (40, 35, none)), (70, 60, 80)), highlight: (45,))),
      [After the inserts], [After `remove(30)`], [After `remove(50)`],
    ),
    caption: [Example: the BST from Problems 5 and 6. Each highlighted node is the IOP that moved up],
  ) <m2-practice-bst>

+ A binary tree has 12 nodes. How many of its child pointers are null? How many are not?

  *Answer:* There are $2 dot 12 = 24$ child pointers. Every node but the root has one pointer aimed at it, so 11 are non-null and $24 - 11 = 13 = n + 1$ are null

+ Prove the null-pointer claim a second way: by strong induction, splitting the tree at the root instead of removing a leaf

  *Answer:* Base case $n = 0$ is the null `root`, so $1 = 0 + 1$. IH: $"NULLS"(j) = j + 1$ for all $0 <= j < n$. For $n >= 1$, write $T = (r, T_L, T_R)$ with $a$ and $b$ nodes, so $a + b = n - 1$ and both are less than $n$. The root's `left` and `right` act as the root pointers of $T_L$ and $T_R$, so every null pointer of $T$ is a null pointer of one subtree. By the IH, $"NULLS"(n) = (a + 1) + (b + 1) = (n - 1) + 2 = n + 1$ $qed$

+ Keys $1, 2, dots, n$ are inserted into an empty BST in increasing order. What shape is the tree, what is its height, and what is the total time for all $n$ inserts?

  *Answer:* Each new key is larger than everything so far, so it always goes right. The tree is a right-leaning linked list with height $n - 1$. Insert number $i$ walks past the $i - 1$ existing nodes, so the total is $0 + 1 + dots + (n - 1) = n(n - 1)/2 = O(n^2)$

+ True or false? Justify each
  + In-order traversal of any binary tree prints the keys in sorted order
  + Every complete tree is full
  + The IOP of a node with two children never has a right child
  + A tree where every node satisfies `left->key < key < right->key` is a BST
  + Level-order traversal can be done with a stack in place of the queue

  *Answer:*
  + False. Only a BST guarantees it. For example, a root 1 with left child 2 prints 2, 1
  + False. The complete tree in @m2-full-perfect-complete has a node (3) with one child
  + True. The IOP is the rightmost node of the left subtree. If it had a right child, that child would be larger and further right
  + False. The rule covers whole subtrees. Root 10, left child 5, and 5's right child 12 passes the child-by-child check, but 12 sits in 10's left subtree
  + False. A stack is LIFO, so it dives into the most recently pushed child and gives a DFS order instead of level by level

+ Write `bool isFull(TreeNode* curr)` and give its runtime

  *Answer:*

  ```cpp
  bool isFull(TreeNode* curr) {
      if(curr == nullptr) { return true; }            // the empty tree is full
      if((curr->left == nullptr) != (curr->right == nullptr)) {
          return false;                               // exactly one child
      }
      return isFull(curr->left) && isFull(curr->right);
  }
  ```

  It looks at each node at most once, so it runs in $O(n)$
