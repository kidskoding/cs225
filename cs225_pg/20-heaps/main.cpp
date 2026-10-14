// main.cpp

#include "../19-priority-queues/Heap.hpp"

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

/** buildHeap: heapifying down from the bottom up, then emptying the heap in sorted order
 * Runtime: O(n log n)
 */
int main() {
    std::cout << "\n== buildHeap ==\n";

    std::vector<int> values = {12, 15, 6, 9, 3, 14, 8, 1, 7, 10};
    printValues("array", values);
    Heap<int> heap(values);
    printValues("after buildHeap", heap.items());

    std::vector<int> sorted;
    while(!heap.isEmpty()) {
        sorted.push_back(heap.removeMin());
    }
    printValues("removeMin until empty", sorted);
    return 0;
}
