#include "CircularQueue.h"
#include <stdexcept>

template <typename T>
CircularQueue<T>::CircularQueue(unsigned int capacity) : capacity(capacity), size(0), front(0), rear(0) { }

template <typename T>
CircularQueue<T>::~CircularQueue() { delete[] items; }

template <typename T>
void CircularQueue<T>::enqueue(T e) {
    if(size == capacity) {
        throw std::runtime_error("queue is full!");
    }

    items[rear] = e;
    rear = (rear + 1) % capacity;
    ++size;
}

template <typename T>
T CircularQueue<T>::dequeue() {
    if(size == 0) {
        throw std::runtime_error("Queue is empty");
    }
    
    T value = items[front];
    front = (front + 1) % capacity;
    --size;
    
    return value;
}

template <typename T>
bool CircularQueue<T>::isEmpty() {
    return size == 0;
}