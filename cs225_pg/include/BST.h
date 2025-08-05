// BST.h

#pragma once
#include <unordered_map>

template <class K, class V>
class BST {
public:
    using TreeIterator = typename std::unordered_map<K, V>::iterator;

    BST();
    void insert(K key, V value);
    void remove(const K& key);
    TreeIterator find(const K& key) const;
    TreeIterator begin();
    TreeIterator end();

private:
    struct TreeNode {
        TreeNode* left;
        TreeNode* right;
        K key;
        V value;
    };

    TreeNode* root;

    // a map that lets us use iterators for fast access without needing to traverse the tree
    std::unordered_map<K, V> node_map;

    TreeNode*& _find(TreeNode*& root, const K& key);
    void _insert(TreeNode*& root, const K& key, const V& value);
    void _swap(TreeNode* a, TreeNode* b);
    TreeNode*& _iop(TreeNode*& node);
    void _remove(TreeNode*& node, const K& key);
};
