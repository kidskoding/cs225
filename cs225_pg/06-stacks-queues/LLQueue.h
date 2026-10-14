// LLQueue.h

#pragma once
#include "../03-lists/LinkedList.h"

/** A FIFO queue stored as a singly linked list with a head and a tail pointer */
template <class T>
class LLQueue {
public:
    /** Creates an empty queue
     * Runtime: O(1)
     */
    LLQueue() : head(nullptr), tail(nullptr), count(0) { }

    /** Adds an element to the end of the queue
     * Runtime: O(1)
     */
    void enqueue(T value);

    /** Removes and returns the element at the front of the queue
     * Runtime: O(1)
     */
    T dequeue();

    /** Returns `true` if the queue is empty; `false` otherwise
     * Runtime: O(1)
     */
    bool isEmpty() const;

    /** Returns the number of elements the queue holds
     * Runtime: O(1)
     */
    int size() const;

private:
    /** Pointer to the front of the queue */
    ListNode<T>* head;

    /** Pointer to the rear of the queue */
    ListNode<T>* tail;

    /** The element count in the queue */
    int count;
};
