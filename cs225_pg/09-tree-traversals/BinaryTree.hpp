// BinaryTree.hpp

#pragma once
#include "BinaryTree.h"
#include <iostream>
#include <queue>

/** Builds a complete tree from its values listed level by level, left to right
 * (the node at index i has children at 2i + 1 and 2i + 2)
 * Runtime: O(n)
 */
template <typename T>
BinaryTree<T>::BinaryTree(const std::vector<T>& levelOrder) : root(nullptr) {
    if(levelOrder.empty()) { return; }

    // make every node first, then link each one to its children by index
    std::vector<TreeNode*> nodes;
    for(const T& value : levelOrder) {
        nodes.push_back(new TreeNode(value));
    }
    for(size_t i = 0; i < nodes.size(); i++) {
        if(2 * i + 1 < nodes.size()) { nodes[i]->left = nodes[2 * i + 1]; }
        if(2 * i + 2 < nodes.size()) { nodes[i]->right = nodes[2 * i + 2]; }
    }
    root = nodes[0];
}

/** Prints every node in pre-order (node, left subtree, right subtree)
 * Runtime: O(n)
 */
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

/** Prints every node in in-order (left subtree, node, right subtree)
 * Runtime: O(n)
 */
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

/** Prints every node in post-order (left subtree, right subtree, node)
 * Runtime: O(n)
 */
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

/** Prints every node level by level, from left to right
 * Runtime: O(n)
 */
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
