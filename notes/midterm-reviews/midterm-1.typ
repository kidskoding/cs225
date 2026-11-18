#import "../diagrams.typ": array-cells, linked-list

= Midterm 1: Lists

This review covers the List ADT and its two implementations from modules 3 to 5: the linked list, the array list, and the amortized analysis of resizing an array list

== Topics Covered

- Lists
  - ADT
  - Linked
  - Array

== List ADT

=== Key Ideas

- *ADT* (Abstract Data Type) - a description of what a data structure can do (its operations and behavior), with no promise about how it's built
- The List ADT keeps elements in a fixed *order* and supports
  - `insert` and `remove` - at the front/back, at an index, or at a pointer you already have
  - `getData` - at the front/back, at an index (`operator[]`), or at a pointer
  - `find`, `isEmpty`, `size`
- A List should be a *template* (`template <typename T>`), so one class can hold integers, pictures, imaginary numbers, anything
- It should act like a plain variable too, so it needs its constructors, destructor and copy constructor
- Two implementations
  + *Linked list* - every element is its own heap allocation, chained together by pointers
  + *Array list* - every element sits in one contiguous buffer (this is `std::vector`)

=== Common Mistakes

- Mixing up the ADT with an implementation. `head`, `next`, `size` pointers and `capacity` belong to an implementation, not to the List ADT
- Saying "a List is $O(1)$" or "$O(n)$". Runtimes belong to an *operation on an implementation*, so always say which one

== Linked List

=== Key Ideas

- A `ListNode<T>` holds `data` and a `next` pointer. The last node's `next` is `nullptr`
- The `List` only stores `head`, a pointer to the first node (an empty list has `head == nullptr`)
- Nodes live on the *heap* (`new`), so they outlive the function that made them. Every `new` needs a matching `delete`
- `find(index)` returns a `ListNode*&`, a pointer *by reference*. That reference is the real pointer inside the list (either `head` or some node's `next`), so assigning to it rewires the list
- `find` walks `curr` to index `index - 1` and returns `curr->next`. `curr` is only a local copy, but `curr->next` lives inside the list
- `find` stops early at the last node, so an index past the end gives back the last node's `next` (a `nullptr`)
- Once you hold the right pointer, the rewiring for insert or remove is $O(1)$. All the $O(n)$ cost comes from walking there

=== Runtimes

#table(
  columns: 2,
  table.header([*Operation*], [*Singly linked list*]),
  [Insert/remove at front], [$O(1)$],
  [Insert at back], [$O(1)$ with a `tail` pointer, $O(n)$ without],
  [Remove at back], [$O(n)$ (walk to the second to last node)],
  [Insert/remove given a pointer], [$O(1)$],
  [Insert/remove at an index], [$O(n)$],
  [Access an index (`operator[]`, `find`)], [$O(n)$],
  [Find a value (sorted or not)], [$O(n)$],
)

=== Code You Should Be Able to Write

```cpp
template <typename T>
struct ListNode {
    T data;
    ListNode* next;
    ListNode(const T& data) : data(data), next(nullptr) { }
};

template <typename T>
void List<T>::insertAtFront(const T& data) {
    ListNode<T>* newNode = new ListNode<T>(data);
    newNode->next = head;
    head = newNode;
}
```

```cpp
template <typename T>
ListNode<T>*& List<T>::find(int index) {
    if(index == 0 || head == nullptr) {
        return head;
    }
    ListNode<T>* curr = head;
    int x = 0;
    while(x < index - 1 && curr->next != nullptr) {
        curr = curr->next;
        x += 1;
    }
    return curr->next;  // the real pointer to the node at `index`
}
```

```cpp
template <typename T>
void List<T>::insert(const T& data, int index) {
    ListNode<T>*& nodeAtIndex = find(index);
    ListNode<T>* newNode = new ListNode<T>(data);
    newNode->next = nodeAtIndex;
    nodeAtIndex = newNode;
}

template <typename T>
T List<T>::remove(int index) {
    ListNode<T>*& toRemove = find(index);
    ListNode<T>* temp = toRemove;  // hold on to it so we can delete it
    T val = temp->data;
    toRemove = toRemove->next;
    delete temp;
    return val;
}

template <typename T>
T& List<T>::operator[](int index) {
    ListNode<T>* loc = find(index);
    return loc->data;
}
```

