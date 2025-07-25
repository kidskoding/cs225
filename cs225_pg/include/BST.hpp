// BST.hpp

#include "BST.h"

template <class K, class V>
typename BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {
    if(root == nullptr) { return root; }
    if(root->key == key) { return key; }

    if(root->key > key) {
        return _find(root->left, key);
    }

    return _find(root->right, key);
}

template <class K, class V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
    _find(key) = new TreeNode(key, value);
}

