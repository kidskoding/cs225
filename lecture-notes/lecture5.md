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

**Amortized Analysis** describes how 