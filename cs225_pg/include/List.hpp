#include "List.h"

/** Inserts data at the front of a List
  * Runtime: O(1)
 */
template <typename T>
void List<T>::insertAtFront(const T& data) {
	// Dynamically allocate the data to the heap
    ListNode<T>* newNode = new ListNode(data);

	// Reassign the next pointer to the head
    newNode->next = head;

	// Reassign the head pointer to the newly created node
    head = newNode;
}

/** Inserts data in the given index of a list
 *  
 */
template <typename T>
ListNode<T>*& List<T>::insert(const T& data, int index) {
    
}

/** Finds the ListNode at the given index!
 *  Runtime: O(n)
 */
template <typename T>
ListNode<T>*& List<T>::find(int index) {
	if(index == 0) { 
        return head; 
    }

	ListNode<T>* curr = head;
	int x = 0;
	while(x < index - 1) {
		curr = curr->next;
        x += 1;
	}
	return curr->next;
}