// ArrayList.h

#pragma once

/** A list stored in a contiguous buffer that doubles when it fills up (like `std::vector`) */
template <typename T>
class ArrayList {
public:
    /** Inserts data to the back of this `ArrayList`
     * Runtime: amortized O(1)
     */
    void pushBack(const T& value);

    /** Returns the element at `index` by reference
     * Runtime: O(1)
     */
    T& operator[](int index);

    /** Returns the number of elements in this `ArrayList` (`size - data`)
     * Runtime: O(1)
     */
    int length() const;

    /** Returns how many elements fit in the buffer before it has to grow (`capacity - data`)
     * Runtime: O(1)
     */
    int allocated() const;

private:
    /** a pointer to the start of the buffer */
    T* data = nullptr;

    /** a pointer one past the last element in use */
    T* size = nullptr;

    /** a pointer one past the end of the allocated buffer */
    T* capacity = nullptr;

    /** Copies the elements into a bigger buffer when it is full
     * Runtime: O(n)
     */
    void addSpace();
};
