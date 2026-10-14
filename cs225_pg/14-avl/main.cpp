// main.cpp

#include "AVL.hpp"

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

/** AVL trees: the rotations from inserting 10, 20, 30, 25, 28, and a remove that rotates
 * Runtime: O(n log n)
 */
int main() {
    std::cout << "\n== AVL Trees ==\n";

    AVL<int, int> avl;
    avl.insert(10, 100);
    avl.insert(20, 200);
    avl.insert(30, 300);
    std::cout << "insert 10, 20, 30 (L rotation about 10): height " << avl.height() << "\n";
    avl.insert(25, 250);
    avl.insert(28, 280);
    std::cout << "insert 25, 28 (LR rotation about 30): height " << avl.height() << "\n";
    printValues("keys", avl.keys());
    avl.remove(10);
    std::cout << "remove(10) (20 is now right heavy, L rotation): height " << avl.height() << "\n";
    printValues("keys", avl.keys());
    std::cout << "find(28) value: " << avl.find(28)->second << "\n";

    AVL<int, int> sorted;
    for(int key = 1; key <= 1000; key++) {
        sorted.insert(key, key);
    }
    std::cout << "insert 1 to 1000 in order: height " << sorted.height()
              << " (a plain BST would be 999)\n";
    return 0;
}
