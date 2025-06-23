

# Module 4 - `ArrayList`, an Array implementation of a `List`

There is another way to implement a `List`, which is by using an Array. This is simply implementing a C++ `std::vector`, or in broader programming terms, an `ArrayList`

The primitive foundation of an `ArrayList` is based on the idea of storing elements in a chunk of contiguous memory, allowing efficient access and manipulation. The list starts with a raw array and builds abstraction over it to support dynamic resizing, safe memory handling, and user-friendly operations, like the ones covered in `LinkedList`

We begin by figuring out what we need to store the list. In the `LinkedList`, we stored individual `ListNode`s, where they each held data along with a pointer to the next node, which allowed for easy chaining access between the nodes

However, in an `ArrayList` approach, we need to simply store a chunk of memory somehow, while this is typically a `std::vector` in C++, we are actually implementing this, so we need a primitive array, as mentioned previously. Therefore, a chunk of memory is allocated using a **pointer**, where we can call this a generic type `T`. This is reflected in our `ArrayList` class below

```
// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:

private:
	// A pointer to the start of a chunk of memory
    T* data;
};
```

`data` is a pointer to a chunk of memory that will be allocated to the heap

In addition to this, we need to store the **size** and **capacity**, where the **size** represents how many items are actually in the list and the **capacity** represents how much space is available in the memory block

These both could be `int`s, or they could be pointers, where `size` represents a pointer to the end of the used portion of the array and `capacity` represents a pointer to the end of the allocated chunk of memory, or buffer. This approach is reflected in our code below,

```
// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:

private:
    T* data;
    T* size;
    T* capacity;
};
```

Now, the next idea to think about this `ArrayList` implementation is how do we add more space to the buffer? If the capacity is full, meaning that size and capacity both point to the same area in the buffer, then how would I resize the buffer to add additional data into the buffer?

The solution is to allocate some new buffer somewhere with a bigger space. Then, copy the data from the previous buffer along with its pointers (`size`, `capacity`, and `data`). This approach will be done with a private method, `addSpace()`. Our `ArrayList` ADT is updated below. Recall that this is a helper method that resizes the buffer, so therefore, it should be private.

```
// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:

private:
    T* data;
    T* size;
    T* capacity;

    void addSpace();
};
```

Notice that this is very expensive, which is why the `LinkedList` approach is often much more recommended

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

## `pushBack()`

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
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTE4MTk3NTAzOTldfQ==
-->