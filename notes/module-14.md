
# Module 14 - AVL Trees

**AVL trees** are **self-balancing binary search trees** that automatically keep themselves balanced through rotations after insertions and deletions, ensuring efficient operations

This means that we have to consider 3 things:

- Rotations
- Maintaining Height
- Detecting Imbalance - check subtree height in $O(1)$ time and compute balance in $O(1)$ time

We can compute balance by having each subtree store its height, which means that I can retrieve it in constant time

``` mermaid
tree
  A->[B, C]
  B->[D, E]
  C->[F, G]
 ```


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTY4NDkyNTI3NywxMjk0NDE2NzgwLDExMD
k5Nzg2MjgsLTE2NTg4NDE0ODIsNDA5NTc4MTM4LC00MDk2MzI1
OTFdfQ==
-->