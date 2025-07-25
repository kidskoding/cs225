#include "LLQueue.h"
#include "LinkedList.h"
#include <stdexcept>

template <typename T>
void LLQueue<T>::enqueue(T value) {
    ListNode<T> newNode = new ListNode<T>(value);
    
    if(isEmpty()) {
        head = tail = newNode;
    } else {
        tail->next = newNode;
        tail = newNode;
    }

    count++;
}

template <typename T>
T LLQueue<T>::dequeue() {
    if(isEmpty()) {
        throw std::runtime_error("cannot dequeue a queue with size 0");
    }

    ListNode<T>* toRemove = head;
    T temp = toRemove->data;
    head = toRemove->next;

    if(head == nullptr) { tail = nullptr; }

    delete toRemove;
    count--;

    return temp;
}

template <typename T>
int LLQueue<T>::size() const {
    return this->count;
}

template <typename T>
bool LLQueue<T>::isEmpty() const {
    return this->count == 0;
}
