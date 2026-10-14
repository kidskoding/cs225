// main.cpp

#include "Dictionary.hpp"

#include <iostream>
#include <string>

/** Dictionaries: insert, find, and remove through the dictionary ADT
 * Runtime: O(1) expected
 */
int main() {
    std::cout << "\n== Dictionaries ==\n";

    Dictionary<std::string, std::string> courses;
    courses.insert("Evans", "CS 225");
    courses.insert("Challen", "CS 124");
    std::cout << "find(Evans): " << courses.find("Evans")->second << "\n";
    std::cout << "remove(Challen) returns: " << courses.remove("Challen") << "\n";
    std::cout << "find(Challen) is end(): " << std::boolalpha
              << (courses.find("Challen") == courses.end()) << std::noboolalpha << "\n";
    return 0;
}
