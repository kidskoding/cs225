
# Module 16 - BBST Range Search

Balanced BST's are useful for **range-based** and **nearest-neighbor** searches (e.g. finding out which nodes in a tree have values that fall between $[11, 42]$)

## Red-Black trees in C++

Previously, we discussed how C++'s STL map is implemented via a red-black tree under the hood

`std::map` includes a `lower_bound` and an `upper_bound` function, which allow efficient logarithmic-time range queries by returning iterators to the first element not less than (`lower_bound`) and the first element greater than (`upper_bound`) a given key, respectively.

- `lower_bound` - The smallest element greater than or equal to the argument
- `upper_bound` - The smallest element greater than the argument


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTg5NTE2NjYyMSwtMjA5NDg4MDQ2M119
-->