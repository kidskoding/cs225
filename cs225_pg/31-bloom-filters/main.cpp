// main.cpp

#include "BloomFilter.h"

#include <cstddef>
#include <cstdint>
#include <iostream>
#include <vector>

/** Bloom filters: the one-hash filter, the shared k = 3 filter, union, and single-bit operations
 * Runtime: O(m)
 */
int main() {
    std::cout << "\n== Bloom Filters ==\n";

    BloomFilter mod7(7, {[](int x) { return size_t(x % 7); }});
    for(int key : {16, 8, 4, 13, 29, 11, 22}) {
        mod7.insert(key);
    }
    std::cout << "h(x) = x mod 7 after 16, 8, 4, 13, 29, 11, 22: " << mod7.bits() << "\n";
    std::cout << std::boolalpha;
    for(int key : {16, 20, 3}) {
        std::cout << "  find(" << key << "): " << mod7.contains(key) << "\n";
    }

    std::vector<BloomFilter::HashFunction> three = {
        [](int x) { return size_t(x % 10); },
        [](int x) { return size_t(2 * x % 10); },
        [](int x) { return size_t((3 * x + 5) % 10); }
    };
    BloomFilter shared(10, three);
    for(int key : {6, 8, 4}) {
        shared.insert(key);
        std::cout << "k = 3, insert " << key << ": " << shared.bits() << "\n";
    }
    for(int key : {6, 1, 16, 9}) {
        std::cout << "  find(" << key << "): " << shared.contains(key) << "\n";
    }

    BloomFilter s1(10, three);
    BloomFilter s2(10, three);
    s1.insert(6);
    s1.insert(4);
    s2.insert(8);
    s2.insert(4);
    std::cout << "S1 = {6, 4}: " << s1.bits() << ", S2 = {8, 4}: " << s2.bits() << "\n";
    s1.unionWith(s2);
    std::cout << "S1 or S2: " << s1.bits() << "\n";

    uint64_t a = 0b10110;
    std::cout << "isSet(10110, 2): " << isSet(a, 2) << ", setBit(10110, 0) = " << setBit(a, 0) << "\n";
    std::cout << std::noboolalpha;
    return 0;
}
