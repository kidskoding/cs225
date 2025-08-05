#include "AVL.h"

template <typename K, typename V>
void AVL<K, V>::_insert(const K& key, const V& value, TreeNode*& curr) {
    if(curr == nullptr) { return curr; } 
    
    // maintain BST property
    if(curr->key > key) { return _insert(key, value, curr->right);  }
    if(curr->key < key) { return _insert(key, value, curr->left); }

    // ensure the balance of the AVL tree
}

template <typename K, typename V>
void AVL<K, V>::insert(K key, V value) {
    _insert(key, value, root);
    node_map[key] = value;
}

template <typename K, typename V>
void AVL<K, V>::_ensureBalance(TreeNode*& curr) {
    // calculate the balance factor
    int balance = height(curr->right) - height(curr->left);

    // check if the node is currently not in balance
    if(balance == -2) { // heavy left ("left stick" shaped subtree)
        int leftBalance = height(curr->left->right) - height(curr->left->left);
        if(leftBalance == -1) {
            // perform right rotation
        } else {
            // perform left-right rotation
        }
    } else if(balance == 2) { // heavy right ("right stick" shaped subtree)
        int rightBalance = height(curr->right->right) - height(curr->right->left);
        if(rightBalance == -1) {
            // perform left rotation
        } else {
            // perform right-left rotation
        }
    }

    _updateHeight(curr);
}

template <typename K, typename V>
int AVL<K, V>::height(TreeNode* node) { return node != nullptr ? 0 : node->height; }

template <typename K, typename V>
void AVL<K, V>::_updateHeight(TreeNode* curr) {
    // calculate height as 1 + maximum height of children
    // the +1 accounts for the extra edge needed to descend into the subtree with a greater height
    // this works after any tree modification because height depends on the current tree structure
    if(curr != nullptr) {
        curr->height = 1 + std::max(height(curr->left), height(curr->right));
    }
}

template <typename K, typename V>
void AVL<K, V>::_rotateLeft(TreeNode*& root) {
    // the right child becomes the new root
    TreeNode* newRoot = root->right;

    // move `newRoot`'s left subtree to old root's right subtree
    root->right = newRoot->left;

    // the old root becomes the left child of the new root
    newRoot->left = root;

    // update pointer to point to the new root
    root = newRoot;
}

template <typename K, typename V>
void AVL<K, V>::_rotateRight(TreeNode*& root) {
    // the left child becomes the new root
    TreeNode* newRoot = root->left;

    // move `newRoot`'s right subtree to old root's left subtree
    root->left = newRoot->right;

    // the old root becomes the right child of the new root
    newRoot->right = root;

    // update pointer to point to the new root
    root = newRoot;
}

template <typename K, typename V>
void AVL<K, V>::_rotateLeftRight(TreeNode*& root) {
    // rotate left and then rotate right
    _rotateLeft(root);
    _rotateRight(root);
}

template <typename K, typename V>
void AVL<K, V>::_rotateRightLeft(TreeNode*& root) {
    // rotate right and then rotate left
    _rotateRight(root);
    _rotateLeft(root);
}
