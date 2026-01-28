
#include "add.h"
#include <stdio.h>

int main(int argc, const char *argv[]) {
  printf("Hello, %s\n", "build in zig");
  printf("libadd   c: 1 + 2 = %d\n", add(1, 2));
  printf("libadd zig: 1 + 2 = %d\n", add_zig(1, 2));
  return 0;
}

// Windows
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\include"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\x86_64-windows-gnu"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\generic-mingw"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\x86_64-windows-any"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\any-windows-any"
// -D __MSVCRT_VERSION__=0xE00 -D _WIN32_WINNT=0x0a00
// clang -cc1 version 20.1.2 based upon LLVM 20.1.2 default target
// x86_64-windows-gnu ignoring nonexistent directory
// "C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\x86_64-windows-gnu"
// ignoring nonexistent directory
// "C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\generic-mingw"
// ignoring nonexistent directory
// "C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\x86_64-windows-any"
// #include "..." search starts here:
// #include <...> search starts here:
//  C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\include
//  C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\any-windows-any