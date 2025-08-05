
# Module 12 - BST Balance

Previously, we discussed that $O(h) \equiv O(n)$ in the worst case scenario. When comparing our BST runtime analysis to our runtime analysis of a `LinkedList`, its not actually any better, and is in fact almost the same.

Although the worst case is identical, a BST's runtime varies significantly by its shape.

For all BST's
	- Its **lower bound** - $h \geq O(log(n)) \equiv h \geq O(log_2(n))$
	- Its **upper bound** - $h \leq O(n)$
<!--stackedit_data:
eyJoaXN0b3J5IjpbODUxOTIwMzUsMTU3NTIxNzc2MF19
-->