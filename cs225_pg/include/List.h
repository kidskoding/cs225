#pragma once

template <typename T>
struct ListNode {
    T data; // the current data in the linked list
    ListNode<T>* next; // a pointer to the next node in the linked list
    ListNode(const T& data) : data(data), next(nullptr) { }
};

template<typename T>
class List {
private:
    ListNode<T>* head; // a pointer to the head of the linked list

public:
    void insertAtFront(const T& data);
    ListNode<T>*& insert(const T& data, int index);
    ListNode<T>*& find(int index);
};