@m1-insert-index and @m1-remove-index show `insert` and `remove` at index 1. In both, `find(1)` hands back the `next` pointer stored inside the node holding 4

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 0.8em,
    align: (right + horizon, left + horizon),
    [Before], linked-list(4, 8, 15, highlight: (1,)),
    [After], linked-list(4, 3, 8, 15, highlight: (1,)),
  ),
  caption: [Example: `insert(3, 1)`. The new node 3 points at 8, then the `next` inside 4 is pointed at 3],
) <m1-insert-index>

#figure(
  grid(
    columns: 2,
    column-gutter: 1em,
    row-gutter: 0.8em,
    align: (right + horizon, left + horizon),
    [Before], linked-list(4, 8, 15, highlight: (1,)),
    [After], linked-list(4, 15),
  ),
  caption: [Example: `remove(1)`. The `next` inside 4 skips ahead to 15, `temp` lets us delete the node holding 8, and 8 is returned],
) <m1-remove-index>

=== Common Mistakes

- Returning `ListNode*` from `find` instead of `ListNode*&`. You'd get a copy, so `insert` and `remove` would change a local variable and leave the list alone
- Skipping `temp` in `remove`. After `toRemove = toRemove->next`, nothing points at the old node anymore, so it can never be deleted (memory leak)
- Thinking a `tail` pointer makes remove at back $O(1)$. You still need the node *before* the tail to set its `next` to `nullptr`, and getting there is a walk from `head`
- Declaring the new node as `ListNode<T>*&`. A reference has to refer to a pointer that already exists, and `new` gives you a brand new one, so use a plain `ListNode<T>*`

== Array List

=== Key Ideas

- Elements sit side by side in one heap buffer. The class keeps three `T*` pointers
  - `data` - start of the buffer
  - `size` - one past the last element in use, so the element count is `size - data`
  - `capacity` - one past the end of the buffer, so the capacity is `capacity - data`
- The buffer is full exactly when `size == capacity`
- `data[i]` is just an offset from the start, which makes indexing $O(1)$
- Keeping elements contiguous means an insert or remove in the middle has to shift everything after it
- `pushBack` writes at `*size` and bumps `size`. When the buffer is full it calls the private helper `addSpace` first
- `addSpace` makes a bigger buffer (twice the capacity, or 1 if the capacity was 0), copies every element over, does `delete[]` on the old buffer, then repoints all three pointers. The copy makes it $O(n)$

@m1-array-layout shows the three pointers on a buffer with 3 elements and room for 6

#figure(
  array-cells(3, 4, 5, none, none, none, marks: (data: 0, size: 3, capacity: 6)),
  caption: [Three elements in a 6 slot buffer. `size` sits right after the 5, and `capacity` sits right after the last slot],
) <m1-array-layout>

=== Runtimes

#table(
  columns: 2,
  table.header([*Operation*], [*Array list*]),
  [Access an index], [$O(1)$],
  [Insert/remove at front], [$O(n)$ (shift all $n$ elements)],
  [Insert at back (`pushBack`)], [$O(1)$ amortized, $O(n)$ for a single call that resizes],
  [Remove at back], [$O(1)$ (move `size` back one)],
  [Insert/remove given a pointer or at an index], [$O(n)$ (shift)],
  [Find a value], [$O(n)$],
  [Find a value in a sorted array list], [$O(log n)$ (binary search)],
  [`addSpace`], [$O(n)$],
)

=== Code You Should Be Able to Write

```cpp
template <typename T>
void ArrayList<T>::pushBack(const T& value) {
    if(size == capacity) {
        addSpace();
    }
    *size = value;
    ++size;
}

template <typename T>
void ArrayList<T>::addSpace() {
    int newCapacity = (capacity - data) * 2;
    if(newCapacity == 0) {
        newCapacity = 1;
    }
    T* newData = new T[newCapacity];
    int currentSize = size - data;
    for(int i = 0; i < currentSize; i++) {
        newData[i] = data[i];
    }
    delete[] data;
    data = newData;
    capacity = data + newCapacity;
    size = data + currentSize;
}
```

#figure(
  grid(
    columns: 3,
    column-gutter: 1.5em,
    align: horizon,
    array-cells(1, 2, 3, 4),
    $stretch(->)^"pushBack(5)"$,
    array-cells(1, 2, 3, 4, 5, none, none, none, highlight: (4,)),
  ),
  caption: [Example: the buffer is full, so `pushBack(5)` first copies 1 to 4 into a buffer of capacity 8, then writes 5],
) <m1-array-resize>

=== Amortized Analysis of Resizing

- *Amortized cost* - total cost of a long run of operations, divided by how many operations there were. Because it averages over a sequence, any single call can still be slow
- One `pushBack` that resizes costs $O(n)$. The question is what $n$ pushes cost *together*

