// Heap.h

#pragma once
#include <cstddef>
#include <vector>

/** A min-heap: a complete binary tree stored in an array (root at index 1), and our priority queue */
template <class T>
class Heap {
public:
    /** Creates an empty heap
     * Runtime: O(1)
     */
    Heap();

    /** Copies `values` into the array as-is, then turns it into a heap with `buildHeap`
     * Runtime: O(n)
     */
    Heap(const std::vector<T>& values);

    /** Inserts `key` into the heap
     * Runtime: O(log n)
     */
    void insert(const T& key);

    /** Removes and returns the smallest value (the root)
     * Runtime: O(log n)
     */
    T removeMin();

    /** Returns whether there is anything left to remove
     * Runtime: O(1)
     */
    bool isEmpty() const;

    /** Returns the number of values in the heap
     * Runtime: O(1)
     */
    size_t size() const;

    /** Turns the unsorted array into a heap by heapifying down from the bottom up
     * Runtime: O(n)
     */
    void buildHeap();

    /** Returns the array that stores the heap, from index 1 (the root) to index n (the last node)
     * Runtime: O(n)
     */
    std::vector<T> items() const;

private:
    /** the array holding the heap one level at a time; index 0 is left empty */
    std::vector<T> item_;

    /** the number of values in the heap, which is also the index of the last node */
    size_t size_;

    /** the number of values the array can hold before it has to grow */
    size_t capacity_;

    /** Inserts `key` at the end of the array and heapifies it up
     * Runtime: O(log n)
     */
    void _insert(const T& key);

    /** Removes and returns the smallest value (the root)
     * Runtime: O(log n)
     */
    T _removeMin();

    /** Swaps the value at `index` up until it is no smaller than its parent
     * Runtime: O(log n)
     */
    void _heapifyUp(size_t index);

    /** Swaps the value at `index` down until it is no larger than its children
     * Runtime: O(log n)
     */
    void _heapifyDown(size_t index);

    /** Doubles the array, which allocates exactly the space for the next level of the tree
     * Runtime: O(n)
     */
    void _growArray();

    /** Returns the index of the parent of `index`
     * Runtime: O(1)
     */
    size_t _parent(size_t index) const;

    /** Returns the index of the left child of `index`
     * Runtime: O(1)
     */
    size_t _leftChild(size_t index) const;

    /** Returns the index of the right child of `index`
     * Runtime: O(1)
     */
    size_t _rightChild(size_t index) const;

    /** Returns whether `index` has no children (its left child would be past the end)
     * Runtime: O(1)
     */
    bool _isLeaf(size_t index) const;

    /** Returns the index of the smaller child (or the left child, if there is no right child)
     * Runtime: O(1)
     */
    size_t _minChild(size_t index) const;
};
