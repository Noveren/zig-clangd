
#include <iostream>

int main(int argc, const char *argv[]) {
  std::cout << "Hello" << std::endl;
  return 0;
}

// Windows
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

// TODO MacOs
// -sys-header-deps -MV -isystem
// /opt/homebrew/Cellar/zig/0.15.2/lib/zig/libcxx/include -isystem
// /opt/homebrew/Cellar/zig/0.15.2/lib/zig/libcxxabi/include -isystem
// /opt/homebrew/Cellar/zig/0.15.2/lib/zig/include -isystem
// /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include -isystem
// /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include -isystem
// /opt/homebrew/include -iframework
// /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks
// -D _LIBCPP_ABI_VERSION=1 -D _LIBCPP_ABI_NAMESPACE=__1 -D
// _LIBCPP_HAS_THREADS=1 -D _LIBCPP_HAS_MONOTONIC_CLOCK -D _LIBCPP_HAS_TERMINAL
// -D _LIBCPP_HAS_MUSL_LIBC=0 -D _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS -D
// _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS -D
// _LIBCPP_HAS_VENDOR_AVAILABILITY_ANNOTATIONS=0 -D _LIBCPP_HAS_FILESYSTEM=1 -D
// _LIBCPP_HAS_RANDOM_DEVICE -D _LIBCPP_HAS_LOCALIZATION -D _LIBCPP_HAS_UNICODE
// -D _LIBCPP_HAS_WIDE_CHARACTERS -D _LIBCPP_HAS_NO_STD_MODULES -D
// _LIBCPP_PSTL_BACKEND_SERIAL -D
// _LIBCPP_HARDENING_MODE=_LIBCPP_HARDENING_MODE_NONE -D
// _LIBCPP_ENABLE_CXX17_REMOVED_UNEXPECTED_FUNCTIONS
// -F/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks
// -O0 -Wno-overriding-option -fdeprecated-macro -ferror-limit 19
// -stack-protector 2 -stack-protector-buffer-size 4 -fblocks
// -fencode-extended-block-signature -fregister-global-dtors-with-atexit
// -fgnuc-version=4.2.1 -fskip-odr-check-in-gmf -fcxx-exceptions -fexceptions
// -fmax-type-align=16 -fcolor-diagnostics -fno-spell-checking -target-cpu
// apple-m2 -target-feature -addr-lsl-slow-14 -target-feature +aes
// -target-feature -aggressive-fma -target-feature
// +alternate-sextload-cvt-f32-pattern -target-feature +altnzcv -target-feature
// -alu-lsl-fast -target-feature +am -target-feature +amvs -target-feature
// +arith-bcc-fusion -target-feature +arith-cbz-fusion -target-feature
// -ascend-store-address -target-feature -avoid-ldapur -target-feature
// -balance-fp-ops -target-feature +bf16 -target-feature -brbe -target-feature
// +bti -target-feature -call-saved-x10 -target-feature -call-saved-x11
// -target-feature -call-saved-x12 -target-feature -call-saved-x13
// -target-feature -call-saved-x14 -target-feature -call-saved-x15
// -target-feature -call-saved-x18 -target-feature -call-saved-x8
// -target-feature -call-saved-x9 -target-feature +ccdp -target-feature +ccidx
// -target-feature +ccpp -target-feature -chk -target-feature -clrbhb
// -target-feature -cmp-bcc-fusion -target-feature -cmpbr -target-feature
// +complxnum -target-feature +CONTEXTIDREL2 -target-feature -cpa
// -target-feature +crc -target-feature -crypto -target-feature -cssc
// -target-feature -d128 -target-feature +disable-latency-sched-heuristic
// -target-feature -disable-ldp -target-feature -disable-stp -target-feature
// +dit -target-feature +dotprod -target-feature +ecv -target-feature +el2vmsa
// -target-feature +el3 -target-feature -enable-select-opt -target-feature -ete
// -target-feature -exynos-cheap-as-move -target-feature -f32mm -target-feature
// -f64mm -target-feature -f8f16mm -target-feature -f8f32mm -target-feature
// -faminmax -target-feature +fgt -target-feature -fix-cortex-a53-835769
// -target-feature +flagm -target-feature -fmv -target-feature
// -force-32bit-jump-tables -target-feature +fp16fml -target-feature -fp8
// -target-feature -fp8dot2 -target-feature -fp8dot4 -target-feature -fp8fma
// -target-feature +fp-armv8 -target-feature +fpac -target-feature -fprcvt
// -target-feature +fptoint -target-feature -fujitsu-monaka -target-feature
// +fullfp16 -target-feature +fuse-address -target-feature
// -fuse-addsub-2reg-const1 -target-feature +fuse-adrp-add -target-feature
// +fuse-aes -target-feature +fuse-arith-logic -target-feature +fuse-crypto-eor
// -target-feature +fuse-csel -target-feature +fuse-literals -target-feature
// -gcs -target-feature -harden-sls-blr -target-feature -harden-sls-nocomdat
// -target-feature -harden-sls-retbr -target-feature -hbc -target-feature -hcx
// -target-feature +i8mm -target-feature -ite -target-feature +jsconv
// -target-feature -ldp-aligned-only -target-feature +lor -target-feature -ls64
// -target-feature +lse -target-feature -lse128 -target-feature +lse2
// -target-feature -lsfe -target-feature -lsui -target-feature -lut
// -target-feature -mec -target-feature -mops -target-feature +mpam
// -target-feature -mte -target-feature +neon -target-feature -nmi
// -target-feature -no-bti-at-return-twice -target-feature -no-neg-immediates
// -target-feature -no-sve-fp-ld1r -target-feature -no-zcz-fp -target-feature
// +nv -target-feature -occmo -target-feature -outline-atomics -target-feature
// +pan -target-feature +pan-rwv -target-feature +pauth -target-feature
// -pauth-lr -target-feature -pcdphint -target-feature +perfmon -target-feature
// -pops -target-feature -predictable-select-expensive -target-feature +predres
// -target-feature -prfm-slc-target -target-feature -rand -target-feature +ras
// -target-feature -rasv2 -target-feature +rcpc -target-feature -rcpc3
// -target-feature +rcpc-immo -target-feature +rdm -target-feature
// -reserve-lr-for-ra -target-feature -reserve-x1 -target-feature -reserve-x10
// -target-feature -reserve-x11 -target-feature -reserve-x12 -target-feature
// -reserve-x13 -target-feature -reserve-x14 -target-feature -reserve-x15
// -target-feature -reserve-x18 -target-feature -reserve-x2 -target-feature
// -reserve-x20 -target-feature -reserve-x21 -target-feature -reserve-x22
// -target-feature -reserve-x23 -target-feature -reserve-x24 -target-feature
// -reserve-x25 -target-feature -reserve-x26 -target-feature -reserve-x27
// -target-feature -reserve-x28 -target-feature -reserve-x3 -target-feature
// -reserve-x4 -target-feature -reserve-x5 -target-feature -reserve-x6
// -target-feature -reserve-x7 -target-feature -reserve-x9 -target-feature -rme
// -target-feature +sb -target-feature +sel2 -target-feature +sha2
// -target-feature +sha3 -target-feature -slow-misaligned-128store
// -target-feature -slow-paired-128 -target-feature -slow-strqro-store
// -target-feature -sm4 -target-feature -sme -target-feature -sme2
// -target-feature -sme2p1 -target-feature -sme2p2 -target-feature -sme-b16b16
// -target-feature -sme-f16f16 -target-feature -sme-f64f64 -target-feature
// -sme-f8f16 -target-feature -sme-f8f32 -target-feature -sme-fa64
// -target-feature -sme-i16i64 -target-feature -sme-lutv2 -target-feature
// -sme-mop4 -target-feature -sme-tmop -target-feature -spe -target-feature
// -spe-eef -target-feature -specres2 -target-feature +specrestrict
// -target-feature +ssbs -target-feature -ssve-aes -target-feature -ssve-bitperm
// -target-feature -ssve-fp8dot2 -target-feature -ssve-fp8dot4 -target-feature
// -ssve-fp8fma -target-feature +store-pair-suppress -target-feature
// -stp-aligned-only -target-feature -strict-align -target-feature -sve
// -target-feature -sve2 -target-feature -sve2-aes -target-feature -sve2-bitperm
// -target-feature -sve2-sha3 -target-feature -sve2-sm4 -target-feature -sve2p1
// -target-feature -sve2p2 -target-feature -sve-aes -target-feature -sve-aes2
// -target-feature -sve-b16b16 -target-feature -sve-bfscale -target-feature
// -sve-bitperm -target-feature -sve-f16f32mm -target-feature -tagged-globals
// -target-feature -the -target-feature +tlb-rmi -target-feature -tlbiw
// -target-feature -tme -target-feature -tpidr-el1 -target-feature -tpidr-el2
// -target-feature -tpidr-el3 -target-feature -tpidrro-el0 -target-feature
// +tracev8.4 -target-feature -trbe -target-feature +uaops -target-feature
// -use-experimental-zeroing-pseudos -target-feature
// -use-fixed-over-scalable-if-equal-cost -target-feature -use-postra-scheduler
// -target-feature -use-reciprocal-square-root -target-feature +v8.1a
// -target-feature +v8.2a -target-feature +v8.3a -target-feature +v8.4a
// -target-feature +v8.5a -target-feature +v8.6a -target-feature -v8.7a
// -target-feature -v8.8a -target-feature -v8.9a -target-feature +v8a
// -target-feature -v8r -target-feature -v9.1a -target-feature -v9.2a
// -target-feature -v9.3a -target-feature -v9.4a -target-feature -v9.5a
// -target-feature -v9.6a -target-feature -v9a -target-feature +vh
// -target-feature -wfxt -target-feature -xs -target-feature +zcm
// -target-feature +zcz -target-feature -zcz-fp-workaround -target-feature
// +zcz-gp
// -fsanitize=alignment,array-bounds,bool,builtin,enum,float-cast-overflow,integer-divide-by-zero,nonnull-attribute,null,pointer-overflow,return,returns-nonnull-attribute,shift-base,shift-exponent,signed-integer-overflow,unreachable,vla-bound
// -fsanitize-recover=alignment,array-bounds,bool,builtin,enum,float-cast-overflow,integer-divide-by-zero,nonnull-attribute,null,pointer-overflow,returns-nonnull-attribute,shift-base,shift-exponent,signed-integer-overflow,vla-bound
// -fsanitize-merge=alignment,array-bounds,bool,builtin,enum,float-cast-overflow,integer-divide-by-zero,nonnull-attribute,null,pointer-overflow,return,returns-nonnull-attribute,shift-base,shift-exponent,signed-integer-overflow,unreachable,vla-bound
// -fno-sanitize-memory-param-retval -fno-sanitize-address-use-odr-indicator
// -D__GCC_HAVE_DWARF2_CFI_ASM=1 -o .zig-cache/tmp/4850cb81e593fb9a-main.o -x
// c++ ./src/main.cc clang -cc1 version 20.1.8 based upon LLVM 20.1.8 default
// target arm64-apple-darwin24.6.0 ignoring duplicate directory
// "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include" ignoring
// duplicate directory
// "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks"
//   as it is a non-system directory that duplicates a system directory
// #include "..." search starts here:
// #include <...> search starts here:
//  /opt/homebrew/Cellar/zig/0.15.2/lib/zig/libcxx/include
//  /opt/homebrew/Cellar/zig/0.15.2/lib/zig/libcxxabi/include
//  /opt/homebrew/Cellar/zig/0.15.2/lib/zig/include
//  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include
//  /opt/homebrew/include
//  /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks
//  (framework directory)
// End of search list.
// zig ld -dynamic -platform_version macos 15.6.1 15.5 -syslibroot
// /Library/Developer/Comman