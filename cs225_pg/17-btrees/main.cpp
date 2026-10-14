// main.cpp

#include "BTree.hpp"

#include <iostream>

/** B-trees: `_exists` searching the order 5 tree from the insertion example
 * Runtime: O(log_m n) seeks
 */
int main() {
    std::cout << "\n== BTrees ==\n";

    using Node = BTree<int>::BTreeNode;
    Node left(5, {1, 3});
    Node middle(5, {57, 101});
    Node right(5, {105, 109});
    Node root(5, {21, 102}, {&left, &middle, &right});
    BTree<int> tree(&root);

    std::cout << std::boolalpha;
    for(int key : {101, 21, 109, 100, 110}) {
        std::cout << "exists(" << key << "): " << tree.exists(key) << "\n";
    }
    std::cout << std::noboolalpha;
    return 0;
}
