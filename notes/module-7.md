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

A bidirectional iterator could also be implemented in a data structure, where it can traverse through elements **forwards** and **backwards**. 

With these requirements, how would we implement `begin()` and `end()` with the example data structure mentioned earlier in this module?

## Implementing `begin()` and `end()` for `Array` and `LinkedList`

| Data Structure | `::begin` | `::end` |
| ------------------| -------------------- | ------- |
`LinkedList` | `Iterator(head_)` | `Iterator(nullptr)` |  
`Array` | `Iterator() { index = 0; }` or `Iterator(0)` | `Iterator(size)` 

Lets explain the table above for an `Array` and `LinkedList`

- `LinkedList` 
	- We would implement `begin()` by having our `Iterator` constructor take in the head of the `LinkedList`, which is `this->head_`, or simply `head_`
		- The reason why this intuitively makes sense is because the beginning of our `LinkedList` is a pointer to the first element of the `LinkedList`, which is simply `head_`
	- We would implement `end()` by returning our `Iterator` object, where it takes in a `nullptr`
		- This also intuitively makes sense because the end of a `LinkedList` occurs when a node no longer holds a pointer to its next node, when this happens its pointer is set to `nullptr`

- `Array` 
	- We would implement begin by having our constructor set our `index` instance variable to `0`. This makes sense because the $0^{th}$ index is always the first element in an array
		- You could also have the `Iterator` constructor take in a $0$
	- We would implement `end()` by returning `Iterator(size)`. This makes sense because size is the last element plus 1 in an array! 

### Iterator Usage Example with `std::vector`

Take a look at the following `Animal` class below

```
struct Animal  {
	std::string name, food;
	bool big;
	Animal(std::string name = "blob", std::string food =  "you", bool big = true) : name(name), food(food), big(big)  {  }
};  

int main()  {
	Animal g("giraffe", "leaves", true), p("penguin", "fish", false), b("bear");
	std::vector<Animal> zoo;

	zoo.push_back(g);
	zoo.push_back(p);
	zoo.push_back(b);

	for(std::vector<Animal>::iterator it = zoo.begin();  it != zoo.end(); it++)  {
		std::cout << it->name << " " << it->food << std::endl;
	}
	return 0;
}
```

1. `Animal` stores 3 things, `name`, `food`, which describe the animal's name, food, and a boolean `big` that determines whether an `Animal` is big or not.
2. The `main` function creates 3 `Animal` objects and stores them in a `std::vector`. We then use an iterator to loop through the objects in the `std::vector`. 

However, take a look at a snippet of the code above, specifically the part that utilizes an iterator

```
for(std::vector<Animal>::iterator it = zoo.begin();  it != zoo.end(); it++)  {
	std::cout << it->name << " " << it->food << std::endl;
}
```

one of the problems with this code is using the post-increment operator over the pre-increment operator. Luckily, `std::vector` implements this operator to work for its iterator, so this isn't an issue in our example code. 

However, if we wanted to implement an iterator minimally, we would use the pre-increment operator (`++it`)
- If I were to do `it++`, then post increment would create a copy of  the current iterator, store that iterator, 
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTIwMzQwOTgyNDIsMTkxMjExNzY2OCwtOT
E0NjUwODg5LC0yMDI1Mzg4Mzg4LDYzOTE0Nzg0NiwxMzIxNDI3
NjIwLDIwMTg0Nzk4NjZdfQ==
-->