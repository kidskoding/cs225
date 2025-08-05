
# Module 12 - BST Balance

Previously, we discussed that $O(h) \equiv O(n)$ in the worst case scenario. When comparing our BST runtime analysis to our runtime analysis of a `LinkedList`, its not actually any better, and is in fact almost the same. 

**The height of a BST depends on the order in which its nodes were inserted into it**

Therefore, a BST can still outperform a linked list because its best-case scenario occurs when the tree is **balanced**, resulting in a height that grows **logarithmically** with the number of nodes. In contrast, a `LinkedList`’s best-case scenario still involves traversing a length that grows **linearly** with the number of elements

This means BST operations can be done in $O(log⁡(n))$ time only when **balanced**, whereas a linked list requires $O(n)$ time even in the best case.

For all BST's:

- Its **lower bound** (best case scenario) occurs when $h \geq O(\log(n)) \equiv h \geq O(\log_2(n))$
- Its **upper bound** (worst case scenario) occurs when $h \leq O(n)$

Previously, we discussed why the upper bound must be at most $O(n)$. But, why is the lower bound at least $O(\log(n))$?

To explain this, we must understand the structure of a perfect BST, which occurs when each level has twice the number of nodes as the previous level

- Level $0$ (root) has $1$ node
- Level $1$ has $2$ nodes
- Level $2$ has $4$ nodes
$\vdots$
- Level $h$ has $2^h$ nodes

This also means that level $l$ has $2^l$ nodes

This forms a geometric series, where the number of nodes at level $l$, $n_l$, occurs as a sum of the geometric series of all nodes up to level $l$, where

$$
n_l = 1 + 2 + 4 + \cdots + 2^l = \sum^l_{i = 0} 2^i
$$

Since $h = l$ at the maximum level of a tree, the total number of nodes in a BST, $n$, is $2^h$, which can also be represented as a sum of the geometric series of all nodes up to level $h$, where

$$
n = 1 + 2 + 4 + \cdots + 2^h = \sum^h_{i = 0} 2^i
$$

The sum of a geometric series is

$$1 + r + r^2 + \cdots + r^n = \sum_{i = 0}^n r^i = \frac{r^{n + 1} - 1}{r - 1}$$

Since $r = 2$, 
$$\frac{2^{n + 1} - 1}{2 - 1} = 2^{n + 1} - 1$$

Solving for $h$,

$$
\begin{align*}
&n = 2^{h + 1} - 1 \\
&n + 1 = 2^{h + 1} \\
&\log_2(n + 1) = h + 1 \\
&h = \log_2(n + 1) - 1
\end{align*}
$$

Ignoring constants, the best case scenario of a BST occurs at a runtime of $O(\log(n))$

Therefore, BSTs can run faster, only if their height remains close to $O(\log⁡(n))$

This explains the notion of **balancing**. We want to balance a BST so that its operations come with a cheaper cost of $O(\log(n))$

As discussed earlier, a BST's height depends on the number of nodes inserted into it.

If we assume that we have random numbers being inserted into our BST, and choose those random numbers, how many different ways are there?

The simple answer is that there is a lot. Mathematically speaking, if we put $n$ random numbers into our tree, that means we have $n$ choices to choose from for the first number to insert, $n - 1$ for the second (since the first number is now gone), and so on. This means that we have $n!$ sequences to insert into our BST, which results in $n$ unique numbers.

If we looked at every possible sequence and computed its height, its average is $O(\log(n))$

This is because inserting keys in a random order splits the tree roughly in half at each step, where the tree’s height grows the number of times you can halve the keys, which is about $\log_2⁡(n) \equiv \log(n)$


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTg3ODY1NDY1NCw3MDk5MTk5LC0xMzQzOT
gxMjc0LDgzNjA3MjgwMCwxNTc1MjE3NzYwXX0=
-->