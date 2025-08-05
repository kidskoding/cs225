#include "BinaryTree.h"
#include <iostream>
#include <queue>

template <typename T>
void BinaryTree<T>::preOrderTraversal(TreeNode* curr) {
    // If the current node is a null pointer (`nullptr`), halt the recursion
    if(curr == nullptr) { return; }

    // Visit the current `TreeNode`
    std::cout << curr->data << " ";

    // Repeat the process for the left subtree
    preOrderTraversal(curr->left);

    // Repeat the process for the right subtree
    preOrderTraversal(curr->right);
}

template <typename T>
void BinaryTree<T>::inOrderTraversal(TreeNode* curr) {
    // If the current node is a null pointer (`nullptr`), halt the recursion
    if(curr == nullptr) { return; }

    // Repeat the process for the left subtree
    inOrderTraversal(curr->left);

    // Visit the current `TreeNode`    
    std::cout << curr->data << " ";

    // Repeat the process for the right subtree
    inOrderTraversal(curr->right);
}

template <typename T>
void BinaryTree<T>::postOrderTraversal(TreeNode* curr) {
    // If the current node is a null pointer (`nullptr`), halt the recursion
    if(curr == nullptr) { return; }

    // Repeat the process for the left subtree
    postOrderTraversal(curr->left);

    // Repeat the process for the right subtree
    postOrderTraversal(curr->right);

    // Visit the current `TreeNode`
    std::cout << curr->data << " ";
}

template <typename T>
void BinaryTree<T>::levelOrderTraversal() {
    // Create a queue to store `TreeNode` pointers at every level
    std::queue<TreeNode*> q;

    // Add the root `TreeNode`, `root` to the queue
    q.push(root);

    while(!q.empty()) {
        // Get the `TreeNode` at the front of the queue and remove it
        TreeNode* n = q.front();
        q.pop();
        
        // Check if the front `TreeNode` is not null
        if(n != nullptr) {
            // visit the node
            std::cout << n->data << " ";

            // add the node's left and right children to the queue
            q.push(n->left);
            q.push(n->right);
        }
    }
}
