#include "List.hpp"
#include <iostream>

int main(int argc, char** argv) {
    List<int> list;
    list.insertAtFront(10);
    list.insertAtFront(20);
    list.insert(30, 1);
    
    std::cout << list[1] << std::endl;
    return 0;
}