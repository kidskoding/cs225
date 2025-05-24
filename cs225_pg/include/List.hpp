#include "List.h"

/** Inserts data at the front of a List
  * Runtime: O(1)
 */
template <typename T>
void List<T>::insertAtFront(const T& data) {
	// Dynamically allocate the data to the heap
    ListNode* newNode = new ListNode(data);

	// Reassign the next pointer to the head
    temp->next = head;

	// Reassign the head pointer to the newly created node
    head = newNode;
}