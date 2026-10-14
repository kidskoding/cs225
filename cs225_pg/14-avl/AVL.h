#pragma once

#include <unordered_map>

template <class K, class V>
class AVL {
public:
    using TreeIterator = typename std::unordered_map<K, V>::iterator;

    AVL();

    /** Inserts a node into the AVL tree */
    void insert(K key, V value);

    // find and remove are identical to regular BST! (will not include. refer to BST implementation)
private:
    struct TreeNode {
        K key;
        V value;

        // have each `TreeNode` store the height in order to self balance
        unsigned int height;

        TreeNode* left;
        TreeNode* right;
    };

    TreeNode* root;
    std::unordered_map<K, V> node_map;

    void _insert(const K& key, const V& value, TreeNode*& curr);
    int height(TreeNode* node);
    void _ensureBalance(TreeNode*& curr);
    void _updateHeight(TreeNode* curr);

    void _rotateLeft(TreeNode*& root);
    void _rotateRight(TreeNode*& root);
    void _rotateLeftRight(TreeNode*& root);
    void _rotateRightLeft(TreeNode*& root);
};
