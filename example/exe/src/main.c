
#include <stdio.h>

extern int add(int, int);

int main(int argc, const char *argv[]) {
  printf("Hello, %s\n", "build in zig");
  printf("libadd: 1 + 2 = %d\n", add(1, 2));
  return 0;
}