#import "../diagrams.typ": linked-list

= Midterm 1: Lists

Midterm 1 covers modules 1-7, which discuss mostly about Lists. The topics covered are listed below

== Topics Covered

- Lists
  - ADT
  - Linked
  - Array

Use these assignments to reference when studying as well
- `lab_debug`
- `mp_stickers`

== Lists

#strong[ADT]s, or Abstract Data Types, are templates/descriptions used to explain how a data structure works and how any user should use it.

In a *`LinkedList`*, each node is stored independently in memory and contains
+ Data - the actual value stored in the node
+ Pointer - a pointer to the next node in the list (or previous in a doubly linked list)

From a visual standpoint a `LinkedList` looks like the one in @m1-linked-list

#figure(
  linked-list(4, 8, 15),
  caption: [A singly linked list: each node holds data and a pointer to the next node],
) <m1-linked-list>

Each node holds data and then a pointer to the next node!

The table below shows the core functionalities of a `LinkedList` and their runtimes

#table(
  columns: 2,
  table.header([*Operation*], [*Singly Linked List*]),
  [Insert/Remove at front], [`O(1)`],
  [Insert/Remove at back], [`O(1)` for insert, `O(n)` for remove],
  [Insert/Remove given a pointer], [`O(1)`],
  [Insert/Remove at a given index], [`O(n)`],
  [Find a value in a list], [`O(n)`],
  [Find a value in a sorted list], [`O(n)`],
)

- Inserting at the front of a `LinkedList` is `O(1)`. This is because we only have to do 3 steps. Create a new node with its given data, point its next to the original head, set the new node as `head`

  You can see these steps in @m1-insert-front, where the new node 2 (shaded) points to the old head 4

  #figure(
    grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 0.8em,
      align: (right + horizon, left + horizon),
      [Before], linked-list(4, 8, 15),
      [After], linked-list(2, 4, 8, 15, highlight: (0,)),
    ),
    caption: [Example: inserting 2 at the front only rewires the new node's `next` and `head`],
  ) <m1-insert-front>
- Removing at the front of a `LinkedList` is also `O(1)`. This is because to remove the front node, we only need to do 3 constant operations
  + Create a temporary node pointing to the head
  + set `head` to its next pointer (`head = head->next`)
  + Free temp from memory (`delete temp`)

  Notice in @m1-remove-front how `head` moves on to 8 while `temp` hangs on to 4 so it can be deleted

  #figure(
    grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 0.8em,
      align: (right + horizon, left + horizon),
      [Before], linked-list(4, 8, 15, head: "head, temp", highlight: (0,)),
      [After], linked-list(8, 15),
    ),
    caption: [Example: `temp` saves the node holding 4, `head` moves to 8, then `delete temp` frees 4],
  ) <m1-remove-front>
- Inserting at the back of a `LinkedList` is also `O(1)`, but this assumes that there is a `tail` pointer
  - Otherwise it would be `O(n)` because we would need to traverse `n` times through the entire list from `head` to find the last node
- Removing from the back of a `LinkedList` is `O(n)` because we have to traverse through the list `n` times in order to find the second to last node and set its `next` pointer to `nullptr`

  In @m1-remove-back, the walk from `head` stops at the second to last node, the shaded 8

  #figure(
    grid(
      columns: 2,
      column-gutter: 1em,
      row-gutter: 0.8em,
      align: (right + horizon, left + horizon),
      [Before], linked-list(4, 8, 15, highlight: (1,)),
      [After], linked-list(4, 8),
    ),
    caption: [Example: removing 15 means walking from `head` to 8, setting its `next` to `nullptr`, then deleting 15],
  ) <m1-remove-back>