#table(
  columns: 3,
  table.header([], [*Grow by 2 (`capacity + 2`)*], [*Double (`capacity * 2`)*]),
  [Resizes in $n$ pushes], [$r = n/2$], [$r = log_2 n$],
  [Copies per resize], [$2, 4, 6, dots$], [$1, 2, 4, dots$],
  [Total cost], [$sum_(k=1)^r 2k = r^2 + r = (n^2 + 2n)/4$], [$2n - 1$ (about $n$ copies plus $n$ writes)],
  [Amortized cost per push], [$(n + 2)/4 = O(n)$], [$(2n - 1)/n = 2 - 1/n = O(1)$],
)

- Grow by a constant - every resize copies more than the last, but only buys 2 free slots. The total is $O(n^2)$, so a push is $O(n)$ amortized
- Double - every resize buys as many free slots as it just copied, so the cheap pushes that fill those slots pay off the copy. The total is about $2n$, so a push is $O(1)$ amortized, which is why `addSpace` doubles

=== Common Mistakes

- Saying `pushBack` is $O(1)$ worst case. A single call that triggers `addSpace` is $O(n)$, and only the *average* over many pushes is $O(1)$
- Forgetting to repoint `size` and `capacity` after the copy. Both still point into the old buffer, which was just freed
- Using `delete` instead of `delete[]` on a buffer that came from `new T[...]`
- Dropping the `newCapacity == 0` check. An empty list has capacity 0, and doubling 0 is still 0
- Writing `capacity + 2` (or any constant) growth and calling it amortized $O(1)$. Constant growth is $O(n)$ amortized

== Linked List vs Array List

#table(
  columns: 3,
  table.header([*Operation*], [*Singly linked list*], [*Array list*]),
  [Insert/remove at front], [$O(1)$], [$O(n)$],
  [Insert at back], [$O(1)$ (with a `tail`)], [$O(1)$\* (amortized)],
  [Remove at back], [$O(n)$], [$O(1)$],
  [Insert/remove given a pointer], [$O(1)$], [$O(n)$],
  [Insert/remove at an index], [$O(n)$], [$O(n)$],
  [Access an index], [$O(n)$], [$O(1)$],
  [Find a value], [$O(n)$], [$O(n)$],
  [Find a value in a sorted list], [$O(n)$], [$O(log n)$ (binary search)],
)

- At an index, both are $O(n)$ for opposite reasons. The linked list pays to *get to* the spot and then changes it in $O(1)$. The array list gets there in $O(1)$ and pays to *shift*
- Pick a linked list when most of your work is at the front or at pointers you already hold
- Pick an array list when you index or binary search a lot

== Practice Problems

+ *Trace.* A linked list holds `4 -> 8 -> 15`. Draw it after each call: `insert(7, 0)`, `insert(9, 2)`, `remove(1)`. What does `remove` return?

  *Answer:* `insert(7, 0)` - `find(0)` returns `head`, so 7 goes in front: `7 -> 4 -> 8 -> 15`. `insert(9, 2)` - `curr` starts at 7, takes one step to 4 and stops (`x = 1 = index - 1`), and `find` returns the `next` inside 4. Now 9 sits between 4 and 8: `7 -> 4 -> 9 -> 8 -> 15`. `remove(1)` - the loop never runs (`0 < 0` is false), so `find` returns the `next` inside 7, which points at 4. That pointer moves on to 9, 4 is deleted and returned. Final list `7 -> 9 -> 8 -> 15`, return value 4

+ *Short answer.* Suppose `find` returned `ListNode<T>*` instead of `ListNode<T>*&`. What goes wrong in `insert`? In `remove`?

  *Answer:* `find` would hand back a copy of the pointer. In `insert`, `nodeAtIndex = newNode` only changes the local copy, so the new node is never linked into the list and leaks. In `remove`, `toRemove = toRemove->next` also changes only the copy, but `delete temp` still frees the node. The list keeps pointing at deleted memory (a dangling pointer), and using it later is undefined behavior

+ *Edge cases of `find`.* The list is `4 -> 8 -> 15`. What does `find(10)` return? What happens on `insert(5, 10)`? On `remove(10)`?

  *Answer:* `curr` walks 4, 8, 15 and stops there because `15->next` is `nullptr`. `find(10)` returns that `nullptr` by reference, the real `next` field inside 15. `insert(5, 10)` sets the new node's `next` to `nullptr` and points 15 at it, so 5 is appended: `4 -> 8 -> 15 -> 5`. `remove(10)` sets `temp` to `nullptr` and then reads `temp->data`, which dereferences a null pointer and crashes (undefined behavior). Nothing is there to remove

