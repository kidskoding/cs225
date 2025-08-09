
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

To build a KD tree from $k$-D space

1. Start with one dimension (doesn't matter which one)
2. Split dataset into two parts: points less than the median go on the left subtree and points greater than the median go on the right subtree
3. Create a node with the median point as the current root
4. Recursively build the left and right subtrees: move to the next dimension (e.g., if you split by x at this level, split by y at the next)
5. Repeat steps 2-4 for each subtree with their respective points

A KD tree stays balanced simply because of the median because at each step you split the dataset using the **median** point along the current dimension, ensuring that half the points go on the left subtree and half the points go on the right subtree

## $k$-Nearest Neighbor ($k$-NN)

**$k$-Nearest Neighbors (k-NN)** is a simple algorithm used in machine learning and data analysis to find the $k$ closest points to a given query point in a dataset

It is used very often in **Machine Learning**, specifically classification and regression

- **Classification** - Assign the query point the most common class among its k nearest neighbors.
- **Regression** - Predict the query point’s value as the average of its k nearest neighbors’ values.

It becomes very efficient with a constructed KD Tree because it avoids brute force checking each point. Instead, it narrows the search by recursively exploring only those regions of space that could contain points closer than the current best candidates, ignoring irrelevant subtrees, to make nearest neighbor searches much faster

To find the nearest neighbor in a KD Tree, given a query point

1. Start at the root and move down the tree, choosing the child subtree that contains the query point based on the splitting dimension
2. Once you reach a leaf, record that point as the current best candidate
3. Backtrack up the tree, at each node checking if there could be points in the other subtree closer than the current best (by comparing distance to the splitting plane)
4. If so, explore the other subtree to find potentially closer points
5. Continue this process until all promising subtrees have been checked
6. Return the closest point found as the nearest neighbor
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTUyNjE1NDExNywtMTE3MTY0ODk2NSwyMT
M2NDg5NDQ3LC03MTgyMTA4MiwtMTM1NTQ2Njc5NiwyMDQ1NjY0
Njg4LC0xNjg1NDI4MzM3LC04OTUxNjY2MjEsLTIwOTQ4ODA0Nj
NdfQ==
-->