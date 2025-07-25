// CircularQueue.h

#pragma once

template <typename T>
class CircularQueue {
public:
    CircularQueue(unsigned int capacity);
    ~CircularQueue();

    void enqueue(T e);
    T dequeue();
    bool isEmpty();
private:
    T* items;
    unsigned int capacity;
    unsigned int size;
    unsigned int front;
    unsigned int rear;
};