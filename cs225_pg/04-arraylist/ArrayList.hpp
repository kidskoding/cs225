// ArrayList.hpp

#pragma once
#include "ArrayList.h"

/** Inserts data to the back of this `ArrayList`
 * Runtime: amortized O(1)
 */
template <typename T>
void ArrayList<T>::pushBack(const T& value) {
    // Add additional space to the buffer if `size` == `capacity`
    if(size == capacity) {
        addSpace();
    }

    // Place the new element at the current end
    *size = value;

    // Increment the `size` pointer to now point to the new end of the filled buffer
    ++size;
}

/** Returns the element at `index` by reference
 * Runtime: O(1)
 */
template <typename T>
T& ArrayList<T>::operator[](int index) {
    // the buffer is contiguous, so this is just pointer arithmetic
    return data[index];
}

/** Returns the number of elements in this `ArrayList` (`size - data`)
 * Runtime: O(1)
 */
template <typename T>
int ArrayList<T>::length() const {
    return size - data;
}

/** Returns how many elements fit in the buffer before it has to grow (`capacity - data`)
 * Runtime: O(1)
 */
template <typename T>
int ArrayList<T>::allocated() const {
    return capacity - data;
}

/** Allocates additional space to the buffer in this `ArrayList`
 * Runtime: O(n)
 */
template <typename T>
void ArrayList<T>::addSpace() {
    /* Reallocate the capacity of the buffer (similar to realloc in C)
     * Typically that of double the original capacity
     */
    int newCapacity = (capacity - data) * 2;

    // If the original capacity is 0, set it to 1 to be minimal and memory efficient
    if(newCapacity == 0) {
        newCapacity = 1;
    }

    // Allocate a new data buffer that is set to the updated capacity
    T* newData = new T[newCapacity];

    // Calculate the number of elements currently in the `ArrayList`
    int currentSize = size - data;

    // Copy all contents from the old data buffer into the new data buffer
    for(int i = 0; i < currentSize; i++) {
        newData[i] = data[i];
    }

    // Free the contents from the old buffer from memory
    delete[] data;

    // Update the data pointer to point to the newly allocated buffer
    data = newData;

    // Point `capacity` to the end of the new buffer
    capacity = data + newCapacity;

    // Update the size pointer to point to the correct position in the new buffer
    size = data + currentSize;
}
