
# Module 12 - BST Balance

Previously, we discussed that $O(h) \equiv O(n)$ in the worst case scenario. When comparing our BST runtime analysis to our runtime analysis of a `LinkedList`, its not actually any better, and is in fact almost the same. 

However, a BST can still outperform a linked list because its best-case scenario occurs when the tree is **balanced**, resulting in a height that grows **logarithmically** with the number of nodes. In contrast, a `LinkedList`’s best-case scenario still involves traversing a length that grows **linearly** with the number of elements

This means BST operations can be done in $O(log⁡(n))$ time only when **balanced**, whereas a linked list requires $O(n)$ time even in the best case.

For all BST's:

- Its **lower bound** (best case scenario) occurs when $h \geq O(log(n)) \equiv h \geq O(log_2(n))$
- Its **upper bound** (worst case scenario) occurs when $h \leq O(n)$

Therefore, BSTs can run faster, only if their height remains close to $O(log⁡(n))$

This is the notion of **balancing**. We want to balance a BST so that its operations come with a cheaper cost of $O(log(n))$

We can prove that
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTUxMTI4NjY1NywxNTc1MjE3NzYwXX0=
-->