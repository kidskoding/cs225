# Module 7 - Iterators

One concept that is often in the scope of DSA is the **iterator**. An iterator is an object that traverses through all the elements/items in a data structure.

Suppose we had 3 data structures, `Array`, `LinkedList`, and a `Hypercube` (also known as a tesseract and is a 4D cube). How would we be able to traverse through every element in this data structure?

The solution is simply an iterator, which provides encapsulated access to our data in a data structure. Each data structure, `Array`, `LinkedList`, and `Hypercube` has its own way to get all its elements.

## Iterate through data in each data structure

| Data Structure | Current Location | Current Data | Next
| ------------------| -------------------- | --------------- | ------- |
`LinkedList` | `ListNode*` (named `cur`) | `cur->data` | `cur = cur->next` | 
`Array` | `index` | `data[index]` | `++index` |
`Hypercube` | `(x, y, z)` (a list or tuple of dimensions) | ?? (cannot be determined) | ?? (cannot be determined)

These intuitively make sense because we know how these data structures work. With an array, we can use its index to access an element, a `LinkedList` we can hold a pointer to the next node, etc.

But if we don't know how the data structure works, it will be very difficult to implement an iterator for it because we wouldn't know how to iterate through its elements.

## Iterators with respect to Classes

Every class that implements an iterator must have the following **two pieces**. 

1. Have two methods
	- `begin()` - Return iterator to the start of the item in a container
	- `end()` - Returns iterator to the end of the item in a container




<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE1MjE1MTIxNzQsMjAxODQ3OTg2Nl19
-->