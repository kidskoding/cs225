// CircularQueue.h

#pragma once

template <typename T>
class CircularQueue {
public:
    void enqueue(T e);
    T dequeue();
    bool isEmpty();
private:
    T* items;
    unsigned int capacity;
    unsigned int size;
};