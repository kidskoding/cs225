// LinkedList.h

#pragma once

template <typename T>
struct ListNode {
    // the current data in the list 
    T data;
    
    // a pointer to the next node in the linked list
    ListNode* next;

    // a copy constructor for the list
    ListNode(const T& data) : data(data), next(nullptr) { }
};

template <typename T>
class LinkedList {
private:
    // a pointer to the head (front) of the linked list
    ListNode<T>* head;

public:
	/** Inserts data at the front of a List
	* Runtime: O(1)
	*/
    void insertAtFront(const T& data);

	/** Inserts data in the given index of a list
	*  Runtime: O(n)
	*/
    void insert(const T& data, int index);
    
	/** Finds the `ListNode` at the given index!
	*  Runtime: O(n)
	*/
	ListNode<T>*& find(int index);
    
	/** Returns the data by reference of the `ListNode` at the given index 
	*	Runtime: O(n)
	*/
	T& operator[](int index);

	/** Removes a `ListNode` by index and returns its associated data! 
	* 	Runtime: O(n)
	*/
    T remove(int index);
};