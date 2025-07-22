#include "BinaryTree.h"
#include <iostream>

template <typename T>
void BinaryTree<T>::preOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }

    std::cout << curr->data << std::endl;
    preOrderTraversal(curr->left);
    preOrderTraversal(curr->right);
}

template <typename T>
void BinaryTree<T>::inOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }
    
    inOrderTraversal(curr->left);
    std::cout << curr->data << std::endl;
    inOrderTraversal(curr->right);
}

template <typename T>
void BinaryTree<T>::postOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }

    postOrderTraversal(curr->left);
    postOrderTraversal(curr->right);
    std::cout << curr->data << std::endl;
}

