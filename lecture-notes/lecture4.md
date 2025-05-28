/*! \page md_lecture4 Lecture 4 - Linked List and List <vector>

Continuing off of [Lecture 3 - Lists and List ADT](\ref md_lecture3), we will expand on our List ADT, which in this scenario is an implementation of a **Linked List**

Recall the following characteristics of a `LinkedList`
- Stores `ListNode`s that are chained together via pointers
- Each `ListNode` contains its own data and holds a pointer to the next `ListNode` in the `List`

This is our current implementation of our `List` ADT

```
// List.h

#pragma once

template <typename T>
struct ListNode {
    T data; // the current data in the linked list
    ListNode<T>* next; // a pointer to the next node in the linked list
    ListNode(const T& data) : data(data), next(nullptr) { }
};

template<typename T>
class List {
private:
    ListNode<T>* head; // a pointer to the head of the linked list

public:
    void insertAtFront(const T& data);
    void insert(const T& data, int index);
    ListNode<T>*& find(int index);
};
```

[[Lecture 3 - Lists and List ADT]] covered two main capabilities that our List ADT must have, an `insertAtFront` function which inserts a `ListNode` at the front/head of the `LinkedList` and a `find` function which finds a `ListNode` by a given `index`

We will continue our discussion with the next function, `insert`. This is a generic function which will insert data into the `List` at a given index. Recall that this algorithm is done in three steps

1. Call `find` to find the `ListNode` at the given index
	1. Recall that `find` returns a reference of a pointer to a `ListNode`, written as a type `ListNode*&`
 2. Allocate the given data onto the heap
	 1. Returned pointer should not be a reference pointer! Make just a regular pointer
	 2. Recall that a reference pointer refers to an existing pointer! There is no existing pointer here, we make a new one when allocating onto the heap
 3. Make the newly created node point to the found `ListNode` at the given index
 4. Set the node found at the given index's pointer to the newly created node

This algorithm is shown in the code below

```
// List.hpp

#include "List.h"

/** Inserts data in the given index of a list
 *  Runtime: O(n)
 */
template <typename T>
void List<T>::insert(const T& data, int index) {
	// Call `find` to find the `ListNode` at the given index
	ListNode<T>*& nodeAtIndex = find(index);

	// Dynamically allocate the data to the heap
	ListNode<T>* newNode = new ListNode(data);

	// Reassign the next node of the newly created node to be the `ListNode` found at the given index
	newNode->next = nodeAtIndex;

	// Reassign the found `ListNode` at the given index's pointer to the newly created node from the given data
	nodeAtIndex = newNode;
}
```

This function has a $O(n)$ runtime, since it needs to traverse to the given position/index and then insert the newly created node of the given data

## operator[]

The next function our `List` ADT function must have is the operator `[ ]`. Recall that in C++ we can operator overload with a function that changes the behavior of the `[ ]` operator. 

The brackets operator will behave very similarly to the `find` function, but rather return the `data` by reference that the `ListNode` at the given index contains. This updates our `List` class like this (shown below)

```
// List.h

#pragma once

template <typename T>
struct ListNode {
    T data; // the current data in the linked list
    ListNode<T>* next; // a pointer to the next node in the linked list
    ListNode(const T& data) : data(data), next(nullptr) { }
};

template<typename T>
class List {
private:
    ListNode<T>* head; // a pointer to the head of the linked list

public:
    void insertAtFront(const T& data);
    void insert(const T& data, int index);
    ListNode<T>*& find(int index);
    T& operator[](int index);
};
```

This algorithm, therefore, works very simple

1. Find the `ListNode` at the given index (we already did this with the `find` function!)
2. Return that `ListNode`'s data (Every `ListNode` instance holds its own data!)

And the code for this function is below

```
// List.hpp

#include "List.h"

/** Returns the data by reference of the `ListNode` at the given index 
 *	Runtime: O(n)
 */
template <typename T>
T& List<T>::operator[](int index) {
	// Call `find` to find the `ListNode` at the given index	
	ListNode<T>* loc = find(index);

	// Return the data that the `ListNode` at the given index holds
	return loc->data;
}
```

This runtime is also $O(n)$ because it takes $n$ times to traverse through the list to find the `ListNode` at the given index to then return its data!

## remove

The next function is to remove data from our `List` at a given index. This updates our `List` class structure!

```
// List.h

#pragma once

