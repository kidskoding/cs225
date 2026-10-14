// main.cpp

#include "ChainedTable.h"
#include "Point.h"
#include "ProbingTable.h"

#include <cstddef>
#include <iostream>
#include <string>
#include <unordered_set>
#include <vector>

/** Prints every slot of a closed hashing table ("_" is empty, "X" is a tombstone)
 * Runtime: O(m)
 */
void printSlots(const std::string& label, const ProbingTable& table) {
    std::cout << label << ":";
    for(const Slot& slot : table.slots()) {
        if(slot.state == State::Full) {
            std::cout << " " << slot.key;
        } else {
            std::cout << (slot.state == State::Empty ? " _" : " X");
        }
    }
    std::cout << "\n";
}

/** Hashing: separate chaining, linear probing with tombstones and rehashing, double hashing,
 * and hashing a custom type
 * Runtime: O(n)
 */
int main() {
    std::cout << "\n== Hashing ==\n";

    const std::vector<int> keys = {16, 8, 4, 13, 29, 11, 22};

    ChainedTable chained;
    for(int key : keys) {
        chained.insert(key, "v" + std::to_string(key));
    }
    const auto& buckets = chained.buckets();
    for(size_t i = 0; i < buckets.size(); i++) {
        std::cout << "table[" << i << "]:";
        for(const auto& entry : buckets[i]) {
            std::cout << " " << entry.first;
        }
        std::cout << "\n";
    }
    std::cout << "find(8): " << *chained.find(8) << ", find(15) is nullptr: " << std::boolalpha
              << (chained.find(15) == nullptr) << std::noboolalpha << "\n";
    chained.remove(29);
    std::cout << "remove(29), table[1]:";
    for(const auto& entry : chained.buckets()[1]) {
        std::cout << " " << entry.first;
    }
    std::cout << "\n";

    // a max load of 1 lets all seven keys fit in seven slots, like the example
    ProbingTable linear(7, 1.0);
    for(int key : keys) {
        linear.insert(key, "v" + std::to_string(key));
        if(key == 29) {
            printSlots("linear probing after 16, 8, 4, 13, 29", linear);
            std::cout << "find(22) is nullptr: " << std::boolalpha << (linear.find(22) == nullptr)
                      << std::noboolalpha << "\n";
        }
    }
    printSlots("linear probing, all seven", linear);

    ProbingTable rehashed = linear;
    rehashed.resize();
    printSlots("resize() to 14 slots", rehashed);

    linear.remove(16);
    printSlots("remove(16)", linear);
    std::cout << "find(29) through the tombstone: " << *linear.find(29) << "\n";

    DoubleHashTable doubled(7, 1.0);
    for(int key : keys) {
        doubled.insert(key, "v" + std::to_string(key));
    }
    printSlots("double hashing, all seven", doubled);

    std::unordered_set<Point> points = {{1, 2}, {2, 1}, {1, 2}};
    std::cout << "unordered_set<Point> of (1, 2), (2, 1), (1, 2) has size " << points.size() << "\n";
    return 0;
}
