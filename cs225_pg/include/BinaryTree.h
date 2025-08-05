#pragma once

template <class T>
class BinaryTree {
private:
    struct TreeNode {
        /** the data each tree node holds */
        T data;

        /** a pointer to the left child `TreeNode` (or `nullptr` if non-existent) */
        TreeNode* left;

        /** a pointer to the right child `TreeNode` (or `nullptr` if non-existent) */
        TreeNode* right;
    };

    /** a pointer to the root node of a tree */
    TreeNode* root;

public:
    /** Computes the pre order traversal of a tree
     *
     * Preorder Traversal steps:
     * 1. Check if `curr == nullptr`; if so, halt the recursion (no more subtrees to process)
     * 2. Visit the current `TreeNode` (`curr`)
     * 3. Repeat the process recursively on the left subtree
     * 4. Repeat the process recursively on the right subtree
     */
    void preOrderTraversal(TreeNode* curr);

    /** Computes the inorder traversal of a tree
     *
     * Inorder Traversal steps:
     * 1. Check if `curr == nullptr`; if so, halt the recursion (no more subtrees to process)
     * 2. Repeat the process recursively on the left subtree
     * 3. Visit the current `TreeNode` (`curr`)
     * 4. Repeat the process recursively on the right subtree
     */
    void inOrderTraversal(TreeNode* curr);

    /** Computes the post order traversal of a tree
     *
     * Postorder Traversal steps:
     * 1. Check if `curr == nullptr`; if so, halt the recursion (no more subtrees to process)
     * 2. Repeat the process recursively on the left subtree
     * 3. Repeat the process recursively on the right subtree
     * 4. Visit the current `TreeNode` (`curr`)
     */
    void postOrderTraversal(TreeNode* curr);

    // Computes the level order traversal of a tree
    void levelOrderTraversal();
};
