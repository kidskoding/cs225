// AVL.hpp

#pragma once
#include "AVL.h"
#include <algorithm>
#include <utility>

/** Inserts a node and rebalances every node on the way back up
 * Runtime: O(h) = O(log n)
 */
template <typename K, typename V>
void AVL<K, V>::_insert(const K& key, const V& value, TreeNode*& curr) {
    // found the empty spot where the new node belongs
    if(curr == nullptr) {
        curr = new TreeNode(key, value);
        return;
    }

    // maintain BST property
    if(curr->key > key) {
        _insert(key, value, curr->left);
    } else if(curr->key < key) {
        _insert(key, value, curr->right);
    }

    // ensure the balance of the AVL tree (this also updates the height of `curr`)
    _ensureBalance(curr);
}

/** Inserts a key-value pair into the AVL tree
 * Runtime: O(h) = O(log n)
 */
template <typename K, typename V>
void AVL<K, V>::insert(K key, V value) {
    _insert(key, value, root);
    node_map[key] = value;
}

/** Removes the node with `key` like a BST, then rebalances every node on the way back up
 * Runtime: O(h) = O(log n)
 */
template <typename K, typename V>
void AVL<K, V>::_remove(TreeNode*& node, const K& key) {
    if(node == nullptr) { return; }

    if(key < node->key) {
        _remove(node->left, key);
    } else if(key > node->key) {
        _remove(node->right, key);
    } else if(node->left == nullptr && node->right == nullptr) {
        // leaf: just free it, there is nothing below it left to balance
        delete node;
        node = nullptr;
        return;
    } else if(node->left == nullptr || node->right == nullptr) {
        // one child: connect the parent straight to that child, whose subtree is already balanced
        TreeNode* tmp = node;
        node = node->left != nullptr ? node->left : node->right;
        delete tmp;
        return;
    } else {
        // two children: swap with the iop, which now sits at the bottom of the left subtree
        K iop_key = node->key;
        TreeNode* iop = _iop(node);
        std::swap(iop->key, node->key);
        std::swap(iop->value, node->value);
        _remove(node->left, iop_key);
    }

    // unlike insert, a remove can unbalance every ancestor, so check each one on the way up
    _ensureBalance(node);
}

/** Removes the node with `key`, rebalancing every ancestor on the way back up
 * Runtime: O(h) = O(log n)
 */
template <typename K, typename V>
void AVL<K, V>::remove(const K& key) {
    _remove(root, key);
    node_map.erase(key);
}

/** Returns the pointer to the in-order predecessor of `root`
 * Runtime: O(h)
 */
template <typename K, typename V>
typename AVL<K, V>::TreeNode*& AVL<K, V>::_iop(TreeNode*& root) {
    // a pointer to the pointer, so moving `curr` never overwrites a link in the tree
    TreeNode** curr = &root->left;
    while((*curr)->right != nullptr) {
        curr = &(*curr)->right;
    }
    return *curr;
}

/** Returns an iterator to the pair with `key` (looked up in `node_map`, like the BST)
 * Runtime: expected O(1)
 */
template <typename K, typename V>
typename AVL<K, V>::TreeIterator AVL<K, V>::find(const K& key) {
    return node_map.find(key);
}

/** Returns an iterator to the first key-value pair
 * Runtime: O(1)
 */
template <typename K, typename V>
typename AVL<K, V>::TreeIterator AVL<K, V>::begin() {
    return node_map.begin();
}

/** Returns an iterator one past the last key-value pair
 * Runtime: O(1)
 */
template <typename K, typename V>
typename AVL<K, V>::TreeIterator AVL<K, V>::end() {
    return node_map.end();
}

/** Rotates the subtree at `curr` if it is out of balance
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_ensureBalance(TreeNode*& curr) {
    // calculate the balance factor
    int balance = height(curr->right) - height(curr->left);

    // check if the node is currently not in balance
    if(balance == -2) {
        int leftBalance = height(curr->left->right) - height(curr->left->left);
        if(leftBalance <= 0) { // heavy left ("left stick" shaped subtree)
            _rotateRight(curr);
        } else { // "left elbow" shaped subtree
            _rotateLeftRight(curr);
        }
    } else if(balance == 2) {
        int rightBalance = height(curr->right->right) - height(curr->right->left);
        if(rightBalance >= 0) { // heavy right ("right stick" shaped subtree)
            _rotateLeft(curr);
        } else { // "right elbow" shaped subtree
            _rotateRightLeft(curr);
        }
    }

    // update the height of `curr`, which is the root of this subtree after any rotation
    _updateHeight(curr);
}

/** Returns the height of a node, or -1 for a null node
 * Runtime: O(1)
 */
template <typename K, typename V>
int AVL<K, V>::height(TreeNode* node) const {
    return node != nullptr ? node->height : -1;
}

/** Returns the height of the whole tree (-1 if it is empty)
 * Runtime: O(1)
 */
template <typename K, typename V>
int AVL<K, V>::height() const {
    return height(root);
}

/** Recomputes the height of `curr` from its children
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_updateHeight(TreeNode* curr) {
    // calculate height as 1 + maximum height of children
    // the +1 accounts for the extra edge needed to descend into the subtree with a greater height
    // this works after any tree modification because height depends on the current tree structure
    if(curr != nullptr) {
        curr->height = 1 + std::max(height(curr->left), height(curr->right));
    }
}

/** Rotates the subtree at `root` to the left
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateLeft(TreeNode*& root) {
    // the right child becomes the new root
    TreeNode* newRoot = root->right;

    // move `newRoot`'s left subtree to old root's right subtree
    root->right = newRoot->left;

    // the old root becomes the left child of the new root
    newRoot->left = root;

    // the old root is now below the new root, so update its height first
    _updateHeight(root);
    _updateHeight(newRoot);

    // update pointer to point to the new root
    root = newRoot;
}

/** Rotates the subtree at `root` to the right
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateRight(TreeNode*& root) {
    // the left child becomes the new root
    TreeNode* newRoot = root->left;

    // move `newRoot`'s right subtree to old root's left subtree
    root->left = newRoot->right;

    // the old root becomes the right child of the new root
    newRoot->right = root;

    // the old root is now below the new root, so update its height first
    _updateHeight(root);
    _updateHeight(newRoot);

    // update pointer to point to the new root
    root = newRoot;
}

/** Rotates left about the left child, then right about `root`
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateLeftRight(TreeNode*& root) {
    // rotate left about the left child and then rotate right about the root
    _rotateLeft(root->left);
    _rotateRight(root);
}

/** Rotates right about the right child, then left about `root`
 * Runtime: O(1)
 */
template <typename K, typename V>
void AVL<K, V>::_rotateRightLeft(TreeNode*& root) {
    // rotate right about the right child and then rotate left about the root
    _rotateRight(root->right);
    _rotateLeft(root);
}

/** Returns every key in the tree in sorted order (an in-order traversal)
 * Runtime: O(n)
 */
template <typename K, typename V>
std::vector<K> AVL<K, V>::keys() const {
    std::vector<K> out;
    _keys(root, out);
    return out;
}

/** Appends the keys of the subtree rooted at `node` to `out`, in order
 * Runtime: O(n)
 */
template <typename K, typename V>
void AVL<K, V>::_keys(TreeNode* node, std::vector<K>& out) const {
    if(node == nullptr) { return; }
    _keys(node->left, out);
    out.push_back(node->key);
    _keys(node->right, out);
}
