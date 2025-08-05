// ArrayList.hpp

#include "ArrayList.h"

template <typename T>
void ArrayList<T>::pushBack(const T& data) {
    // add additional space to the buffer if `size` == `capacity`
    if(size == capacity) {
        addSpace();
    }

    // place the new element at the current end
    *size = data;

    // incrememnt the `size` pointer to now point to the new end of the filled buffer
    ++size;
}

template <typename T>
void ArrayList<T>::addSpace() {
    /* Reallocate the capacity of the buffer (similar to realloc in C);
     * typically that of double the original capacity
     */
    int newCapacity = capacity * 2;

    // if the original capacity is 0, set it to 1 to be minimal and memory efficient
    if(newCapacity == 0) {
        newCapacity = 1;
    }

    // allocate a new data buffer that is set to the updated capacity
    T* newData = new T[newCapacity];

    // calculate the number of elements currently in the `ArrayList`
    int currentSize = size - data;

    // copy all contents from the old data buffer into the new data buffer
    for(int i = 0; i < size; i++) {
        newData[i] = data[i];
    }

    // free the contents from the old buffer from memory
    delete[] data;

    // update the data pointer to point to the newly allocated buffer
    data = newData;

    // set the current capacity to the new capacity
    capacity = newCapacity;

    // update the size pointer to point to the correct position in the new buffer
    size = data + currentSize;
}