// main.cpp

#include "DisjointSets.h"

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

/** Disjoint sets: plain uptrees, union by size and by height, and path compression
 * Runtime: O(n)
 */
int main() {
    std::cout << "\n== Disjoint Sets ==\n";

    // {0, 1, 4}, {2, 7}, {3, 5, 6} as plain uptrees (roots store -1)
    DisjointSets sets;
    sets.addElements(8);
    sets._union(0, 1);
    sets._union(1, 4);
    sets._union(7, 2);
    sets._union(3, 5);
    sets._union(6, 5);
    printValues("uptrees", sets.data());
    std::cout << "find(7): " << sets.find(7) << "\n";
    sets._union(4, 5);
    printValues("union(4, 5)", sets.data());
    std::cout << "find(0): " << sets.find(0) << "\n";
    printValues("after find(0) compresses 0 and 1", sets.data());

    // the tall 4 node set rooted at 4 and the bushy 8 node set rooted at 7
    std::vector<int> bySize = {4, 8, 7, 2, -4, 7, 2, -8, 0, 5, 5, 7};
    DisjointSets sizeSets(bySize);
    sizeSets.unionBySize(4, 7);
    std::cout << "unionBySize(4, 7): index 4 stores " << sizeSets.data()[4]
              << ", index 7 stores " << sizeSets.data()[7] << "\n";

    std::vector<int> byHeight = bySize;
    byHeight[4] = -4; // height 3
    byHeight[7] = -3; // height 2
    DisjointSets heightSets(byHeight);
    heightSets.unionByHeight(4, 7);
    std::cout << "unionByHeight(4, 7): index 7 stores " << heightSets.data()[7]
              << ", index 4 stores " << heightSets.data()[4] << "\n";

    DisjointSets chain;
    chain.addElements(11);
    chain._union(6, 4);
    chain._union(4, 2);
    chain._union(2, 7);
    chain._union(7, 9);
    chain._union(9, 10);
    std::cout << "find(6) on the path 6, 4, 2, 7, 9, 10: " << chain.find(6) << "\n";
    printValues("after path compression", chain.data());
    return 0;
}