template <typename T>
struct ListNode {
    T data; // the current data in the linked list
    ListNode<T>* next; // a pointer to the next node in the linked list
    ListNode(const T& data) : data(data), next(nullptr) { }
};

template<typename T>
class List {
private:
    ListNode<T>* head; // a pointer to the head of the linked list

public:
    void insertAtFront(const T& data);
    void insert(const T& data, int index);
    ListNode<T>*& find(int index);
    T& operator[](int index);
    T remove(int index);
};
```

The algorithm for this is once again simple

1. Find the `ListNode` at the given index, with our helper `find` function, lets call it `toRemove`
2. Create a `temp` `ListNode` containing the `ListNode` to be removed, lets call it `temp`
3. Create a variable containing `temp`'s `data`, can call this `val`
4. Set toRemove to the next `ListNode` in the `List`
5. delete the `temp` `ListNode` from memory (`temp` was what was removed)
6. return `val`

```
// List.hpp

#include "List.h"

/** Removes a `ListNode` by index and returns its associated data! 
 * 	Runtime: O(n)
 */
template <typename T>
T remove(int index) {
	// Find the `ListNode` to be removed
	ListNode<T>*& toRemove = find(index);

	// Create a temporary `ListNode` containing what should be removed
	ListNode<T>* temp = toRemove;

	// Create a `val` variable to store temp's data
	T val = temp->data;

	// Reassign `toRemove` to the next node in the `ListNode`
	toRemove = toRemove->next;

	// Delete `temp` from memory since we no longer need it
	delete temp;
	return val;
}
```

**A couple things about this algorithm**
- You need a pointer to the node you're removing so you can later delete it, which is what we call `toRemove`
- Creates a copy pointer to the node being removed called `temp`. We keep a separate reference so that we can return its data in the function
	- Without `temp`, once `toRemove = toRemove->next`, the previous node that `toRemove` stored is now lost
	- We need the original node that was stored in `toRemove` in order to be able to return the data that was removed from the `List`, which is why we store it in `temp!
- `delete temp`, ensures the memory allocated to `temp` is freed. We do this call because we know that the `List` no longer needs this `temp` `ListNode` (**`List` no longer needs to track it!**)

This wraps up the first implementation of `List`, which is a LinkedList

## Representing a `List` as a `std::vector`

Now onto the array implementation of a `List`. In this array implementation, we are really just implementing a C++ `std::vector` or `ArrayList`

The primitive foundation of an `ArrayList` is based on the idea of storing elements in a chunk of contiguous memory, allowing efficient access and manipulation. The list starts with a raw array and builds abstraction over it to support dynamic resizing, safe memory handling, and user-friendly operations, like the ones covered in LinkedList

We begin by figuring out what we need to store the list. In the `List` approach by using a LinkedList, we stored individual `ListNodes`, where they each held data along with a pointer to the next node, which allowed for easy chaining access between the nodes

However, in an `ArrayList` approach, we need to simply store a chunk of memory somehow, while this is typically a `std::vector` in C++, we are actually implementing this, so we need a primitive array, as mentioned previously. Therefore, a chunk of memory is allocated using a **pointer**, where we can call this a generic type `T`. This is reflected in our `ArrayList` class below

```
// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:

private:
	// A pointer to the start of a chunk of memory
    T* data;
};
```
`data` is a pointer to a chunk of memory that will be allocated to the heap

In addition to this, we need to store the **size** and **capacity**, where the **size** represents how many items are actually in the list and the **capacity** represents how much space is available in the memory block

These both could be ints, or they could be pointers, where `size` represents a pointer to the end of the used portion of the array and `capacity` represents a pointer to the end of the allocated chunk of memory, or buffer. This approach is reflected in our code below,

```
// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:

private:
    T* data;
    T* size;
    T* capacity;
};
```

Now, the next idea to think about this `ArrayList` implementation is how do we add more space to the buffer? If the capacity is full, meaning that size and capacity both point to the same area in the buffer, then how would I resize the buffer to add additional data into the buffer?

The solution is to allocate some new buffer somewhere with a bigger space. Then, copy the data from the previous buffer along with its pointers (`size`, `capacity`, and `data`). This approach will be done with a private method, `addSpace()`. Our `ArrayList` ADT is updated below. Recall that this is a helper method that resizes the buffer, so therefore, it should be private.

```
// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:

private:
    T* data;
    T* size;
    T* capacity;

    void addSpace();
};
```

Notice that this is very expensive, which is why the `LinkedList` approach is often much more recommended
