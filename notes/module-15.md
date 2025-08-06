
# Module 15 - Lambdas

> NOTE: This is a simple lesson reviewing iterators and lambda functions from CS 128!

## Iterators

From 128, we know that there are **three** types of iterators:

1. **Forward**
	- Only moves in the **forward** direction,
	- **Operations**: `++it` (increment), `*it` (dereference), `==` and `!=` (comparison)
	- **Example**: Singly `LinkedList` iterator, where you can go through the list once from start to end, but can't go backwards

2. **Bidirectional**
	- Can move in **both directions** (forward and backward)
	- **Operations**: Everything from Forward, plus `--it` (decrement)
	- **Example**: Doubly linked list iterator and `std::set` iterator
	- You can traverse forward with `++` or backward with `--`

3. **Random Access**
	-  Can **jump to any position** in constant time
	-  **Operations**: Everything from Bidirectional, plus `it + n`, `it - n`, `it[n]`, `<`, `>`, etc.
	-  **Example**: `std::vector` iterator, array pointers
	-  You can do `it + 5` to jump 5 positions ahead, or `it[10]` to access element 10

## Lambdas

In C++, a **lambda function** is an **anonymous function** you can define inline. This means that I define and write the function right when I use it, instead of somewhere else

This is typically used for short snippets of code like callbacks, custom sorting, or quick operations without writing a separate named function.
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTExMTE2Nzg5NDIsMTE2ODU4NDcwMywzNj
IwMTgxMSwtMjQ5ODQxNzU1XX0=
-->