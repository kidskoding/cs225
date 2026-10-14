// BTree.h

#pragma once
#include <initializer_list>
#include <vector>

/** A B-tree of order m: every node holds up to m - 1 sorted keys and up to m children.
 * Only search is implemented (the notes show insertion as an algorithm, not code)
 */
template <typename K>
class BTree {
public:
    /** One node of the B-tree, with its keys in a preallocated sorted array */
    struct BTreeNode {
        /** the sorted keys, preallocated to hold all m - 1 of them */
        std::vector<K> keys_;

        /** how many of the slots in `keys_` are in use */
        unsigned keys_ct_;

        /** child i holds the keys between key i - 1 and key i; unused children are null */
        std::vector<BTreeNode*> children_;

        /** Creates a node of a B-tree of order `order`, holding `keys` (in sorted order) and `children`
         * Runtime: O(m)
         */
        BTreeNode(unsigned order, std::initializer_list<K> keys, std::initializer_list<BTreeNode*> children = {});

        /** Returns whether the node has no children (its first child pointer is null)
         * Runtime: O(1)
         */
        bool isLeaf() const;

        /** Fetches child `i`; this is where the seek to disk or another server would happen
         * Runtime: O(1) seek (a copy of the node, like reading it off disk)
         */
        BTreeNode _fetchChild(unsigned i) const;
    };

    /** Creates a B-tree whose root is `root` (or an empty tree, if `root` is null)
     * Runtime: O(1)
     */
    BTree(BTreeNode* root = nullptr) : root_(root) { }

    /** Returns whether `key` is in the tree
     * Runtime: O(log_m n) seeks, plus O(m) work inside each node
     */
    bool exists(const K& key);

private:
    /** the root node of the tree */
    BTreeNode* root_;

    /** Returns whether `key` is in the subtree rooted at `node`
     * Runtime: O(log_m n) seeks, plus O(m) work inside each node
     */
    bool _exists(BTreeNode& node, const K& key);
};
