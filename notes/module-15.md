
# Module 15 - Lambdas

> NOTE: This is a simple lesson reviewing iterators and lambda functions from CS 128!

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


<!--stackedit_data:
eyJoaXN0b3J5IjpbMTE5NDE1ODkzNCwxMTY4NTg0NzAzLDM2Mj
AxODExLC0yNDk4NDE3NTVdfQ==
-->