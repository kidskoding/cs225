
# Module 9 - Tree Traversals

Previously, we discussed a new data structure: trees, where we discussed that there is a $O(n)$, linear space, overhead cost because $n$-space is required to store the data

Here, we will continue discussing Trees and the Tree ADT. Previously, we failed to discuss how the implementation of `insert`, `remove`, and `access` would work. This is because the way they work is different for every tree.

Recall that previously we discussed that every data structure should be able to have its own way of getting everything it contains, which was done through an iterator. This means that if we want to achieve this functionality, we would need to implement an iterator interface. But **how**?

We need to know how to find everything in our tree. Otherwise, how would we know that we found everything. The simple answer to these questions is by implementing **tree traversals**

**Tree traversals** are algorithms that will follow the structure of a tree in some fixed order that **visits** every node. They access **all the nodes** in a tree. So every data point is stored in some sort, and we are going to visit all of the nodes.
- By visit, we typically mean whatever the algorithm wants to do with the data, which for demonstration purposes, we just simplify to printing the data because that is an easy way to test what is going on
- So when a node is visited, it will then be print and then at the end check whether we went through every node in the tree

While it makes sense that the goal of a tree traversal is to visit every node, but **how**? Should it visit the node before I traverse into the subtree, during, or after? The simple answer is that **it is up to you**





<!--stackedit_data:
eyJoaXN0b3J5IjpbMTAzNjEyOTE5NSw2NjU5OTk3OTIsLTY2MT
EyNTQ2MF19
-->