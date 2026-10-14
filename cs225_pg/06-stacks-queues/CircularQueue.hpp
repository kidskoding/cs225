// CircularQueue.hpp

#pragma once
#include "CircularQueue.h"
#include <stdexcept>

/** Creates an empty queue with room for `capacity` elements before it has to grow
 * Runtime: O(1)
 */
template <typename T>
CircularQueue<T>::CircularQueue(unsigned int capacity)
    : items(new T[capacity]), capacity(capacity), size(0), start(0) { }

/** Frees the array holding the queue
 * Runtime: O(1)
 */
template <typename T>
CircularQueue<T>::~CircularQueue() { delete[] items; }

/** Adds an element to the rear of the queue
 * Runtime: amortized O(1)
 */
template <typename T>
void CircularQueue<T>::enqueue(T e) {
    // grow the array if the queue is full, just like an `ArrayList`
    if(size == capacity) {
        addSpace();
    }

    // the next open spot is `size` past the front, wrapping around the end of the array
    items[(start + size) % capacity] = e;

    // increment the queue size
    ++size;
}

/** Removes and returns the element at the front of the queue
 * Runtime: O(1)
 */
template <typename T>
T CircularQueue<T>::dequeue() {
    // throw a runtime error if the queue is empty
    if(size == 0) {
        throw std::runtime_error("Queue is empty");
    }

    // get the value from the front of the queue
    T value = items[start];

    // move the front forward; the old value stays in memory but is no longer part of the queue
    start = (start + 1) % capacity;

    // decrement the queue size, since we removed an element
    --size;

    // return the value of the element dequeued
    return value;
}

/** Returns `true` if the queue is empty; `false` otherwise
 * Runtime: O(1)
 */
template <typename T>
bool CircularQueue<T>::isEmpty() {
    // if the size is 0, the queue is empty
    return size == 0;
}

/** Doubles the array, copying the queue over in order so it starts back at index 0
 * Runtime: O(n)
 */
template <typename T>
void CircularQueue<T>::addSpace() {
    // double the capacity, or start at 1 if the queue had no space at all
    unsigned int newCapacity = capacity * 2;
    if(newCapacity == 0) {
        newCapacity = 1;
    }

    // copy items[start], items[start + 1], ... in queue order, wrapping around as needed
    T* newItems = new T[newCapacity];
    for(unsigned int i = 0; i < size; i++) {
        newItems[i] = items[(start + i) % capacity];
    }

    // free the old array and point at the new one, which starts at index 0
    delete[] items;
    items = newItems;
    capacity = newCapacity;
    start = 0;
}
