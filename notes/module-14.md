
# Module 14 - AVL Trees

**AVL trees** are **self-balancing binary search trees** that automatically keep themselves balanced through rotations after insertions and deletions, ensuring efficient operations

This means that we have to consider 3 things:

- Rotations
- Maintaining Height
- Detecting Imbalance - check subtree height in $O(1)$ time and compute balance in $O(1)$ time

We can compute balance by having each subtree store its height, which means that I can retrieve it in constant time




<!--stackedit_data:
eyJoaXN0b3J5IjpbMTI5NDQxNjc4MCwxMTA5OTc4NjI4LC0xNj
U4ODQxNDgyLDQwOTU3ODEzOCwtNDA5NjMyNTkxXX0=
-->