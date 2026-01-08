
#include "add.h"
#include "stdio.h"

int main(int argc, const char *argv[]) {
  printf("Hello, %s\n", "build in zig");
  printf("libadd   c: 1 + 2 = %d\n", add(1, 2));
  printf("libadd zig: 1 + 2 = %d\n", add_zig(1, 2));
  return 0;
}