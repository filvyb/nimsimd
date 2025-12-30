import nimsimd/runtimecheck

let
  cpuHasAvx* = checkInstructionSets({AVX})
  cpuHasAvx2* = checkInstructionSets({AVX, AVX2})
  cpuHasAvx512* = checkInstructionSets({AVX512F, AVX512CD, AVX512VL, AVX512DQ, AVX512BW})
  cpuHasAvx512icl* = checkInstructionSets({
    AVX512F, AVX512CD, AVX512VL, AVX512DQ, AVX512BW,
    AVX512IFMA, AVX512VBMI, AVX512VBMI2, AVX512VPOPCNTDQ, AVX512BITALG, AVX512VNNI,
    VPCLMULQDQ, GFNI, VAES
  })
  cpuHasAvx512zen4* = checkInstructionSets({
    AVX512F, AVX512CD, AVX512VL, AVX512DQ, AVX512BW,
    AVX512IFMA, AVX512VBMI, AVX512VBMI2, AVX512VPOPCNTDQ, AVX512BITALG, AVX512VNNI,
    VPCLMULQDQ, GFNI, VAES, AVX512BF16
  })
  cpuHasVp2intersect* = checkInstructionSets({AVX512VP2INTERSECT})

echo "AVX: ", cpuHasAvx
echo "AVX2: ", cpuHasAvx2
echo "AVX512 (Skylake): ", cpuHasAvx512
echo "AVX512 ICL (Ice Lake): ", cpuHasAvx512icl
echo "AVX512 Zen4: ", cpuHasAvx512zen4
echo "VP2INTERSECT: ", cpuHasVp2intersect
