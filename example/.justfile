
cc:
    zig c++ ./src/main.cc -o ./zig-out/cxx.exe --verbose > ./zig-out/zig_cxx.txt

c:
    zig cc ./src/main.c -o ./zig-out/c.exe --verbose > ./zig-out/zig_c.txt