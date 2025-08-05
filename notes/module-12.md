
# Module 12 - BST Balance

Previously, we discussed that $O(h) \equiv O(n)$ in the worst case scenario. When comparing our BST runtime analysis to our runtime analysis of a `LinkedList`, its not actually any better, and is in fact almost the same. 

However, a BST can still be better. This is because BST's best case scenario occurs on a height that grows **logarithmically**, while a `LinkedList` has a lower bound on a length that grows **linearly**

For all BST's
	- Its **lower bound** (best case scenario) occurs when $h \geq O(log(n)) \equiv h \geq O(log_2(n))$
	- Its **upper bound** (worst case scenario) occurs when $h \leq O(n)$

Therefore, BSTs can run faster, only if their height remains close to $O(log⁡(n))$
<!--stackedit_data:
eyJoaXN0b3J5IjpbMTczMDQ1NjkxNywxNTc1MjE3NzYwXX0=
-->