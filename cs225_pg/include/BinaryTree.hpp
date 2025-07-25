#include "BinaryTree.h"
#include <iostream>
#include <queue>

template <typename T>
void BinaryTree<T>::preOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }

    std::cout << curr->data << " ";
    preOrderTraversal(curr->left);
    preOrderTraversal(curr->right);
}

template <typename T>
void BinaryTree<T>::inOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }
    
    inOrderTraversal(curr->left);
    std::cout << curr->data << " ";
    inOrderTraversal(curr->right);
}

template <typename T>
void BinaryTree<T>::postOrderTraversal(TreeNode* curr) {
    if(curr == nullptr) { return; }

    postOrderTraversal(curr->left);
    postOrderTraversal(curr->right);
    std::cout << curr->data << " ";
}

template <typename T>
void BinaryTree<T>::levelOrderTraversal() {
    std::queue<TreeNode*> q;
    q.push(root);

    while(!q.empty()) {
        TreeNode* n = q.front();
        q.pop();
        
        if(n != nullptr) {
            std::cout << n->data << " ";
            q.push(n->left);
            q.push(n->right);
        }
    }
}