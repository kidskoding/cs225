/*! \page md_lecture5 Lecture 5 - Amortized Analysis

Continuing off of [lecture 4](\ref md_lecture4) about a `std::vector` implementation in C++, we defined the following things

- `data` - a contiguous chunk of memory allocated for our custom implemented `std::vector` or `ArrayList`
    - This will be allocated onto the heap, where we get a returned generic type pointer that points to this buffer/chunk of contiguous memory
- `size` - a generic type pointer that points to the area in memory where data is filled up
- `capacity` - a generic type pointer that points to the end of the allocated chunk of memory

Our helper `addSpace()` function must add data to the end of the allocated chunk of memory. However, this causes issues when the allocated chunk of memory is full with data. Recall that this occurs when `size == capacity`. 
- To solve this problem, we simply need to allocate a new buffer with a bigger capacity and then copy over the previous buffer's data along with the respective pointers to the buffer including `data`, `size`, and `capacity`

We will come back to this `addSpace()` helper function, but for now we will talk about the main public function that will use `addSpace()` called `pushBack()`, which is one very common function in a `std::vector`! Recall, that it simply inserts an element at the end of the list

We can update our `ArrayList` ADT like this,

```
// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:
    void pushBack(const T& data);
private:
    T* data;
    T* size;
    T* capacity;

    void addSpace();
};
```

The algorithm for `pushBack()` becomes simple with our helper `addSpace()` function

1. Check if `size == capacity`. If so, then call helper function `addSpace()` to add more space into the function
2. Then, deallocate the `size` pointer and set it equal to the new `data` parameter variable
    - we do this because this is how we place the given element at the end of the current end of the buffer  
    - Remember that `size` tracks the end of filled data in the buffer and `capacity` tracks the end of the entire buffer!
3. Add 1 to the `size` pointer to set the pointer to the new current end of the buffer

The code for this algorithm is shown below

```
// ArrayList.hpp

#include "ArrayList.h"

/** Inserts data to the back of this `ArrayList`
 *  Runtime: O(1)
 */
template <typename T>
void ArrayList<T>::pushBack(const T& data) {
    // Add additional space to the buffer if `size` == `capacity`
    if(size == capacity) {
        addSpace();
    }

    // Place the new element at the current end
    *size = data;

    // Incrememnt the `size` pointer to now point to the new end of the filled buffer
    ++size;
}
```

## Amortized Analysis

**Amortized Analysis** is a technique commonly used in Computer Science to analyze the **average running time** per operation
over a sequence of operations in an algorithm. Rather than focusing on the worst case cost for a single operation (this is simply **Big-O**), amortized analysis evaluates the overall cost when spreaded out evenly across all operations performed.

This is useful because even though some operations in an algorithm can cost a lot more than others, the average cost per operation is low when many operations are performed consecutively.

### Resizing by adding 2 elements every time

One way to implement our `addSpace()` function is to resize the buffer by increasing the `capacity` by 2 each time the array is full. This means that when more space is needed, `addSpace()` allocates a new array with a capacity of `capacity + 2`. Recall that after this, `addSpace()` then needs to copy all the data from the previous buffer to the new buffer and then update the buffer's internal pointers.

Since `addSpace()` needs to copy all the data from the previous buffer to the new buffer when updating its capacity by `capacity + 2`, this means that the algorithm has a runtime of \f$O(n)\f$, where \f$n\f$ represents the number of elements currently in the array. This is because each element must be copied one by one into the new buffer.

> Click [here to view the evaluated amortized cost of this algorithm](https://www.overleaf.com/read/sncwntpxpnhh#c3df0b). Please view subsection 1.1 to explain the amortized analysis of this operation

### Resizing by doubling the elements every time

Now suppose, we resized the `ArrayList` by doubling the capacity everytime. Each time we resize, the time it takes to do so doubles from 1, 2, 4, 8, 16, etc. This is because each resize involves copying all the elements from the old array into a new array that is twice as large.

> Click [here to view the evaluated amortized cost of this algorithm](https://www.overleaf.com/read/sncwntpxpnhh#c3df0b). Please view subsection 1.2 of this document to explain the amortized analysis of this operation

Since the amortized cost when doubling the capacity each resize is O(1), it makes more sense to implement the `addSpace()` function using this resizing method

Now to implement our `addSpace()` function into our data buffer, we need to do a series of steps following our resize approach

1. Reallocate the data buffer, typically done by doubling its capacity
2. Check if the original capacity is 0. If so, set the new capacity to 1. This is to ensure memory efficiency
3. Allocate a new data buffer equivalent to the new capacity (which was double the original capacity)
4. Calculate the number of elements currently in the `ArrayList` (recall that this can be done with our `size` and `data` pointers by doing `size` - `data`)
5. Copy all contents from the old data buffer into the new data buffer
6. Free all the contents from the old data buffer and update the pointer of the new data buffer
7. Update the capacity to the new capacity and update the size pointer to point to the correct position in the new buffer

The code for this algorithm that reflects these series of steps is shown below,

```
// ArrayList.hpp

#include "ArrayList.h"

/** Allocates additional space to the buffer in this `ArrayList`
 *  Runtime: O(n)
 */
template <typename T>
void ArrayList<T>::addSpace() {
    /* Reallocate the capacity of the buffer (similar to realloc in C)
     * Typically that of double the original capacity
     */
    int newCapacity = capacity * 2;

    // If the original capacity is 0, set it to 1 to be minimal and memory efficient
    if(newCapacity == 0) {
        newCapacity = 1;
    }

    // Allocate a new data buffer that is set to the updated capacity
    T* newData = new T[newCapacity];

    // Calculate the number of elements currently in the `ArrayList`
    int currentSize = size - data;

    // Copy all contents from the old data buffer into the new data buffer
    for(int i = 0; i < size; i++) {
        newData[i] = data[i];
    }

    // Free the contents from the old buffer from memory
    delete[] data;

    // Update the data pointer to point to the newly allocated buffer
    data = newData;

    // Set the current capacity to the new capacity
    capacity = newCapacity;

    // Update the size pointer to point to the correct position in the new buffer
    size = data + currentSize;
}
```

This will effectively add more space to our buffer (double that the original) when its capacity is full

### Amortized Costs of various operations on various List Implementations

| Operation | **Singly Linked List** | **Array** |
| --------- | --------------------- | --------- |
| Insert/Remove at front/back | O(1) | O(1)* (amortized) |
| Insert/Remove given a pointer | O(1) | O(n) | 
| Insert/Remove at a given index | O(n) | O(n) |
| Find a value in a list | O(n) | O(n) |
| Find a value in a sorted list | O(n) | O(log n) |

The `*` represents **amortized** cost, which means the average cost per operation over a sequence of operations. Whether to use the amortized case depends on the application you are building. Amortized analysis isn’t ideal for explaining the cost of a single, individual operation, but rather useful for understanding the average cost spread across many operations.
