
#include <iostream>

int main(int argc, const char *argv[]) {
  std::cout << "Hello" << std::endl;
  return 0;
}

// -sys-header-deps -MV -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libcxx\\include" -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libcxxabi\\include"
// -isystem "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\include" -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\x86_64-windows-gnu"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\generic-mingw"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\x86_64-windows-any"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libc\\include\\any-windows-any"
// -isystem
// "C:\\Users\\no-ve\\scoop\\apps\\zig\\0.15.2\\lib\\libunwind\\include" -D
// __MSVCRT_VERSION__=0xE00 -D _WIN32_WINNT=0x0a00 -D _LIBCPP_ABI_VERSION=1 -D
// _LIBCPP_ABI_NAMESPACE=__1 -D _LIBCPP_HAS_THREADS=1 -D
// _LIBCPP_HAS_MONOTONIC_CLOCK -D _LIBCPP_HAS_TERMINAL -D
// _LIBCPP_HAS_MUSL_LIBC=0 -D _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS -D
// _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS -D
// _LIBCPP_HAS_VENDOR_AVAILABILITY_ANNOTATIONS=0 -D _LIBCPP_HAS_FILESYSTEM=1 -D
// _LIBCPP_HAS_RANDOM_DEVICE -D _LIBCPP_HAS_LOCALIZATION -D _LIBCPP_HAS_UNICODE
// -D _LIBCPP_HAS_WIDE_CHARACTERS -D _LIBCPP_HAS_NO_STD_MODULES -D
// _LIBCPP_PSTL_BACKEND_SERIAL -D
// _LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE -D
// _LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS -O0 -Wno-pragma-pack
// -fdeprecated-macro -ferror-limit 19 -fmessage-length=120 -stack-protector 2
// -stack-protector-buffer-size 4 -fno-use-cxa-atexit -fgnuc-version=4.2.1
// -fskip-odr-check-in-gmf -fcxx-exceptions -fexceptions -exception-model=seh
// -fcolor-diagnostics -fno-spell-checking -target-cpu raptorlake
// -target-feature -16bit-mode -target-feature -32bit-mode -target-feature
// +64bit -target-feature +adx -target-feature +aes -target-feature
// +allow-light-256-bit -target-feature -amx-avx512 -target-feature -amx-bf16
// -target-feature -amx-complex -target-feature -amx-fp16 -target-feature
// -amx-fp8 -target-feature -amx-int8 -target-feature -amx-movrs -target-feature
// -amx-tf32 -target-feature -amx-tile -target-feature -amx-transpose
// -target-feature +avx -target-feature -avx10.1-256 -target-feature
// -avx10.1-512 -target-feature -avx10.2-256 -target-feature -avx10.2-512
// -target-feature +avx2 -target-feature -avx512bf16 -target-feature
// -avx512bitalg -target-feature -avx512bw -target-feature -avx512cd
// -target-feature -avx512dq -target-feature -avx512f -target-feature
// -avx512fp16 -target-feature -avx512ifma -target-feature -avx512vbmi
// -target-feature -avx512vbmi2 -target-feature -avx512vl -target-feature
// -avx512vnni -target-feature -avx512vp2intersect -target-feature
// -avx512vpopcntdq -target-feature -avxifma -target-feature -avxneconvert
// -target-feature +avxvnni -target-feature -avxvnniint16 -target-feature
// -avxvnniint8 -target-feature +bmi -target-feature +bmi2 -target-feature
// -branch-hint -target-feature -branchfusion -target-feature -ccmp
// -target-feature -cf -target-feature -cldemote -target-feature +clflushopt
// -target-feature +clwb -target-feature -clzero -target-feature +cmov
// -target-feature -cmpccxadd -target-feature +crc32 -target-feature +cx16
// -target-feature +cx8 -target-feature -egpr -target-feature -enqcmd
// -target-feature -ermsb -target-feature -evex512 -target-feature +f16c
// -target-feature -false-deps-getmant -target-feature -false-deps-lzcnt-tzcnt
// -target-feature -false-deps-mulc -target-feature -false-deps-mullq
// -target-feature +false-deps-perm -target-feature +false-deps-popcnt
// -target-feature -false-deps-range -target-feature -fast-11bytenop
// -target-feature +fast-15bytenop -target-feature -fast-7bytenop
// -target-feature -fast-bextr -target-feature -fast-dpwssd -target-feature
// +fast-gather -target-feature -fast-hops -target-feature -fast-imm16
// -target-feature -fast-lzcnt -target-feature -fast-movbe -target-feature
// +fast-scalar-fsqrt -target-feature -fast-scalar-shift-masks -target-feature
// +fast-shld-rotate -target-feature +fast-variable-crosslane-shuffle
// -target-feature +fast-variable-perlane-shuffle -target-feature
// +fast-vector-fsqrt -target-feature -fast-vector-shift-masks -target-feature
// -faster-shift-than-shuffle -target-feature +fma -target-feature -fma4
// -target-feature +fsgsbase -target-feature -fsrm -target-feature +fxsr
// -target-feature +gfni -target-feature -harden-sls-ijmp -target-feature
// -harden-sls-ret -target-feature +hreset -target-feature -idivl-to-divb
// -target-feature +idivq-to-divl -target-feature -inline-asm-use-gpr32
// -target-feature +invpcid -target-feature -kl -target-feature -lea-sp
// -target-feature -lea-uses-ag -target-feature -lvi-cfi -target-feature
// -lvi-load-hardening -target-feature -lwp -target-feature +lzcnt
// -target-feature +macrofusion -target-feature +mmx -target-feature +movbe
// -target-feature +movdir64b -target-feature +movdiri -target-feature -movrs
// -target-feature -mwaitx -target-feature -ndd -target-feature -nf
// -target-feature -no-bypass-delay -target-feature +no-bypass-delay-blend
// -target-feature +no-bypass-delay-mov -target-feature +no-bypass-delay-shuffle
// -target-feature +nopl -target-feature -pad-short-functions -target-feature
// +pclmul -target-feature -pconfig -target-feature -pku -target-feature +popcnt
// -target-feature -ppx -target-feature -prefer-128-bit -target-feature
// -prefer-256-bit -target-feature -prefer-mask-registers -target-feature
// +prefer-movmsk-over-vtest -target-feature -prefer-no-gather -target-feature
// -prefer-no-scatter -target-feature -prefetchi -target-feature +prfchw
// -target-feature +ptwrite -target-feature -push2pop2 -target-feature -raoint
// -target-feature +rdpid -target-feature -rdpru -target-feature +rdrnd
// -target-feature +rdseed -target-feature -retpoline -target-feature
// -retpoline-external-thunk -target-feature -retpoline-indirect-branches
// -target-feature -retpoline-indirect-calls -target-feature -rtm
// -target-feature +sahf -target-feature -sbb-dep-breaking -target-feature
// +serialize -target-feature -seses -target-feature -sgx -target-feature +sha
// -target-feature -sha512 -target-feature +shstk -target-feature +slow-3ops-lea
// -target-feature -slow-incdec -target-feature -slow-lea -target-feature
// -slow-pmaddwd -target-feature -slow-pmulld -target-feature -slow-shld
// -target-feature -slow-two-mem-ops -target-feature -slow-unaligned-mem-16
// -target-feature -slow-unaligned-mem-32 -target-feature -sm3 -target-feature
// -sm4 -target-feature +sse -target-feature +sse2 -target-feature +sse3
// -target-feature +sse4.1 -target-feature +sse4.2 -target-feature -sse4a
// -target-feature -sse-unaligned-mem -target-feature +ssse3 -target-feature
// -tagged-globals -target-feature -tbm -target-feature -tsxldtrk
// -target-feature +tuning-fast-imm-vector-shift -target-feature -uintr
// -target-feature -use-glm-div-sqrt-costs -target-feature -use-slm-arith-costs
// -target-feature -usermsr -target-feature +vaes -target-feature +vpclmulqdq
// -target-feature +vzeroupper -target-feature +waitpkg -target-feature
// -wbnoinvd -target-feature -widekl -target-feature +x87 -target-feature -xop
// -target-feature +xsave -target-feature +xsavec -target-feature +xsaveopt
// -target-feature +xsaves -target-feature -zu
// -fsanitize=alignment,array-bounds,bool,builtin,enum,float-cast-overflow,integer-divide-by-zero,nonnull-attribute,null,pointer-overflow,return,returns-nonnull-attribute,shift-base,shift-exponent,signed-integer-overflow,unreachable,vla-bound
// -fsanitize-recover=alignment,array-bounds,bool,builtin,enum,float-cast-overflow,integer-divide-by-zero,nonnull-attribute,null,pointer-overflow,returns-nonnull-attribute,shift-base,shift-exponent,signed-integer-overflow,vla-bound
// -fsanitize-merge=alignment,array-bounds,bool,builtin,enum,float-cast-overflow,integer-divide-by-zero,nonnull-attribute,null,pointer-overflow,return,returns-nonnull-attribute,shift-base,shift-exponent,signed-integer-overflow,unreachable,vla-bound
// -fno-sanitize-memory-param-retval -fno-sanitize-address-use-odr-indicator
// -faddrsig -o ".zig-cache\\tmp\\40c5e8e226f1b9dc-main.obj" -x c++
// ./src/main.cc

// ignoring nonexistent directory
// "C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\x86_64-windows-gnu"
// ignoring nonexistent directory
// "C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\generic-mingw"
// ignoring nonexistent directory
// "C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\x86_64-windows-any"
// #include "..." search starts here:
// #include <...> search starts here:
//  C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libcxx\include
//  C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libcxxabi\include
//  C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\include
//  C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libc\include\any-windows-any
//  C:\Users\no-ve\scoop\apps\zig\0.15.2\lib\libunwind\include