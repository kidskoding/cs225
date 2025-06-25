
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
| Insert/Remove at back     | `O(1)` for insert, `O(n)` for remove | Insert/Remove given a pointer  | `O(1)` |
| Insert/Remove at a given index | `O(n)` |
| Find a value in a list         | `O(n)` |
| Find a value in a sorted list  | `O(n)` |

- Inserting at the front of a `LinkedList` is `O(1)`. This is because we only have to do 3 steps. Create a new node with its given data, point its next to the original head, set the new node as `head`
- Removing at the front of a `LinkedList` is also `O(1)`. This is because to remove the front node, we only need to do 3 constant operations 
	1. Create a temporary node pointing to the head
	2. set `head` to its next pointer (`head = head->next`)
	3. Free temp from memory (`delete temp`)
- Inserting at the back of a `LinkedList` is also `O(1)`


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE5MjgzNTEzNCwxNjk4ODg4NTA2LDM2Mj
A0ODMwMSw3MDMzNTkzNTQsLTcwNzA3NDg4LC0xMDkwNjUyMjJd
fQ==
-->