// BTree.hpp

#pragma once
#include "BTree.h"

/** Creates a node of a B-tree of order `order`, holding `keys` (in sorted order) and `children`
 * Runtime: O(m)
 */
template <typename K>
BTree<K>::BTreeNode::BTreeNode(unsigned order, std::initializer_list<K> keys, std::initializer_list<BTreeNode*> children)
    : keys_(keys), keys_ct_(keys.size()), children_(children) {
    // preallocate every slot, so a node never has to resize
    keys_.resize(order - 1);
    children_.resize(order, nullptr);
}

/** Returns whether the node has no children (its first child pointer is null)
 * Runtime: O(1)
 */
template <typename K>
bool BTree<K>::BTreeNode::isLeaf() const {
    // a node with any children has a child to the left of key 0
    return children_[0] == nullptr;
}

/** Fetches child `i`; this is where the seek to disk or another server would happen
 * Runtime: O(1) seek (a copy of the node, like reading it off disk)
 */
template <typename K>
typename BTree<K>::BTreeNode BTree<K>::BTreeNode::_fetchChild(unsigned i) const {
    return *children_[i];
}

/** Returns whether `key` is in the tree
 * Runtime: O(log_m n) seeks, plus O(m) work inside each node
 */
template <typename K>
bool BTree<K>::exists(const K& key) {
    if(root_ == nullptr) { return false; }
    return _exists(*root_, key);
}

/** Returns whether `key` is in the subtree rooted at `node`
 * Runtime: O(log_m n) seeks, plus O(m) work inside each node
 */
template <typename K>
bool BTree<K>::_exists(BTreeNode& node, const K& key) {
    unsigned i;
    // find the index of the key, or the first index with a larger key
    for(i = 0; i < node.keys_ct_ && key > node.keys_[i]; i++) { }

    // the key is in this node
    if(i < node.keys_ct_ && key == node.keys_[i]) {
        return true;
    }

    // a leaf has no children left to search, so the key isn't in the tree
    if(node.isLeaf()) {
        return false;
    } else {
        // the expensive part: a seek to fetch the next node from disk or another server
        BTreeNode nextChild = node._fetchChild(i);
        return _exists(nextChild, key);
    }
}
