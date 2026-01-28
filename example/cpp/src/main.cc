
#include "add.h"
#include <iostream>

int main(int argc, const char *argv[]) {
  int a = add(1, 2);
  std::cout << "Hello" << a << std::endl;
  return 0;
}

// Windows zig c++ ./main.cc -o main.exe --verbose
/*
  zig -cc1
  -triple x86_64-unknown-windows-gnu
  ...
-isystem "..\\lib\\libcxx\\include"
-isystem "..\\lib\\libcxxabi\\include"
-isystem "..\\lib\\include"
-isystem "..\\lib\\libc\\include\\x86_64-windows-gnu"
-isystem "..\\lib\\libc\\include\\generic-mingw"
-isystem "..\\lib\\libc\\include\\x86_64-windows-any"
-isystem "..\\lib\\libc\\include\\any-windows-any"
-isystem "..\\lib\\libunwind\\include"
-D __MSVCRT_VERSION__=0xE00 
-D _WIN32_WINNT=0x0a00 
-D _LIBCPP_ABI_VERSION=1 
-D _LIBCPP_ABI_NAMESPACE=__1 
-D _LIBCPP_HAS_THREADS=1 
-D _LIBCPP_HAS_MONOTONIC_CLOCK 
-D _LIBCPP_HAS_TERMINAL 
-D _LIBCPP_HAS_MUSL_LIBC=0 
-D _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS 
-D _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS 
-D _LIBCPP_HAS_VENDOR_AVAILABILITY_ANNOTATIONS=0 
-D _LIBCPP_HAS_FILESYSTEM=1 
-D _LIBCPP_HAS_RANDOM_DEVICE 
-D _LIBCPP_HAS_LOCALIZATION 
-D _LIBCPP_HAS_UNICODE 
-D _LIBCPP_HAS_WIDE_CHARACTERS 
-D _LIBCPP_HAS_NO_STD_MODULES 
-D _LIBCPP_PSTL_BACKEND_SERIAL 
-D _LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE 
-D _LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS
*/
