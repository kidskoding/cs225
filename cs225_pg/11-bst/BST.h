// BST.h

#pragma once
#include <unordered_map>
#include <vector>

/** A binary search tree, with `node_map` alongside it for fast lookups and iterators */
template <class K, class V>
class BST {
public:
    using TreeIterator = typename std::unordered_map<K, V>::iterator;

    /** Creates an empty BST
     * Runtime: O(1)
     */
    BST() : root(nullptr) { }

    /** Inserts a key-value pair into the BST
     * Runtime: O(h)
     */
    void insert(const K key, const V value);

    /** Removes the node with the given key from the BST
     * Runtime: O(h)
     */
    void remove(const K& key);

    /** Returns an iterator to the pair with `key` (looked up in `node_map`)
     * Runtime: expected O(1)
     */
    TreeIterator find(const K& key);

    /** Returns an iterator to the first key-value pair
     * Runtime: O(1)
     */
    TreeIterator begin();

    /** Returns an iterator one past the last key-value pair
     * Runtime: O(1)
     */
    TreeIterator end();

    /** Returns every key in the tree in sorted order (an in-order traversal)
     * Runtime: O(n)
     */
    std::vector<K> keys() const;

private:
    /** A node of the BST, holding one key-value pair */
    struct TreeNode {
        TreeNode* left;
        TreeNode* right;
        K key;
        V value;

        /** Creates a leaf holding `key` and `value`
         * Runtime: O(1)
         */
        TreeNode(const K& key, const V& value) : left(nullptr), right(nullptr), key(key), value(value) { }
    };

    /** a pointer to the root node of the tree */
    TreeNode* root;

    /** a map that lets us use iterators for fast access without needing to traverse the tree */
    std::unordered_map<K, V> node_map;

    // internal helpers

    /** Returns the pointer to `key`'s node, or the null spot where it goes
     * Runtime: O(h)
     */
    TreeNode*& _find(TreeNode*& root, const K& key);

    /** Inserts a new node at the null pointer `_find` stops on
     * Runtime: O(h)
     */
    void _insert(TreeNode*& root, const K& key, const V& value);

    /** Returns the pointer to the in-order predecessor of `root`
     * Runtime: O(h)
     */
    TreeNode*& _iop(TreeNode*& root);

    /** Swaps the key and value stored in two nodes
     * Runtime: O(1)
     */
    void _swap(TreeNode* a, TreeNode* b);

    /** Removes the node with `key` from the subtree rooted at `node`
     * Runtime: O(h)
     */
    void _remove(TreeNode*& node, const K& key);

    /** Appends the keys of the subtree rooted at `node` to `out`, in order
     * Runtime: O(n)
     */
    void _keys(TreeNode* node, std::vector<K>& out) const;
};
