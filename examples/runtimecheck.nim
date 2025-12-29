import nimsimd/runtimecheck

let
  cpuHasAvx* = checkInstructionSets({AVX})
  cpuHasAvx2* = checkInstructionSets({AVX, AVX2})
  cpuHasAvx512f* = checkInstructionSets({AVX512F})
  cpuHasAvx512cd* = checkInstructionSets({AVX512F, AVX512CD})
  cpuHasAvx512dq* = checkInstructionSets({AVX512F, AVX512DQ})
  cpuHasAvx512bw* = checkInstructionSets({AVX512F, AVX512BW})
  cpuHasAvx512vl* = checkInstructionSets({AVX512F, AVX512VL})

echo "AVX: ", cpuHasAvx
echo "AVX2: ", cpuHasAvx2
echo "AVX512F: ", cpuHasAvx512f
echo "AVX512CD: ", cpuHasAvx512cd
echo "AVX512DQ: ", cpuHasAvx512dq
echo "AVX512BW: ", cpuHasAvx512bw
echo "AVX512VL: ", cpuHasAvx512vl
