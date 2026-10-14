// CircularQueue.h

#pragma once

/** A FIFO queue stored in an array that wraps around, and doubles when it is full */
template <typename T>
class CircularQueue {
public:
    /** Creates an empty queue with room for `capacity` elements before it has to grow
     * Runtime: O(1)
     */
    CircularQueue(unsigned int capacity = 4);

    /** Frees the array holding the queue
     * Runtime: O(1)
     */
    ~CircularQueue();

    // the queue owns `items`, so copying it would free the same array twice
    CircularQueue(const CircularQueue&) = delete;
    CircularQueue& operator=(const CircularQueue&) = delete;

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
    /** Pointer to the dynamically allocated array holding the queue elements */
    T* items;

    /** Total capacity of the queue (number of elements it can hold) */
    unsigned int capacity;

    /** Current number of elements in the queue */
    unsigned int size;

    /** Index of the front element, the next one `dequeue` removes */
    unsigned int start;

    /** Doubles the array, copying the queue over in order so it starts back at index 0
     * Runtime: O(n)
     */
    void addSpace();
};
