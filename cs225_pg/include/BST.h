// BST.h

#pragma once
#include <unordered_map>

template <class K, class V>
class BST {
public:
    using TreeIterator = typename std::unordered_map<K, V>::iterator;

    BST();
    void insert(const K key, V value);
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

    TreeNode*& _find(TreeNode*& root, const K& key);
    void _insert(TreeNode*& root, const K& key, const V& value);
};