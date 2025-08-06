
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

This is typically used for short snippets of code like callbacks, custom sorting, or quick operations that don't necessarily need a separate named function

Take a look at a popular function used in excel, `COUNTIF`. This function counts the number of cells in a range that meet a specific criteria

Suppose the criteria is that any integer, $x$, is less than 5. To code this in C++ we would do,

```
bool lessThan5(int x) {
    return x < 5;
}

int countIf(std::vector<int>& data) {
    return std::count_if(data.begin(), data.end(), lessThan5);
}
```

However, `lessThan5` is an unnecessary function when you can achieve the same result more concisely and directly using a lambda expression inline, avoiding extra named functions and keeping the code simpler and easier to read.

To solve this problem, we can use a *
<!--stackedit_data:
eyJoaXN0b3J5IjpbMzgxNDY0NDg2LDE4NjM1NTMyMDksMTE2OD
U4NDcwMywzNjIwMTgxMSwtMjQ5ODQxNzU1XX0=
-->