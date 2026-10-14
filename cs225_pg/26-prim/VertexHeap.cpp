// VertexHeap.cpp

#include "VertexHeap.h"
#include <utility>

/** Puts every vertex 0 to n - 1 into the heap with its cost from `cost`, using buildHeap
 * Runtime: O(n)
 */
VertexHeap::VertexHeap(const std::vector<int>& cost)
    : cost_(cost), heap_(cost.size() + 1), pos_(cost.size()), size_(cost.size()) {
    // vertex v starts at index v + 1, since index 0 is left empty
    for(size_t v = 0; v < cost.size(); v++) {
        heap_[v + 1] = v;
        pos_[v] = v + 1;
    }

    // buildHeap: every leaf is already a heap, so start at the parent of the last node
    for(size_t i = _parent(size_); i > 0; i--) {
        _heapifyDown(i);
    }
}

/** Removes and returns the vertex with the smallest cost
 * Runtime: O(log n)
 */
int VertexHeap::removeMin() {
    int minVertex = heap_[1];

    // move the last vertex to the root through `_swap`, so `pos_` stays correct
    _swap(1, size_);
    size_--;
    _heapifyDown(1);
    return minVertex;
}

/** Lowers the cost of `v` and heapifies it up to its new place
 * Runtime: O(log n)
 */
void VertexHeap::decreaseKey(int v, int newCost) {
    cost_[v] = newCost;
    // a smaller cost can only be out of place relative to its parent
    _heapifyUp(pos_[v]);
}

/** Returns whether every vertex has been removed
 * Runtime: O(1)
 */
bool VertexHeap::isEmpty() const {
    return size_ == 0;
}

/** Swaps the vertex at `index` up until its parent's cost is no larger
 * Runtime: O(log n)
 */
void VertexHeap::_heapifyUp(size_t index) {
    if(index > 1) {
        size_t parent = _parent(index);
        if(cost_[heap_[index]] < cost_[heap_[parent]]) {
            _swap(index, parent);
            _heapifyUp(parent);
        }
    }
}

/** Swaps the vertex at `index` down until its cost is no larger than its children's
 * Runtime: O(log n)
 */
void VertexHeap::_heapifyDown(size_t index) {
    if(!_isLeaf(index)) {
        size_t minChild = _minChild(index);
        if(cost_[heap_[index]] > cost_[heap_[minChild]]) {
            _swap(index, minChild);
            _heapifyDown(minChild);
        }
    }
}

/** Swaps two heap slots and updates `pos_` for both vertices
 * Runtime: O(1)
 */
void VertexHeap::_swap(size_t i, size_t j) {
    std::swap(heap_[i], heap_[j]);
    pos_[heap_[i]] = i; // keep track of where each vertex moved
    pos_[heap_[j]] = j;
}

/** Returns the index of the parent of `index`
 * Runtime: O(1)
 */
size_t VertexHeap::_parent(size_t index) const {
    return index / 2;
}

/** Returns whether `index` has no children
 * Runtime: O(1)
 */
bool VertexHeap::_isLeaf(size_t index) const {
    return 2 * index > size_;
}

/** Returns the index of the child with the smaller cost (or the left child, if it's the only one)
 * Runtime: O(1)
 */
size_t VertexHeap::_minChild(size_t index) const {
    size_t left = 2 * index;
    size_t right = 2 * index + 1;
    if(right > size_) { return left; }
    return cost_[heap_[right]] < cost_[heap_[left]] ? right : left;
}
