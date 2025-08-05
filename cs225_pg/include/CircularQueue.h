// CircularQueue.h

#pragma once

template <typename T>
class CircularQueue {
public:
    CircularQueue(unsigned int capacity);
    ~CircularQueue();

    /** Adds an element to the rear of the queue */
    void enqueue(T e);

    /** Removes and returns the element at the front of the queue */
    T dequeue();

    /** Checks if the queue is empty (`true` if so, otherwise `false`) */
    bool isEmpty();
private:
    /** Pointer to the dynamically allocated array holding the queue elements */
    T* items;

    /** Total capacity of the queue (number of elements it can hold) */
    unsigned int capacity;

    /** Current number of elements in the queue */
    unsigned int size;

    /** Index of the front element */
    unsigned int front;

    /** Index of the rear element */
    unsigned int rear;
};
