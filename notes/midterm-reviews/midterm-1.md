
# Midterm 1 - Lists

Midterm 1 covers modules 1-7, which discuss mostly about Lists. The topics covered are listed below

## Topics Covered

-   Lists
    -   ADT
    -   Linked
    -   Array

Use these assignments to reference when studying as well
-   lab_debug
-   mp_stickers

## Lists

**ADT**s, or Abstract Data Types, are templates/descriptions used to explain how a data structure works and how any user should use it.  

In a **`LinkedList`**, each node is stored independently in memory and contains
1. Data - the actual value stored in the node
2. Pointer - a pointer to the next node in the list (or previous in a doubly linked list)

From a visual standpoint a `LinkedList` looks like one below
```
[Data | Next] -> [Data | Next] -> [Data | Next] -> NULL
```

Each node holds data and then a pointer to the next node!

The table below shows the core functionalities of a `LinkedList` and their runtimes

| Operation                     | **Singly Linked List** |
|-------------------------------|-----------------------|
| Insert/Remove at front    | `O(1)` |
| Insert/Remove at back     | usually `O(n)`, can be `O(1)` if there is a `tail` pointer to back of the list
| Insert/Remove given a pointer  | `O(1)` |
| Insert/Remove at a given index | `O(n)` |
| Find a value in a list         | `O(n)` |
| Find a value in a sorted list  | `O(n)` |





<!--stackedit_data:
eyJoaXN0b3J5IjpbLTU2ODgxMzkwOCw3MDMzNTkzNTQsLTcwNz
A3NDg4LC0xMDkwNjUyMjJdfQ==
-->