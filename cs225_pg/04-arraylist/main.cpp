// main.cpp

#include "ArrayList.hpp"

#include <iostream>
#include <string>
#include <vector>

/** Prints `label`, then every value in `values` separated by spaces
 * Runtime: O(n)
 */
template <typename T>
void printValues(const std::string& label, const std::vector<T>& values) {
    std::cout << label << ":";
    for(const T& value : values) {
        std::cout << " " << value;
    }
    std::cout << "\n";
}

/** ArrayList and amortized analysis: pushBack doubling the buffer whenever it fills up
 * Runtime: O(n)
 */
int main() {
    std::cout << "\n== ArrayList and Amortized Analysis ==\n";

    ArrayList<int> list;
    for(int value = 1; value <= 5; value++) {
        list.pushBack(value);
        std::cout << "pushBack(" << value << "): length " << list.length()
                  << ", allocated " << list.allocated() << "\n";
    }

    std::vector<int> contents;
    for(int i = 0; i < list.length(); i++) {
        contents.push_back(list[i]);
    }
    printValues("contents", contents);
    return 0;
}
