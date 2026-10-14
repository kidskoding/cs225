// VertexHeap.h

#pragma once
#include <cstddef>
#include <vector>

/** A min-heap of vertex numbers ordered by each vertex's cost, which also tracks where every
 * vertex sits in the heap so `decreaseKey` can find it in O(1) (used by Prim's algorithm)
 */
class VertexHeap {
public:
    /** Puts every vertex 0 to n - 1 into the heap with its cost from `cost`, using buildHeap
     * Runtime: O(n)
     */
    VertexHeap(const std::vector<int>& cost);

    /** Removes and returns the vertex with the smallest cost
     * Runtime: O(log n)
     */
    int removeMin();

    /** Lowers the cost of `v` and heapifies it up to its new place
     * Runtime: O(log n)
     */
    void decreaseKey(int v, int newCost);

    /** Returns whether every vertex has been removed
     * Runtime: O(1)
     */
    bool isEmpty() const;

private:
    /** cost_[v] is the priority of vertex v */
    std::vector<int> cost_;

    /** the heap of vertex numbers, with the root at index 1 (index 0 is left empty) */
    std::vector<int> heap_;

    /** pos_[v] is v's index in `heap_` */
    std::vector<size_t> pos_;

    /** the number of vertices still in the heap */
    size_t size_;

    /** Swaps the vertex at `index` up until its parent's cost is no larger
     * Runtime: O(log n)
     */
    void _heapifyUp(size_t index);

    /** Swaps the vertex at `index` down until its cost is no larger than its children's
     * Runtime: O(log n)
     */
    void _heapifyDown(size_t index);

    /** Swaps two heap slots and updates `pos_` for both vertices
     * Runtime: O(1)
     */
    void _swap(size_t i, size_t j);

    /** Returns the index of the parent of `index`
     * Runtime: O(1)
     */
    size_t _parent(size_t index) const;

    /** Returns whether `index` has no children
     * Runtime: O(1)
     */
    bool _isLeaf(size_t index) const;

    /** Returns the index of the child with the smaller cost (or the left child, if it's the only one)
     * Runtime: O(1)
     */
    size_t _minChild(size_t index) const;
};
