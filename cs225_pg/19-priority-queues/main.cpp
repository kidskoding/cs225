// main.cpp

#include "Heap.hpp"

#include <iostream>
#include <string>
#include <vector>

/** Prints `label`, then every value in `values` separated by spaces
 * Runtime: O(n)
 */
template <typename T>
void printValues(const std::string& label, const std::vector<T>& values) {
    std::cout << label << ":";
    for(const T& value : values) {
        std::cout << " " << value;
    }
    std::cout << "\n";
}

/** Priority queues and heaps: the ADT example, then insert and removeMin on the example heap
 * Runtime: O(n log n)
 */
int main() {
    std::cout << "\n== Priority Queues and Heaps ==\n";

    Heap<int> pq;
    for(int x : {12, 7, 225, -57}) {
        pq.insert(x);
    }
    std::vector<int> removed;
    for(int i = 0; i < 3; i++) {
        removed.push_back(pq.removeMin());
    }
    pq.insert(42);
    pq.insert(21);
    while(!pq.isEmpty()) {
        removed.push_back(pq.removeMin());
    }
    printValues("insert 12, 7, 225, -57; remove x3; insert 42, 21; remove all", removed);

    std::vector<int> example = {4, 5, 6, 15, 9, 7, 20, 16, 25, 14, 12, 11};
    Heap<int> heap(example);
    printValues("heap array", heap.items());
    heap.insert(21);
    heap.insert(3);
    printValues("insert 21, then 3", heap.items());

    Heap<int> other(example);
    int min = other.removeMin();
    printValues("removeMin() returns " + std::to_string(min) + ", leaving", other.items());
    return 0;
}
