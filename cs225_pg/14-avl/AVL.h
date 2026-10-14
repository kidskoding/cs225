// AVL.h

#pragma once
#include <unordered_map>
#include <vector>

/** A self-balancing BST that rotates to keep every node's balance factor in [-1, 1] */
template <class K, class V>
class AVL {
public:
    using TreeIterator = typename std::unordered_map<K, V>::iterator;

    /** Creates an empty AVL tree
     * Runtime: O(1)
     */
    AVL() : root(nullptr) { }

    /** Inserts a key-value pair into the AVL tree
     * Runtime: O(h) = O(log n)
     */
    void insert(K key, V value);

    /** Removes the node with `key`, rebalancing every ancestor on the way back up
     * Runtime: O(h) = O(log n)
     */
    void remove(const K& key);

    /** Returns an iterator to the pair with `key` (looked up in `node_map`, like the BST)
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

    /** Returns the height of the whole tree (-1 if it is empty)
     * Runtime: O(1)
     */
    int height() const;

private:
    /** A node of the AVL tree, which also stores the height of its subtree */
    struct TreeNode {
        K key;
        V value;

        // have each `TreeNode` store the height in order to self balance
        unsigned int height;

        TreeNode* left;
        TreeNode* right;

        /** Creates a leaf, which has height 0 and no children
         * Runtime: O(1)
         */
        TreeNode(const K& key, const V& value)
            : key(key), value(value), height(0), left(nullptr), right(nullptr) {}
    };

    /** a pointer to the root node of the tree */
    TreeNode* root;

    /** a map that lets us use iterators for fast access without needing to traverse the tree */
    std::unordered_map<K, V> node_map;

    /** Inserts a node and rebalances every node on the way back up
     * Runtime: O(h) = O(log n)
     */
    void _insert(const K& key, const V& value, TreeNode*& curr);

    /** Removes the node with `key` like a BST, then rebalances every node on the way back up
     * Runtime: O(h) = O(log n)
     */
    void _remove(TreeNode*& node, const K& key);

    /** Returns the pointer to the in-order predecessor of `root`
     * Runtime: O(h)
     */
    TreeNode*& _iop(TreeNode*& root);

    /** Returns the height of a node, or -1 for a null node
     * Runtime: O(1)
     */
    int height(TreeNode* node) const;

    /** Rotates the subtree at `curr` if it is out of balance
     * Runtime: O(1)
     */
    void _ensureBalance(TreeNode*& curr);

    /** Recomputes the height of `curr` from its children
     * Runtime: O(1)
     */
    void _updateHeight(TreeNode* curr);

    /** Rotates the subtree at `root` to the left
     * Runtime: O(1)
     */
    void _rotateLeft(TreeNode*& root);

    /** Rotates the subtree at `root` to the right
     * Runtime: O(1)
     */
    void _rotateRight(TreeNode*& root);

    /** Rotates left about the left child, then right about `root`
     * Runtime: O(1)
     */
    void _rotateLeftRight(TreeNode*& root);

    /** Rotates right about the right child, then left about `root`
     * Runtime: O(1)
     */
    void _rotateRightLeft(TreeNode*& root);

    /** Appends the keys of the subtree rooted at `node` to `out`, in order
     * Runtime: O(n)
     */
    void _keys(TreeNode* node, std::vector<K>& out) const;
};
