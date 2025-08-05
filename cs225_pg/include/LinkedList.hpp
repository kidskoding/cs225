// LinkedList.hpp

#include "LinkedList.h"

template <typename T>
void LinkedList<T>::insertAtFront(const T& data) {
	// dynamically allocate the data to the heap
    ListNode<T>* newNode = new ListNode<T>(data);

	// reassign the next pointer to the head
    newNode->next = head;

	// reassign the head pointer to the newly created node
    head = newNode;
}

template <typename T>
void LinkedList<T>::insert(const T& data, int index) {
	// call `find` to find the `ListNode` at the given index
	ListNode<T>*& nodeAtIndex = find(index);

	// dynamically allocate the data to the heap
	ListNode<T>* newNode = new ListNode<T>(data);

	// reassign the next node of the newly created node to be the `ListNode` found at the given index
	newNode->next = nodeAtIndex;

	// reassign the found `ListNode` at the given index's pointer to the newly created node from the given data
	nodeAtIndex = newNode;
}

template <typename T>
ListNode<T>*& LinkedList<T>::find(int index) {
	// return the head if the index is 0
	// we know that the first node in the list is always the head!
	if(index == 0) { 
        return head; 
    }

	// create a copy pointer of the head to traverse through the list!
	ListNode<T>* curr = head;
	
	// traverse through the list to find the node right before the given index
	int x = 0;
	while(curr != nullptr && x < index - 1) {
		curr = curr->next;
        x += 1;
	}

	// return the next node in the list, since that matches the node at the given index
	return curr->next;
}

template <typename T>
T& LinkedList<T>::operator[](int index) {
	// call `find` to find the `ListNode` at the given index	
	ListNode<T>*& loc = find(index);

	// return the data that the `ListNode` at the given index holds
	return loc->data;
}

template <typename T>
T LinkedList<T>::remove(int index) {
	// find the `ListNode` to be removed
	ListNode<T>*& toRemove = find(index);

	// create a temporary `ListNode` containing what should be removed
	ListNode<T>* temp = toRemove;

	// create a `val` variable to store temp's data
	T val = temp->data;

	// reassign `toRemove` to the next node in the `ListNode`
	toRemove = toRemove->next;

	// delete `temp` from memory since we no longer need it
	delete temp;
	return val;
}