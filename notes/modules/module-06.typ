#import "../diagrams.typ": array-cells

= Stacks and Queues

One of the biggest problems with both `ArrayList` and `LinkedList` is that accessing elements can sometimes be slow. Recall that the runtime complexity is `O(1)` to remove an element at the beginning and end and `O(n)` for elements not at the beginning/end.

Therefore, if we want `O(1)` insertion and removal, we need a faster data structure, which introduces Stacks and Queues.

This lecture will introduce Stacks, but will only fully cover the Queue implementation. The next lecture will cover the Stack implementation in depth along with introducing another new topic

== Queues

Queues are everywhere and are used in an enormous amount of computer hardware. A Queue is like a list, but with a fixed order of *FIFO (First In First Out)*.

FIFO is a good mnemonic that helps remember how queues fundamentally work. *This means that the first element in the queue will be the first element out of the queue*. Some may also refer the FIFO mnemonic as LILO - Last In Last Out, but the idea behind remembering what a queue does is still fundamentally the same.

A queue is like a *line of people* (funnily enough a line in British English is called a queue!). Suppose people would line up to ride on the scariest rollercoaster in town. The first person who is in line will be the first person who will leave the line to go on the rollercoaster. Similarly, if someone joins the line for the rollercoaster they will be placed at the end of the line.

Queues have a simple implementation because they only really need two core functionalities, `enqueue()` and `dequeue()`.

- `enqueue()` will add elements to the end of the queue
- `dequeue()` will remove elements at the front of the queue

These functions are both `O(1)`, meaning adding and removing is constant time. This is because these functionalities happen at the back and front of the queue for `enqueue()` and `dequeue()` respectively, meaning we don't have to deal with the other elements in the queue. In @queue-enqueue-dequeue, for example, 5 joins at the back and 3 leaves from the front, and 4 never moves.

#figure(
  grid(
    columns: 5,
    column-gutter: 1em,
    align: horizon,
    array-cells(3, 4, none, none, marks: (front: 0, back: 1)),
    $stretch(->)^"enqueue(5)"$,
    array-cells(3, 4, 5, none, marks: (front: 0, back: 2)),
    $stretch(->)^"dequeue()"$,
    array-cells(none, 4, 5, none, marks: (front: 1, back: 2)),
  ),
  caption: [Example: `enqueue(5)` joins at the back, then `dequeue()` removes 3 from the front],
) <queue-enqueue-dequeue>

== Stacks

Like a Queue, a Stack also has a fixed order, but it works a little bit differently than a Queue. This order is referred to as *LIFO (Last In First Out)*.

LIFO is a good mnemonic that helps remember how stacks fundamentally work. *The last item put into the stack will be the first item out of the stack*. Some may also refer to the LIFO mnemonic as FILO - First In Last Out, but the idea behind remembering what a stack does/will do is still fundamentally the same.

A Stack is best described when thinking about a stack of plates in the kitchen. You add plates to the top, but remove plates from the top. You can't touch any other plate underneath until it appears at the top (well you could but the plates on top will topple over and break!).

Stacks also a simple implementation because they also only really need two core functionalities, `push()` and `pop()`.

- `push()` will add elements to the top of the stack
- `pop()` will remove elements from the top of the stack

If we store a stack in an array, both operations happen at `top`, as you can see in @queue-stack-push-pop: `push(5)` puts 5 on top and `pop()` takes that same 5 right back off.

#figure(
  grid(
    columns: 5,
    column-gutter: 1em,
    align: horizon,
    array-cells(3, 4, none, none, marks: (top: 1)),
    $stretch(->)^"push(5)"$,
    array-cells(3, 4, 5, none, marks: (top: 2)),
    $stretch(->)^"pop()"$,
    array-cells(3, 4, none, none, marks: (top: 1)),
  ),
  caption: [Example: a stack stored in an array. `push(5)` and `pop()` both work at `top`, so `pop()` returns 5, the last element pushed],
) <queue-stack-push-pop>

These functions are also both `O(1)`, meaning adding and removing is constant time. This is because these functionalities both happen at the top of the stack, meaning we don't have to deal with the other elements in the queue.

== Stacks vs. Queues

- Stacks operate upon the mnemonic LIFO - *Last In First Out* (last element in is the first element out), while Queues operate upon the mnemonic FIFO - *First In First Out* (first element in is the first element out)
- Insertion/Removal on a Stack happens at the same end (the top), while Insertion/Removal on a Queue happens at different ends, which are the back and front respectively.
  - Regardless of this, insertion/removal are `O(1)` because they happen at the ends of the Stack/Queue

== `CircularQueue` Implementation - `enqueue` and `dequeue`

Take a look at the following `CircularQueue` implementation below

```cpp
// CircularQueue.h

#pragma once

template <typename T>
class CircularQueue {
public:
    /** Adds an element to the rear of the queue
     * Runtime: amortized O(1)
     */
    void enqueue(T e);

    /** Removes and returns the element at the front of the queue
     * Runtime: O(1)
     */
    T dequeue();

    /** Returns `true` if the queue is empty; `false` otherwise
     * Runtime: O(1)
     */
    bool isEmpty();
private:
    // Pointer to the dynamically allocated array holding the queue elements
    T* items;

    // Total capacity of the queue (number of elements it can hold)
    unsigned int capacity;

    // Current number of elements in the queue
    unsigned int size;
};
```

This queue is an Array implementation, where data is stored in an array that `items` points to.

Before implementing this queue, we need to understand how the functionality of `enqueue()` and `dequeue()` fully work.

