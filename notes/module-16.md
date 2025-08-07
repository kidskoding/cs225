
# Module 16 - BBST Range Search and KD Trees

Balanced BST's are useful for **range-based** and **nearest-neighbor** searches (e.g. finding out which nodes in a tree have values that fall between $[11, 42]$)

## Upper and Lower Bound

Previously, we discussed how C++'s STL map is implemented via a red-black tree under the hood

`std::map` includes a `lower_bound` and an `upper_bound` function, which allow efficient logarithmic-time range queries by returning iterators to the first element not less than (`lower_bound`) and the first element greater than (`upper_bound`) a given key, respectively.

- `lower_bound` - The smallest element greater than or equal to the argument
- `upper_bound` - The smallest element strictly greater than the argument

## Range-Based Searches

Since BBST's are balanced, its height is $O(\log n)$, so range queries can be efficient when combining with in-order traversal, since that maintains sorted order

**Range queries** are a search to find all keys that fall within a given range, typically written as $[x, y]$, where $x$ is the lowest possible value (lower bound) and $y$ is the highest possible value (upper bound)


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEzNTU0NjY3OTYsLTEzNTU0NjY3OTYsMj
A0NTY2NDY4OCwtMTY4NTQyODMzNywtODk1MTY2NjIxLC0yMDk0
ODgwNDYzXX0=
-->