#import "../diagrams.typ": btree

= BTree Analysis

In the last chapter, we saw how a B-tree works: we insert more than one key into each node, and when a node ends up with one more key than it's allowed to hold, we split it into two nodes and push the middle key up to the parent (or up into a brand new root)

Search is a direct extension of a BST. Every key in a non-leaf node has a child before it and a child after it, so if the key we want isn't in the current node, it has to be before all of its keys, between two of them, or after all of them, and there is a child there to go down into. A BST does exactly the same thing with one key and two children; a B-tree just has up to $m - 1$ keys and $m$ children

The choice to grow the tree by kicking keys *up* is a little unobvious, but it means all of the leaves are always at the same level. So in a sense, a B-tree is always approaching a *perfect* $m$-ary tree. That suggests a B-tree is pretty good at staying short, and this chapter shows exactly how short

== Properties of a B-Tree

A B-tree of order $m$ is an $m$-way (or $m$-ary) tree, so every node has between 0 and $m$ children

- All keys within a node are kept *sorted* in a fixed-size array, so we can binary search them
- Every node contains *no more than $m - 1$ keys*. That's just the design: with $m - 1$ keys we need $m$ children, and $m$ is the most children an $m$-ary tree can have
- Every internal node has *exactly one more child than it has keys*. This comes directly from how search works: one child before each key, plus one after the last key
- The root is either a leaf (when the tree has at most $m - 1$ keys) or has between 2 and $m$ children
- Every *non-root internal node* has *at least $ceil(m / 2)$ children*

The last property is the one that matters for the analysis, so let's make sure it's right. A non-root node only comes into existence when a full node splits. If $m = 6$, an overfilled node has 6 keys: one goes up, and the remaining 5 split into 3 and 2. The smaller node has 2 keys, so it has 3 children, and $ceil(6 / 2) = 3$. If $m = 5$, an overfilled node has 5 keys: one goes up, and the other 4 split into 2 and 2, each with 3 children, and $ceil(5 / 2) = ceil(2.5) = 3$

When we think about a B-tree, we tend to think about the keys, since that's what we split. But we state the minimum in terms of *children*, because the minimum number of children is what describes the minimum *structure* of the tree

== What We Want to Show

The whole reason to use a B-tree is that fetching a node (a *seek*) is somewhere between 100,000 and 100 million times more expensive than anything else we do. So the only thing we count is seeks. Every search and insert follows a single path from the root to a leaf, so the number of seeks is the *height* of the tree

Our goal is to show that the height is about $log_m n$, where $n$ is the number of keys

How good is that? If $m = 10$, then $log_(10) n$ is just the number of digits in $n$. A million keys means a height of about 6. In practice $m$ is often around 1000, and then the height is the number of *commas* in $n$. Storing a trillion records (1,000,000,000,000) gives a tree of height 4! Four seeks to find anything in a trillion records is an enormous improvement over a binary tree's 40

The work *inside* each node isn't free, but it's cheap: we binary search the node's sorted keys in $O(log m)$ time at each of the $O(log_m n)$ levels. As $m$ gets bigger, the tree gets shorter but each node takes longer to search, so that is the trade-off. In practice, $n$ is millions of times bigger than $m$, and a seek costs millions of times more than a comparison, so the number of seeks dominates

== Minimum Number of Nodes

Just like with AVL trees, we can't directly figure out the height from the number of keys, since that gets incredibly convoluted. Instead, we go the other way around: given a height $h$, what is the *fewest* keys a B-tree of order $m$ can have? If even the emptiest possible tree of height $h$ has a lot of keys, then a tree with $n$ keys can't be very tall

We find the minimum number of keys by first finding the minimum number of *nodes*, which is defined by the minimum branching. Let $b = ceil(m / 2)$, the minimum number of children of a non-root internal node

- *Level 0* - The root, which is just 1 node
- *Level 1* - The root only needs 1 key, so it can have as few as *2* children
- *Level 2* - Each of the 2 nodes at level 1 is a non-root internal node, so each has at least $b$ children, for $2b$ nodes
- *Level 3* - Each of those $2b$ nodes has at least $b$ children, for $2b^2$ nodes
- *Level $k$* - In general, $2b^(k - 1)$ nodes

@btree-min-tree shows the smallest possible B-tree of order 5 with height 2: the root has one key and two children, and every other node has the minimum $b = 3$ children and $b - 1 = 2$ keys

#figure(
  btree(("50", ("20 35", "5 10", "25 30", "40 45"), ("70 85", "55 60", "75 80", "90 95"))),
  caption: [The smallest B-tree of order 5 with height 2. With $b = ceil(5 / 2) = 3$, it has $1 + 2 + 2 dot 3 = 9$ nodes and $1 + 8 dot 2 = 17$ keys],
) <btree-min-tree>

Adding up every level gives the minimum number of nodes in a B-tree of height $h$

$ "min nodes" = 1 + sum_(k = 1)^h 2b^(k - 1) = 1 + 2 sum_(k = 0)^(h - 1) b^k $

Using the closed form of a geometric series (the same kind of identity we used for AVL trees), $sum_(k = 0)^(h - 1) b^k = (b^h - 1) / (b - 1)$, so

$ "min nodes" = 1 + 2 dot (b^h - 1) / (b - 1) $

== Minimum Number of Keys

Nodes aren't what we want, though. $n$ is the number of *keys*, so we need to turn nodes into keys

- The root can have just *1* key
- Every other node has at least $b$ children (or is a leaf made by a split), so it has at least $b - 1$ keys

So we multiply only the non-root part by $b - 1$, and the $b - 1$ cancels out

$ "min keys" = 1 + (b - 1) dot 2 dot (b^h - 1) / (b - 1) = 1 + 2(b^h - 1) = 2b^h - 1 $

For the tree in @btree-min-tree, $b = 3$ and $h = 2$, so the minimum is $2 dot 3^2 - 1 = 17$ keys, which matches

Any B-tree of height $h$ with $n$ keys has at least this many keys, so

$ n >= 2 ceil(m / 2)^h - 1 $

Solving for $h$ gives us what we wanted

$ ceil(m / 2)^h <= (n + 1) / 2 quad ==> quad h <= log_(ceil(m / 2)) ((n + 1) / 2) $

Wrapping this in a Big-O, the $1/2$ inside the log and the $ceil(dot / 2)$ in the base are both constants (changing the base of a log only changes it by a constant factor), so

$ h = O(log_m n) $

So the number of seeks for `find` and `insert` is $O(log_m n)$: count the commas

#quote(block: true)[We're being a little sloppy here: Big-O with multiple variables ($m$ and $n$) is a much more complicated beast than Big-O with one variable, and we are hand-waving the math. If you're a math major, it's worth digging into. For engineering purposes, though, the answer clearly comes out to $log_m n$]
