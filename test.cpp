#include "iostream"
#include <cerrno>
#include <cstdio>
#include <ostream>
#include <pthread.h>

void a() {

}

int main() {
  std::cout << "wow" << std::endl;
  a();
  return 0;
}

