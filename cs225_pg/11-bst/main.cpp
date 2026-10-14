// main.cpp

#include "BST.hpp"

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

/** Inserts `keys` (each with the value key * 10) into a new BST, in order
 * Runtime: O(n h)
 */
BST<int, int> exampleBST(const std::vector<int>& keys) {
    BST<int, int> bst;
    for(int key : keys) {
        bst.insert(key, key * 10);
    }
    return bst;
}

/** Binary search trees: insert, find, and the three remove cases from the notes
 * Runtime: O(n h)
 */
int main() {
    std::cout << "\n== Binary Search Trees ==\n";

    BST<int, int> bst = exampleBST({15, 8, 25, 4, 12, 21, 30});
    printValues("keys (in-order)", bst.keys());
    std::cout << "find(21) value: " << bst.find(21)->second << "\n";
    bst.insert(23, 230);
    printValues("insert(23)", bst.keys());
    bst.remove(4);
    printValues("remove(4) (leaf)", bst.keys());

    BST<int, int> oneChild = exampleBST({15, 8, 25, 4, 21, 30, 2, 6});
    oneChild.remove(8);
    printValues("remove(8) (one child) from 15, (8, (4, 2, 6)), (25, 21, 30)", oneChild.keys());

    BST<int, int> twoChildren = exampleBST({15, 8, 25, 4, 12, 10});
    twoChildren.remove(15);
    printValues("remove(15) (two children, IOP 12) from 15, (8, 4, (12, 10)), 25", twoChildren.keys());
    return 0;
}
