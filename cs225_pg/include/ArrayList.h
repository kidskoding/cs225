// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:
    // insert an element at the end of this `ArrayList`
    void pushBack(const T& data);
private:
    // a pointer to the start of the buffer
    T* data;

    // a pointer to the end of the last used space in the buffer
    T* size;

    // a pointer to the end of the allocated space in the buffer
    T* capacity;

    // allocate additional space to the buffer in this `ArrayList`
    void addSpace();
};