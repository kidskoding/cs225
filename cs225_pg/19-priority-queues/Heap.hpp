// Heap.hpp

#pragma once
#include "Heap.h"
#include <stdexcept>
#include <utility>

/** Creates an empty heap
 * Runtime: O(1)
 */
template <class T>
Heap<T>::Heap() : item_(1), size_(0), capacity_(0) { }

/** Copies `values` into the array as-is, then turns it into a heap with `buildHeap`
 * Runtime: O(n)
 */
template <class T>
Heap<T>::Heap(const std::vector<T>& values)
    : item_(values.size() + 1), size_(values.size()), capacity_(values.size()) {
    // index 0 stays empty, so the values go in at indices 1 through n
    for(size_t i = 0; i < values.size(); i++) {
        item_[i + 1] = values[i];
    }
    buildHeap();
}

/** Inserts `key` into the heap
 * Runtime: O(log n)
 */
template <class T>
void Heap<T>::insert(const T& key) {
    _insert(key);
}

/** Removes and returns the smallest value (the root)
 * Runtime: O(log n)
 */
template <class T>
T Heap<T>::removeMin() {
    if(isEmpty()) {
        throw std::runtime_error("removeMin on an empty heap");
    }
    return _removeMin();
}

/** Returns whether there is anything left to remove
 * Runtime: O(1)
 */
template <class T>
bool Heap<T>::isEmpty() const {
    return size_ == 0;
}

/** Returns the number of values in the heap
 * Runtime: O(1)
 */
template <class T>
size_t Heap<T>::size() const {
    return size_;
}

/** Returns the array that stores the heap, from index 1 (the root) to index n (the last node)
 * Runtime: O(n)
 */
template <class T>
std::vector<T> Heap<T>::items() const {
    return std::vector<T>(item_.begin() + 1, item_.begin() + size_ + 1);
}

/** Inserts `key` at the end of the array and heapifies it up
 * Runtime: O(log n)
 */
template <class T>
void Heap<T>::_insert(const T& key) {
    // check to ensure there's space to insert an element
    // ...if not, grow the array
    if(size_ == capacity_) { _growArray(); }

    // insert the new element at the end of the array
    item_[++size_] = key;

    // restore the heap property
    _heapifyUp(size_);
}

/** Swaps the value at `index` up until it is no smaller than its parent
 * Runtime: O(log n)
 */
template <class T>
void Heap<T>::_heapifyUp(size_t index) {
    // index 1 is the root, which has no parent to swap with
    if(index > 1) {
        // swap with the parent if it is smaller, then keep going up
        if(item_[index] < item_[_parent(index)]) {
            std::swap(item_[index], item_[_parent(index)]);
            _heapifyUp(_parent(index));
        }
    }
}

/** Removes and returns the smallest value (the root)
 * Runtime: O(log n)
 */
template <class T>
T Heap<T>::_removeMin() {
    // swap with the last value
    // the minimum is always the root at index 1
    T minValue = item_[1];
    item_[1] = item_[size_];
    size_--;

    // restore the heap property
    _heapifyDown(1);

    // return the minimum value
    return minValue;
}

/** Swaps the value at `index` down until it is no larger than its children
 * Runtime: O(log n)
 */
template <class T>
void Heap<T>::_heapifyDown(size_t index) {
    if(!_isLeaf(index)) {
        // swap with the smaller child so the heap property holds below
        size_t minChildIndex = _minChild(index);
        if(item_[index] > item_[minChildIndex]) {
            std::swap(item_[index], item_[minChildIndex]);
            _heapifyDown(minChildIndex);
        }
    }
}

/** Turns the unsorted array into a heap by heapifying down from the bottom up
 * Runtime: O(n)
 */
template <class T>
void Heap<T>::buildHeap() {
    // every leaf is already a heap, so start at the parent of the last node
    for(size_t i = _parent(size_); i > 0; i--) {
        _heapifyDown(i);
    }
}

/** Doubles the array, which allocates exactly the space for the next level of the tree
 * Runtime: O(n)
 */
template <class T>
void Heap<T>::_growArray() {
    capacity_ = capacity_ == 0 ? 1 : 2 * capacity_;

    // one extra slot for the empty index 0
    item_.resize(capacity_ + 1);
}

/** Returns the index of the parent of `index`
 * Runtime: O(1)
 */
template <class T>
size_t Heap<T>::_parent(size_t index) const {
    // integer division is the floor of index / 2
    return index / 2;
}

/** Returns the index of the left child of `index`
 * Runtime: O(1)
 */
template <class T>
size_t Heap<T>::_leftChild(size_t index) const {
    return 2 * index;
}

/** Returns the index of the right child of `index`
 * Runtime: O(1)
 */
template <class T>
size_t Heap<T>::_rightChild(size_t index) const {
    return 2 * index + 1;
}

/** Returns whether `index` has no children (its left child would be past the end)
 * Runtime: O(1)
 */
template <class T>
bool Heap<T>::_isLeaf(size_t index) const {
    // the tree is complete, so a right child can't exist without a left child
    return _leftChild(index) > size_;
}

/** Returns the index of the smaller child (or the left child, if there is no right child)
 * Runtime: O(1)
 */
template <class T>
size_t Heap<T>::_minChild(size_t index) const {
    size_t left = _leftChild(index);
    size_t right = _rightChild(index);
    if(right > size_) { return left; }
    return item_[right] < item_[left] ? right : left;
}
