#include "List.hpp"
#include <iostream>

int main(int argc, char** argv) {
    List<int> list;
    
    list.insertAtFront(10);
    list.insertAtFront(20);
    list.insert(1, 30);

    ListNode<int>* node = list.find(1);
    if (node != nullptr) {
        std::cout << "Node at index 1: " << node->data << '\n';
    } else {
        std::cout << "Node at index 1 not found.\n";
    }
}
