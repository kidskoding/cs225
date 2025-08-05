
# Module 12 - BST Balance

Previously, we discussed that $O(h) \equiv O(n)$ in the worst case scenario. When comparing our BST runtime analysis to our runtime analysis of a `LinkedList`, its not actually any better, and is in fact almost the same. 

However, a BST can still be better. This is because BST's have a lower bound on a height that grows **logarithmically**, while a `LinkedList` has a lower bound on a length that grows **linearly**

Although the worst case is identical, a BST's runtime varies significantly by its shape.

For all BST's
	- Its **lower bound** - $h \geq O(log(n)) \equiv h \geq O(log_2(n))$
	- Its **upper bound** - $h \leq O(n)$
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTI2OTExNzM3MCwxNTc1MjE3NzYwXX0=
-->