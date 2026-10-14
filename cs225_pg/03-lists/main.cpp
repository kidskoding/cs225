// main.cpp

#include "LinkedList.hpp"

#include <iostream>
#include <string>

/** Prints a linked list front to back, following `find` until it reaches the null end
 * Runtime: O(n^2) (every `find` walks from the head)
 */
template <typename T>
void printList(const std::string& label, LinkedList<T>& list) {
    std::cout << label << ":";
    for(int i = 0; list.find(i) != nullptr; i++) {
        std::cout << " " << list[i];
    }
    std::cout << "\n";
}

/** Builds the list 10 -> 20 -> 30 from the notes
 * Runtime: O(1)
 */
LinkedList<int> exampleList() {
    LinkedList<int> list;
    list.insertAtFront(30);
    list.insertAtFront(20);
    list.insertAtFront(10);
    return list;
}

/** Linked lists: insertAtFront, insert, find, operator[], and remove
 * Runtime: O(n^2)
 */
int main() {
    std::cout << "\n== Linked Lists ==\n";

    LinkedList<int> list = exampleList();
    printList("list", list);
    list.insertAtFront(3);
    printList("insertAtFront(3)", list);

    LinkedList<int> other = exampleList();
    std::cout << "find(2) on 10 20 30 points to: " << other.find(2)->data << "\n";
    other.insert(3, 1);
    printList("insert(3, 1) on 10 20 30", other);
    std::cout << "operator[](2): " << other[2] << "\n";
    std::cout << "remove(1) returns: " << other.remove(1) << "\n";
    printList("after remove(1)", other);
    return 0;
}
