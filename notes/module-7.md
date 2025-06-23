# Module 7 - Iterators

One concept that is often in the scope of DSA is the **iterator**. An iterator is an object that traverses through all the elements/items in a data structure.

Suppose we had 3 data structures, `Array`, `LinkedList`, and a `Hypercube` (also known as a tesseract and is a 4D cube). How would we be able to traverse through every element in this data structure?

The solution is simply an iterator, which provides encapsulated access to our data in a data structure. Each data structure, `Array`, `LinkedList`, and `Hypercube` has its own way of iterating through its data
- For example, an `Array` typically uses an index to iterate, where `index++` traverses through each element in an array
- Similarly, a `LinkedList` uses a pointer to iterate, where `cur->next` represents a pointer to the next `ListNode` in a `LinkedList`. This is shown in the table below

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
	- `begin()` - Return iterator to the start item in a container (index 0)
	- `end()` - Returns iterator to one past the end item in a container
		- `end()` can come in handy a lot to check if an item exists in an iterator.
		- If I want to find string `milk` in a `std::vector<std::string>` named `groceries`, i can write `milk != groceries.end()` to see if `groceries` contains milk.
		- If `milk` is found, `end()` will return an iterator to what it found (in this case is `milk`) or will return an iterator to `end()` saying that there is no milk in the list.
		- This is a useful tool because we get an extra feature in our data structures to say that an element does/does not exist

2. Must have the base class `std::iterator`, which requires us to minimally implement
	- `operator*()` to get the data, where `*it` is the data at iterator `it`
	- `operator++()` to move/traverse through the data in a data structure
		- This standardized approach is what allows us to iterate via a data structure regardless of whether or not we iterate via a pointer (`LinkedList`) or index (`Array`)
	- `operator!=()` , which compares a constant reference to an iterator (`const Iterator& i`) to an element in the data structure and check whether they are equal or not

There are also some other nice features that can be implemented in an iterator, one of which is the arrow operator `->` which accesses members of a pointer. 

- Recall that this is the shorthand for dereferencing a pointer and then calling its member, where 
`*(item).data` is equivalent to `item->data`. 

A bidirectional iterator could also b


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTEwMTEzNzcyNjQsMTMyMTQyNzYyMCwyMD
E4NDc5ODY2XX0=
-->