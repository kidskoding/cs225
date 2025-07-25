#pragma once

template <class T>
class BinaryTree {
private:
    struct TreeNode {
        T data;
        TreeNode* left;
        TreeNode* right;
    };

    TreeNode* root;

public:
    void preOrderTraversal(TreeNode* curr);
    void inOrderTraversal(TreeNode* curr);
    void postOrderTraversal(TreeNode* curr);
    void levelOrderTraversal();
};