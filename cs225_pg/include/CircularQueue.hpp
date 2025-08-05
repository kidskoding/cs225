#include "CircularQueue.h"
#include <stdexcept>

template <typename T>
CircularQueue<T>::CircularQueue(unsigned int capacity) : capacity(capacity), size(0), front(0), rear(0) { }

template <typename T>
CircularQueue<T>::~CircularQueue() { delete[] items; }

template <typename T>
void CircularQueue<T>::enqueue(T e) {
    // throw a runtime error if the queue is full
    if(size == capacity) {
        throw std::runtime_error("queue is full!");
    }

    // Add an element to the end of the queue
    items[rear] = e;

    // reassign the front index of the queue
    rear = (rear + 1) % capacity;

    // increment the queue size
    ++size;
}

template <typename T>
T CircularQueue<T>::dequeue() {
    // throw a runtime error if the queue is empty
    if(size == 0) {
        throw std::runtime_error("Queue is empty");
    }
    
    // get the value from the front of the queue
    T value = items[front];

    // reassign the front index of the queue
    front = (front + 1) % capacity;

    // decrement the queue size, since we removed an element
    --size;
    
    // return the value of the element dequeued
    return value;
}

template <typename T>
bool CircularQueue<T>::isEmpty() {
    // if the size is 0, the queue is empty
    return size == 0;
}
