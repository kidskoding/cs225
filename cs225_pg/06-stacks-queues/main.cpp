// main.cpp

#include "CircularQueue.hpp"
#include "LLQueue.hpp"

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

/** Queues: the array-based CircularQueue (wrapping around and doubling) and the linked list queue
 * Runtime: O(n)
 */
int main() {
    std::cout << "\n== Stacks and Queues ==\n";

    CircularQueue<int> q(4);
    q.enqueue(3);
    q.enqueue(4);
    std::cout << "enqueue 3, 4, then dequeue(): " << q.dequeue() << "\n";
    q.enqueue(5);
    q.enqueue(6);
    std::cout << "enqueue 5, 6, then dequeue(): " << q.dequeue() << "\n";
    // start = 2 and size = 2, so 7 wraps around to index 0 and 8 fills the array
    q.enqueue(7);
    q.enqueue(8);
    // the array is full, so enqueue(9) doubles it and copies 5, 6, 7, 8 back to index 0
    q.enqueue(9);
    std::vector<int> drained;
    while(!q.isEmpty()) {
        drained.push_back(q.dequeue());
    }
    printValues("enqueue 7, 8, 9 (wrap, then grow), then dequeue all", drained);

    LLQueue<int> llq;
    llq.enqueue(3);
    llq.enqueue(4);
    llq.enqueue(5);
    std::cout << "LLQueue: enqueue 3, 4, 5, then dequeue(): " << llq.dequeue()
              << ", size " << llq.size() << "\n";
    return 0;
}
