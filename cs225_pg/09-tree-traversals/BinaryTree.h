// BinaryTree.h

#pragma once
#include <vector>

/** A binary tree of `TreeNode`s, with the four traversals from the notes */
template <class T>
class BinaryTree {
private:
    /** A node of the tree, with up to two children */
    struct TreeNode {
        /** the data each tree node holds */
        T data;

        /** a pointer to the left child `TreeNode` (or `nullptr` if non-existent) */
        TreeNode* left;

        /** a pointer to the right child `TreeNode` (or `nullptr` if non-existent) */
        TreeNode* right;

        /** Creates a leaf holding `data`
         * Runtime: O(1)
         */
        TreeNode(const T& data) : data(data), left(nullptr), right(nullptr) { }
    };

    /** a pointer to the root node of a tree */
    TreeNode* root;

public:
    /** Creates an empty tree
     * Runtime: O(1)
     */
    BinaryTree() : root(nullptr) { }

    /** Builds a complete tree from its values listed level by level, left to right
     * (the node at index i has children at 2i + 1 and 2i + 2)
     * Runtime: O(n)
     */
    BinaryTree(const std::vector<T>& levelOrder);

    /** Prints every node in pre-order (node, left subtree, right subtree)
     *
     * Preorder Traversal steps:
     * 1. Check if `curr == nullptr`; if so, halt the recursion (no more subtrees to process)
     * 2. Visit the current `TreeNode` (`curr`)
     * 3. Repeat the process recursively on the left subtree
     * 4. Repeat the process recursively on the right subtree
     *
     * Runtime: O(n)
     */
    void preOrderTraversal(TreeNode* curr);

    /** Prints every node in in-order (left subtree, node, right subtree)
     *
     * Inorder Traversal steps:
     * 1. Check if `curr == nullptr`; if so, halt the recursion (no more subtrees to process)
     * 2. Repeat the process recursively on the left subtree
     * 3. Visit the current `TreeNode` (`curr`)
     * 4. Repeat the process recursively on the right subtree
     *
     * Runtime: O(n)
     */
    void inOrderTraversal(TreeNode* curr);

    /** Prints every node in post-order (left subtree, right subtree, node)
     *
     * Postorder Traversal steps:
     * 1. Check if `curr == nullptr`; if so, halt the recursion (no more subtrees to process)
     * 2. Repeat the process recursively on the left subtree
     * 3. Repeat the process recursively on the right subtree
     * 4. Visit the current `TreeNode` (`curr`)
     *
     * Runtime: O(n)
     */
    void postOrderTraversal(TreeNode* curr);

    /** Prints every node in pre-order, starting from the root
     * Runtime: O(n)
     */
    void preOrderTraversal() { preOrderTraversal(root); }

    /** Prints every node in in-order, starting from the root
     * Runtime: O(n)
     */
    void inOrderTraversal() { inOrderTraversal(root); }

    /** Prints every node in post-order, starting from the root
     * Runtime: O(n)
     */
    void postOrderTraversal() { postOrderTraversal(root); }

    /** Prints every node level by level, from left to right
     * Runtime: O(n)
     */
    void levelOrderTraversal();
};
