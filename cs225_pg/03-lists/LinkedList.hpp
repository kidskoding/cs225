// LinkedList.hpp

#pragma once
#include "LinkedList.h"

/** Inserts data at the front of a List
 * Runtime: O(1)
 */
template <typename T>
void LinkedList<T>::insertAtFront(const T& data) {
    // Dynamically allocate the data to the heap
    ListNode<T>* newNode = new ListNode<T>(data);

    // Reassign the next pointer to the head
    newNode->next = head;

    // Reassign the head pointer to the newly created node
    head = newNode;
}

/** Inserts data in the given index of a list
 * Runtime: O(n)
 */
template <typename T>
void LinkedList<T>::insert(const T& data, int index) {
    // Call `find` to find the `ListNode` at the given index
    ListNode<T>*& nodeAtIndex = find(index);

    // Dynamically allocate the data to the heap
    ListNode<T>* newNode = new ListNode<T>(data);

    // Reassign the next node of the newly created node to be the `ListNode` found at the given index
    newNode->next = nodeAtIndex;

    // Reassign the found `ListNode` at the given index's pointer to the newly created node from the given data
    nodeAtIndex = newNode;
}

/** Finds the `ListNode` at the given index!
 * Runtime: O(n)
 */
template <typename T>
ListNode<T>*& LinkedList<T>::find(int index) {
    // Return the head if the index is 0
    // We know that the first node in the list is always the head!
    if(index == 0 || head == nullptr) {
        return head;
    }

    // Create a copy pointer of the head to traverse through the list!
    ListNode<T>* curr = head;

    // Traverse through the list to find the node right before the given index
    // Stop early at the last node so `curr` never becomes null
    int x = 0;
    while(x < index - 1 && curr->next != nullptr) {
        curr = curr->next;
        x += 1;
    }

    // Return the next node in the list, since that matches the node at the given index
    return curr->next;
}

/** Returns the data by reference of the `ListNode` at the given index
 * Runtime: O(n)
 */
template <typename T>
T& LinkedList<T>::operator[](int index) {
    // Call `find` to find the `ListNode` at the given index
    ListNode<T>* loc = find(index);

    // Return the data that the `ListNode` at the given index holds
    return loc->data;
}

/** Removes a `ListNode` by index and returns its associated data!
 * Runtime: O(n)
 */
template <typename T>
T LinkedList<T>::remove(int index) {
    // Find the `ListNode` to be removed
    ListNode<T>*& toRemove = find(index);

    // Create a temporary `ListNode` containing what should be removed
    ListNode<T>* temp = toRemove;

    // Create a `val` variable to store temp's data
    T val = temp->data;

    // Reassign `toRemove` to the next node in the `ListNode`
    toRemove = toRemove->next;

    // Delete `temp` from memory since we no longer need it
    delete temp;
    return val;
}
