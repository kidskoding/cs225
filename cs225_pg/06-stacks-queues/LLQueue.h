// LLQueue.h

#include "LinkedList.h"

template <class T>
class LLQueue {
public:
    LLQueue() : head(nullptr), tail(nullptr), count(0) { }

    /** Adds an element to the end of the queue */
    void enqueue(T value);

    /** Removes an element from the front of the queue */
    T dequeue();

    /** Checks if the queue is empty (`true` if so, otherwise `false`) */
    bool isEmpty() const;

    /** Returns the number of elements the queue holds */
    int size() const;

private:
    /** Pointer to the rear of the queue */
    ListNode<T>* tail;

    /** Pointer to the front of the queue */
    ListNode<T>* head;

    /** The element count in the queue */
    int count;
};
