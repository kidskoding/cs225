// LinkedList.h

#pragma once

template <typename T>
struct ListNode {
    // the current data in the list 
    T data;
    
    // a pointer to the next node in the linked list
    ListNode<T>* next;

    // a copy constructor for the list
    ListNode(const T& data) : data(data), next(nullptr) { }
};

template<typename T>
class LinkedList {
private:
    // a pointer to the head of the linked list
    ListNode<T>* head;

public:
    void insertAtFront(const T& data);
    void insert(const T& data, int index);
    ListNode<T>*& find(int index);
    T& operator[](int index);
    T remove(int index);
};