+ *Runtime.* What is the runtime of this loop on a linked list with $n$ nodes? On an array list?
  ```cpp
  for(int i = 0; i < n; i++) {
      std::cout << list[i] << std::endl;
  }
  ```

  *Answer:* On a linked list, `list[i]` calls `find(i)`, which walks about $i$ nodes. The total is $0 + 1 + dots + (n - 1) approx n^2 / 2$, so $O(n^2)$. On an array list each `list[i]` is $O(1)$, so the loop is $O(n)$

+ *True or false.* With a `tail` pointer, removing the last node of a singly linked list is $O(1)$

  *Answer:* False. Removing the last node means setting the second to last node's `next` to `nullptr` (and moving `tail` there). A singly linked node has no pointer back, so you have to walk from `head` to find that node, which is $O(n)$. The `tail` only makes *insert* at the back $O(1)$

+ *True or false.* A sorted linked list supports `find` in $O(log n)$ using binary search

  *Answer:* False. Binary search needs to jump to the middle in $O(1)$. In a linked list, reaching the middle is already a walk of $n/2$ nodes, so `find` stays $O(n)$. Only the sorted *array* list gets $O(log n)$

+ *True or false.* `pushBack` on an array list (with doubling) always runs in $O(1)$ time

  *Answer:* False. A call that finds `size == capacity` runs `addSpace`, which copies all $n$ elements, so that single call is $O(n)$. What is $O(1)$ is the *amortized* cost, the average over a long run of pushes

+ *Trace resizing.* Start with an empty array list (all three pointers `nullptr`, capacity 0) using the `addSpace` from this review. Push 1, 2, ..., 9. On which pushes does `addSpace` run? How many element copies happen in total? What are the final size and capacity?

  *Answer:* `addSpace` runs on pushes 1 (capacity $0 -> 1$, 0 copies), 2 ($1 -> 2$, 1 copy), 3 ($2 -> 4$, 2 copies), 5 ($4 -> 8$, 4 copies) and 9 ($8 -> 16$, 8 copies). That's 5 resizes and $0 + 1 + 2 + 4 + 8 = 15$ copies. Final size 9, final capacity 16

+ *Amortized.* Now push 1000 elements into an empty array list. About how many element copies does growing by 2 make, compared with doubling?

  *Answer:* Grow by 2 (starting from capacity 0, so the first resize makes capacity 2) - resizes happen on pushes 1, 3, 5, ..., 999 and copy $0, 2, 4, dots, 998$ elements. The total is $2(1 + 2 + dots + 499) = 499 dot 500$, so 249,500 copies, which is about $n^2/4$. Doubling - resizes on pushes 1, 2, 3, 5, 9, ..., 513 copy $0, 1, 2, 4, dots, 512$ elements, for a total of $1023$ copies, which is about $n$

+ *Find the bug.* What's wrong with this `remove`?
  ```cpp
  template <typename T>
  T List<T>::remove(int index) {
      ListNode<T>*& toRemove = find(index);
      T val = toRemove->data;
      toRemove = toRemove->next;
      delete toRemove;
      return val;
  }
  ```

  *Answer:* After `toRemove = toRemove->next`, `toRemove` points at the node *after* the removed one. So `delete toRemove` frees the wrong node. That node is still linked into the list (a dangling pointer), while the node we meant to remove is unreachable and leaks. The fix is to save the node in `temp` before moving the pointer and `delete temp` afterwards. (If the removed node was the last one, `toRemove` is `nullptr` and nothing gets freed, but the removed node still leaks)

+ *Find the bug.* This `addSpace` leaves out `size = data + currentSize;`. What happens on the next `pushBack`?

  *Answer:* `size` still points into the old buffer, which `delete[] data` just freed. `pushBack` then does `*size = value`, a write to freed memory (undefined behavior). The new buffer also never sees the value, and `size == capacity` stops being a valid "full" check, since the two pointers now point into different buffers

+ *Code.* Write `T& operator[](int index)` for the linked list. Why is it fine to store the result of `find` in a plain `ListNode<T>*` here, when `insert` needs a `ListNode<T>*&`?

  *Answer:* `operator[]` never changes which node a pointer points at. It only reads the node, and a copy of the pointer still leads to the same node, so returning `loc->data` by reference still gives the caller the real data inside the list. `insert` has to change the pointer itself, so it needs the reference. Runtime is $O(n)$ because of `find`

  ```cpp
  template <typename T>
  T& List<T>::operator[](int index) {
      ListNode<T>* loc = find(index);
      return loc->data;
  }
  ```
