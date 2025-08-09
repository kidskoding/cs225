
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

A **$k$-dimensional tree**, or **KD Tree** is a data structure used to store and search points in $k$-dimensional space efficiently for range queries and nearest neighbor searches

Range based searching has a lot of real world applications, involving **computer graphics**, **collision detection**, and and **sensor data**. Each of these things relies on quickly identifying all objects, points, or events that fall within a specific region or interval, so that only relevant data is processed while ignoring everything outside the range, which greatly improves efficiency.

## KD Trees

Range based searching becomes efficient with a type of tree known as a **KD Tree**, which organizes points so that large portions of space can be skipped entirely during a query


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTExNzE2NDg5NjUsMjEzNjQ4OTQ0NywtNz
E4MjEwODIsLTEzNTU0NjY3OTYsMjA0NTY2NDY4OCwtMTY4NTQy
ODMzNywtODk1MTY2NjIxLC0yMDk0ODgwNDYzXX0=
-->