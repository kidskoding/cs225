#import "../diagrams.typ": array-cells

= Lambdas

#quote(block: true)[NOTE: This is a simple lesson reviewing iterators and lambda functions from CS 128!]

== Iterators

From 128, we know that there are *three* types of iterators:

+ *Forward*
  - Only moves in the *forward* direction,
  - *Operations*: `++it` (increment), `*it` (dereference), `==` and `!=` (comparison)
  - *Example*: Singly `LinkedList` iterator, where you can go through the list once from start to end, but can't go backwards

+ *Bidirectional*
  - Can move in *both directions* (forward and backward)
  - *Operations*: Everything from Forward, plus `--it` (decrement)
  - *Example*: Doubly linked list iterator and `std::set` iterator
  - You can traverse forward with `++` or backward with `--`

+ *Random Access*
  - Can *jump to any position* in constant time
  - *Operations*: Everything from Bidirectional, plus `it + n`, `it - n`, `it[n]`, `<`, `>`, etc.
  - *Example*: `std::vector` iterator, array pointers
  - You can do `it + 5` to jump 5 positions ahead, or `it[10]` to access element 10

== Lambdas

In C++, a *lambda function* is an *anonymous function* you can define on the fly and inline. This means that I define and write the function right when I use it, instead of somewhere else

This is typically used for short snippets of code like callbacks, custom sorting, or quick operations that don't necessarily need a separate named function.

Lambda functions are so useful because they allow us to use functions as *data*. This means that the function itself is a value that can be stored, passed around, and manipulated!

*Lambdas consist of 3 things*

+ Capture, notated in `[ ]` - specifies which variables from the surrounding scope the lambda can access and whether it captures them by value (copy) or by reference
+ Parameter, notated in `( )` - The list of parameters with a type and name specified and separated with commas
+ Body, notated in `{ }` - The body of the lambda

For example,

`auto isBig = [big](int num) { return num >= big; };`

- `[ ]` contains the variables within scope that the lambda "captures" for it to use. In this example, this variable is `big`
- `( )` contains the parameters needed to pass into the function
- `{ }` contains the body of the function

Take a look at a popular function used in excel, `COUNTIF`. This function counts the number of cells in a range that meet a specific criteria

Suppose the criteria is that any integer, $x$, is less than 5. To code this in C++ we would do,

```cpp
bool lessThan5(int x) {
    return x < 5;
}

/** Counts the values in `data` that are less than 5
 * Runtime: O(n)
 */
int countIf(std::vector<int>& data) {
    return std::count_if(data.begin(), data.end(), lessThan5);
}
```

In @lambda-count-if-trace, for example, `count_if` calls `lessThan5` on every value from `begin()` up to `end()`, and only 3, 1, and 4 (highlighted) pass.

#figure(
  array-cells(3, 8, 1, 6, 4, highlight: (0, 2, 4), marks: (begin: 0, end: 5)),
  caption: [Example: `count_if` walks from `begin()` up to, but not including, `end()` and counts the highlighted values less than 5, returning 3],
) <lambda-count-if-trace>

However, `lessThan5` is an unnecessary function when you can achieve the same result more concisely and directly using a lambda expression inline, avoiding extra named functions and keeping the code simpler and easier to read.

To solve this problem, we can use a *lambda*, like the one below

```cpp
auto lessThan5 = [](int x) { return x < 5; };
```

this makes our `countIf` function much more readable

```cpp
/** Counts the values in `data` that are less than 5
 * Runtime: O(n)
 */
int countIf(std::vector<int>& data) {
    auto lessThan5 = [](int x) { return x < 5; };
    return std::count_if(data.begin(), data.end(), lessThan5);
}
```
