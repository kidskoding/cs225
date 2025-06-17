// ArrayList.h

#pragma once

template<typename T>
class ArrayList {
public:
    void pushBack(const T& data);
private:
    // a pointer to the start of the buffer
    T* data;

    // a pointer to the end of the last used space in the buffer
    T* size;

    // a pointer to the end of the allocated space in the buffer
    T* capacity;
    
    void addSpace();
};