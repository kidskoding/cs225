#pragma once

template<typename T>
class List {
public:
    void insertAtFront(const T& data);

private:
    struct ListNode {
        T data; // the current data in the linked list
        ListNode* next; // a pointer to the next node in the linked list
        ListNode(const T& data) : data(data), next(nullptr) { }
    };

    ListNode* head; // a pointer to the head of the linked list
}