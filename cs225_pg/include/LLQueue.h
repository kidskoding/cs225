// LLQueue.h

#include "LinkedList.h"

template <class T>
class LLQueue {
public:
    LLQueue() : head(nullptr), tail(nullptr), count(0) { }

    void enqueue(T value);
    T dequeue();
    bool isEmpty() const;
    int size() const;

private:
    ListNode<T>* tail;
    ListNode<T>* head;
    int count;
};