- Recall that `enqueue()` adds elements to the back of a queue. From a code standpoint, we insert elements by writing `items[size]`, inserting at the next most empty place in our `items` array
  - Recall that `capacity` represents the total length of the `items` array, while `size` represents the total number of elements the array has
  - Suppose we called `enqueue(3)`. This inserts 3 at the back of the array, where `items` now has a size of 1
    - This means that if we were to call `enqueue(4)`, this means that `items[1]` will in fact represent the proper position to place the next element in the queue, which in this case is 4.
  - After both calls, `items` looks like @queue-items-after-enqueue, with 3 at index 0, 4 at index 1, and two empty slots left over

#figure(
  array-cells(3, 4, none, none),
  caption: [`items` after `enqueue(3)` and `enqueue(4)`, with a capacity of 4],
) <queue-items-after-enqueue>

- `dequeue()` removes elements from the front of a queue. From a code standpoint, we return the element at the front of a queue and then return it.
  - However, in order to properly implement this, we need to track where to remove elements from. This means adding a new variable, called `start`, where `items[start]` represents the element to remove from a queue. `size` would then decrement by 1 since an element was removed.
  - Since `items[start]` removes elements from a queue, `items[size]` will no longer work to insert additional elements from a queue.
    - This is because `items[size]` represents the last element in `items`, not the next index in the array to insert the new element.
    - To fix this issue, we can write `items[size + start]` to properly insert new elements into the queue. This is because start represents the index in `items` to remove an element, and size represents the number of elements `items` contains, so the next available spot in memory would be `start + size`
  - Remember that this doesn't free the data from memory, the data is still occupied in memory, it's just that the queue no longer considers the dequeued element to be part of the queue, which is done programmatically by simply updating `start`
  - Notice in @queue-dequeue-start how `start` moves from 0 to 1 after a `dequeue()`, even though the 3 is still sitting in `items[0]`

#figure(
  grid(
    columns: 3,
    column-gutter: 1.5em,
    align: horizon,
    array-cells(3, 4, none, none, marks: (start: 0)),
    $stretch(->)^"dequeue()"$,
    array-cells(3, 4, none, none, marks: (start: 1)),
  ),
  caption: [Example: `dequeue()` returns `items[0]` (3) and moves `start` to 1. The 3 is still in memory but is no longer part of the queue, and the next `enqueue` writes to `items[start + size]`, index 2],
) <queue-dequeue-start>

This is great, `enqueue()` and `dequeue()` work perfectly, until we come across another core issue. What if `items` is full? Since `items` is full and we were to insert elements using `items[start + size]`, our index would simply be out of bounds, since `start + size` exceeds the total size of `items`

- To fix this problem, we need a way to loop back from the beginning of `items`, and in programming this is referred to as the modulo operator `%`.
  - If we modulo `start + size` by capacity, we ensure that once the index reaches the end of the array, it wraps around back to the beginning, which effectively prevents an index out of bounds access into `items`
  - Therefore, `items[(size + start) % capacity]` will insert elements into `items` and `items[start % capacity]` will remove elements from `items`
    - This works because when we call `items[(size + start) % capacity]` and `items[start % capacity]`, `start` ensures that we overwrite memory that has already been removed by the queue.
  - In @queue-circular-wrap, for example, `enqueue(7)` wraps around to index 0, right where the dequeued 3 used to be

#figure(
  grid(
    columns: 3,
    column-gutter: 1.5em,
    align: horizon,
    array-cells(3, 4, 5, 6, marks: (start: 2)),
    $stretch(->)^"enqueue(7)"$,
    array-cells(7, 4, 5, 6, marks: (start: 2), highlight: (0,)),
  ),
  caption: [Example: with `start = 2`, `size = 2`, and `capacity = 4`, the queue is 5, 6. `enqueue(7)` writes to index `(2 + 2) % 4 = 0`, wrapping around over the already dequeued 3],
) <queue-circular-wrap>

So great, this queue implementation is amazing now, but there is still one more problem. What if the queue is actually full, where `size == capacity`? (recall that this typically happens when you enqueue a bunch of elements to the point where there is no more available allocated memory in `items` to place another element)

- To solve this problem, we use the same approach as the `ArrayList`.
  - Create a new container by doubling the `capacity` and then copy all elements from `items` into the new container
  - Update the `items` pointer to point to the newly made container.
- However, this implementation poses another problem because the `start` of the queue is no longer the `0`th element.
  - To solve this, when copying, we set the elements in the new container to correspond to the order of the queue by copying `items[start]`, then `items[start + 1]`, `items[start + 2]`, and so on, wrapping around as needed
  - You can see this copy in @queue-resize-unwrap: the wrapped queue 5, 6, 7, 8 starts at index 2, but after copying it starts back at index 0

#figure(
  grid(
    columns: 3,
    column-gutter: 1.5em,
    align: horizon,
    array-cells(7, 8, 5, 6, marks: (start: 2)),
    $->$,
    array-cells(5, 6, 7, 8, none, none, none, none, marks: (start: 0), highlight: (0, 1, 2, 3)),
  ),
  caption: [Example: a full queue 5, 6, 7, 8 that has wrapped around. Copying from `start` in queue order puts it back at index 0 of the doubled array],
) <queue-resize-unwrap>

This effectively describes implementing a queue in depth via a `CircularQueue`. In a `CircularQueue`, we use a dynamically allocated array, like `items` that circles around when inserting an element goes outside the array's dynamically allocated memory!

Typically from a hardware standpoint, we don't resize a queue. In hardware, memory is already preallocated and doesn't change at runtime.
