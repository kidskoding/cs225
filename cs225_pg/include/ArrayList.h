// ArrayList.h

#pragma once

template <typename T>
class ArrayList {
public:
    /** Inserts data to the back of this `ArrayList`
    *  Runtime: O(1)
    */
    void pushBack(const T& data);
private:
    // a pointer to the start of the buffer
    T* data;

    // a pointer to the end of the last used space in the buffer
    T* size;

    // a pointer to the end of the allocated space in the buffer
    T* capacity;
    
    /** Allocates additional space to the buffer in this `ArrayList`
    *  Runtime: O(n)
    */
    void addSpace();
};