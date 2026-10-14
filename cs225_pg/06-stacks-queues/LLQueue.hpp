// LLQueue.hpp

#pragma once
#include "LLQueue.h"
#include <stdexcept>

/** Adds an element to the end of the queue
 * Runtime: O(1)
 */
template <typename T>
void LLQueue<T>::enqueue(T value) {
    // create a new node with the given data
    ListNode<T>* newNode = new ListNode<T>(value);

    if(isEmpty()) {
        // assign head and tail to the new node (there is only one element in the queue)
        head = tail = newNode;
    } else {
        // assign tail's next node to the new node
        tail->next = newNode;

        // assign tail to the new node
        tail = newNode;
    }

    // increment the element count in the queue
    count++;
}

/** Removes and returns the element at the front of the queue
 * Runtime: O(1)
 */
template <typename T>
T LLQueue<T>::dequeue() {
    // check if queue is empty (cannot dequeue on a queue with size 0)
    if(isEmpty()) {
        throw std::runtime_error("cannot dequeue a queue with size 0");
    }

    // retrieve the element needed to be removed and its data
    ListNode<T>* toRemove = head;
    T temp = toRemove->data;

    // reassign the front to the removed element's next pointer
    head = toRemove->next;

    // reassign `tail` to null if `head` is null
    if(head == nullptr) { tail = nullptr; }

    // free `toRemove` from memory
    delete toRemove;

    // decrement the element count from the queue
    count--;

    // return the removed node's data
    // this data was stored in `temp` prior to removing the node
    return temp;
}

/** Returns the number of elements the queue holds
 * Runtime: O(1)
 */
template <typename T>
int LLQueue<T>::size() const {
    // return the count of elements in the queue
    return this->count;
}

/** Returns `true` if the queue is empty; `false` otherwise
 * Runtime: O(1)
 */
template <typename T>
bool LLQueue<T>::isEmpty() const {
    // check if the element count in the queue is 0
    return this->count == 0;
}
