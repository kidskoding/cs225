// BST.hpp

#include "BST.h"

template <typename K, typename V>
typename BST<K, V>::TreeNode*& BST<K, V>::_find(TreeNode*& root, const K& key) {
    // if the root's pointer is null, return the root or
    // if the root's key equals the given key, return the root
    if(root == nullptr || root->key == key) { return root; }

    // if the root's key is greater than the given key, call find on the left subtree
    if(root->key > key) {
        return _find(root->left, key);
    }

    // if the root's key is less than the given key, call find on the right subtree
    return _find(root->right, key);
}

template <typename K, typename V>
typename BST<K, V>::TreeIterator BST<K, V>::find(const K& key) const {
    // use `node_map` to quickly find the value without traversing the tree
    return node_map.find(key);
}

template <typename K, typename V>
void BST<K, V>::_insert(TreeNode*& root, const K& key, const V& value) {
    // grab the reference/location to the pointer where `key` should be inserted
    TreeNode*& loc = _find(root, key);

    // assign `loc` to point to a new `TreeNode` with the given `key` and `value`
    loc = new TreeNode(key, value);
}

template <typename K, typename V>
void BST<K, V>::insert(K key, V value) {
    _insert(root, key, value);

    // also insert the key-value pair into the hashmap for fast lookup and iterator support
    node_map[key] = value;
}

template <typename K, typename V>
typename BST<K, V>::TreeNode*& BST<K, V>::_iop(TreeNode*& node) {
    // grab the left subtree of the root
    TreeNode*& curr = node->left;

    // iterate through each right child of the left subtree to find the rightmost node
	// return the rightmost node (since that always contains the greatest value)
    while(curr->right != nullptr) {
        curr = curr->right;
    }
    return curr;
}

template <typename K, typename V>
void BST<K, V>::_swap(TreeNode* a, TreeNode* b) {
    // swap the internal data of nodes `a` and `b`
    std::swap(a->key, b->key);
    std::swap(a->value, b->value);
}

template <typename K, typename V>
void BST<K, V>::_remove(TreeNode*& node, const K& key) {
    if(node != nullptr) { return; }

    if(key < node->key) {
        // descend down the left subtree because left subtree contains the smaller values
        _remove(node->left, key);
    } else if(key > node->key) {
        // descend down the right subtree because right subtree contains the larger values
        _remove(node->right, key);
    } else {
        // case 1: the leaf node case - free the node and set it to null
        if(node->left != nullptr && node->right != nullptr) {
            delete node;
            node = nullptr;
        } 
        
        // case 2: the one child node case (either left or right child)
        else if(node->left != nullptr) {
            // remove the node by connecting its parent directly to the node’s only child (the right child)
            TreeNode* tmp = node;
            node = node->right;
            delete tmp;
        }
        else if(node->right != nullptr) {
            // remove the node by connecting its parent directly to the node’s only child (the left child)
            TreeNode* tmp = node;
            node = node->left;
            delete tmp;
        }

        // case 3: the two child node case (both left and right child)
        // swap the removed node with the iop and recursively call the function on the left subtree
        else {
            K iop_key = node->key;
            TreeNode* iop = _iop(node);
            _swap(iop, node);

            // recursively call on the left subtree because the iop (the node to remove) is located there
            _remove(node->left, iop_key);
        }
    }
}

template <typename K, typename V>
void BST<K, V>::remove(const K& key) {
    _remove(root, key);

    // remove the key from the map
    node_map.erase(key);
}

template <typename K, typename V>
typename BST<K, V>::TreeIterator BST<K, V>::begin() {
    return node_map.begin();
}

template <typename K, typename V>
typename BST<K, V>::TreeIterator BST<K, V>::end() {
    return node_map.end();
}
