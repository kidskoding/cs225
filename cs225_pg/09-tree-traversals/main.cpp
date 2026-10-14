// main.cpp

#include "BinaryTree.hpp"

#include <iostream>

/** Binary trees: the four traversals on the tree 4, (2, 1, 3), (6, 5, 7)
 * Runtime: O(n)
 */
int main() {
    std::cout << "\n== Binary Trees and Traversals ==\n";

    BinaryTree<int> tree({4, 2, 6, 1, 3, 5, 7});
    std::cout << "pre-order: ";
    tree.preOrderTraversal();
    std::cout << "\nin-order: ";
    tree.inOrderTraversal();
    std::cout << "\npost-order: ";
    tree.postOrderTraversal();
    std::cout << "\nlevel-order: ";
    tree.levelOrderTraversal();
    std::cout << "\n";
    return 0;
}
