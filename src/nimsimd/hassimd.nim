import std/macros, std/tables

var simdProcs* {.compileTime.}: Table[string, NimNode]

proc procName(procedure: NimNode): string =
  ## Given a procedure this returns the name as a string.
  let nameNode = procedure[0]
  if nameNode.kind == nnkPostfix:
    nameNode[1].strVal
  else:
    nameNode.strVal

proc procArguments(procedure: NimNode): seq[NimNode] =
  ## Given a procedure this gets the arguments as a list.
  for i, arg in procedure[3]:
    if i > 0:
      for j in 0 ..< arg.len - 2:
        result.add(arg[j])

proc procReturnType(procedure: NimNode): NimNode =
  ## Given a procedure this gets the return type.
  procedure[3][0]

proc procSignature(procedure: NimNode): string =
  ## Given a procedure this returns the signature as a string.
  result = "("

  for i, arg in procedure[3]:
    if i > 0:
      for j in 0 ..< arg.len - 2:
        result &= arg[^2].repr & ", "

  if procedure[3].len > 1:
    result = result[0 ..^ 3]

  result &= ")"

  let ret = procedure.procReturnType()
  if ret.kind != nnkEmpty:
    result &= ": " & ret.repr

proc callAndReturn(name: NimNode, procedure: NimNode): NimNode =
  ## Produces a procedure call with arguments.
  let
    retType = procedure.procReturnType()
    call = newNimNode(nnkCall)
  call.add(name)
  for arg in procedure.procArguments():
    call.add(arg)
  if retType.kind == nnkEmpty:
    result = quote do:
      `call`
      return
  else:
    result = quote do:
      return `call`

macro simd*(procedure: untyped) =
  let signature = procedure.procName() & procSignature(procedure)
  simdProcs[signature] = procedure.copy()
  return procedure

macro hasSimd*(procedure: untyped) =
  let
    name = procedure.procName()
    nameNeon = name & "Neon"
    nameSse2 = name & "Sse2"
    nameAvx = name & "Avx"
    nameAvx2 = name & "Avx2"
    nameAvx512f = name & "Avx512f"
    nameAvx512bw = name & "Avx512bw"
    nameAvx512dq = name & "Avx512dq"
    nameAvx512vl = name & "Avx512vl"
    nameAvx512cd = name & "Avx512cd"
    nameAvx512 = name & "Avx512"
    nameAvx512vnni = name & "Avx512vnni"
    nameAvx512ifma = name & "Avx512ifma"
    nameAvx512vbmi = name & "Avx512vbmi"
    nameAvx512vpopcntdq = name & "Avx512vpopcntdq"
    nameAvx512vbmi2 = name & "Avx512vbmi2"
    nameAvx512bitalg = name & "Avx512bitalg"
    nameAvx512icl = name & "Avx512icl"
    nameAvx512bf16 = name & "Avx512bf16"
    nameGfni = name & "Gfni"
    nameVaes = name & "Vaes"
    nameVp2intersect = name & "Vp2intersect"
    nameVpclmulqdq = name & "Vpclmulqdq"
    callNeon = callAndReturn(ident(nameNeon), procedure)
    callSse2 = callAndReturn(ident(nameSse2), procedure)
    callAvx = callAndReturn(ident(nameAvx), procedure)
    callAvx2 = callAndReturn(ident(nameAvx2), procedure)
    callAvx512f = callAndReturn(ident(nameAvx512f), procedure)
    callAvx512bw = callAndReturn(ident(nameAvx512bw), procedure)
    callAvx512dq = callAndReturn(ident(nameAvx512dq), procedure)
    callAvx512vl = callAndReturn(ident(nameAvx512vl), procedure)
    callAvx512cd = callAndReturn(ident(nameAvx512cd), procedure)
    callAvx512 = callAndReturn(ident(nameAvx512), procedure)
    callAvx512vnni = callAndReturn(ident(nameAvx512vnni), procedure)
    callAvx512ifma = callAndReturn(ident(nameAvx512ifma), procedure)
    callAvx512vbmi = callAndReturn(ident(nameAvx512vbmi), procedure)
    callAvx512vpopcntdq = callAndReturn(ident(nameAvx512vpopcntdq), procedure)
    callAvx512vbmi2 = callAndReturn(ident(nameAvx512vbmi2), procedure)
    callAvx512bitalg = callAndReturn(ident(nameAvx512bitalg), procedure)
    callAvx512icl = callAndReturn(ident(nameAvx512icl), procedure)
    callAvx512bf16 = callAndReturn(ident(nameAvx512bf16), procedure)
    callGfni = callAndReturn(ident(nameGfni), procedure)
    callVaes = callAndReturn(ident(nameVaes), procedure)
    callVp2intersect = callAndReturn(ident(nameVp2intersect), procedure)
    callVpclmulqdq = callAndReturn(ident(nameVpclmulqdq), procedure)

  var
    foundSimd: bool

  if procedure[6].kind != nnkStmtList:
    error("hasSimd proc body must start with nnkStmtList")

  var insertIdx = 0
  if procedure[6][0].kind == nnkCommentStmt:
    insertIdx = 1

  when defined(amd64):
    if nameAvx512icl & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512icl:
          `callAvx512icl`
      )
      inc insertIdx
    if nameAvx512bf16 & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512bf16:
          `callAvx512bf16`
      )
      inc insertIdx
    if nameGfni & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasGfni:
          `callGfni`
      )
      inc insertIdx
    if nameVaes & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasVaes:
          `callVaes`
      )
      inc insertIdx
    if nameVp2intersect & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasVp2intersect:
          `callVp2intersect`
      )
      inc insertIdx
    if nameVpclmulqdq & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasVpclmulqdq:
          `callVpclmulqdq`
      )
      inc insertIdx
    if nameAvx512 & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512:
          `callAvx512`
      )
      inc insertIdx
    if nameAvx512bitalg & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512bitalg:
          `callAvx512bitalg`
      )
      inc insertIdx
    if nameAvx512vbmi2 & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512vbmi2:
          `callAvx512vbmi2`
      )
      inc insertIdx
    if nameAvx512vpopcntdq & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512vpopcntdq:
          `callAvx512vpopcntdq`
      )
      inc insertIdx
    if nameAvx512vbmi & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512vbmi:
          `callAvx512vbmi`
      )
      inc insertIdx
    if nameAvx512ifma & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512ifma:
          `callAvx512ifma`
      )
      inc insertIdx
    if nameAvx512vnni & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512vnni:
          `callAvx512vnni`
      )
      inc insertIdx
    if nameAvx512bw & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512bw:
          `callAvx512bw`
      )
      inc insertIdx
    if nameAvx512dq & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512dq:
          `callAvx512dq`
      )
      inc insertIdx
    if nameAvx512vl & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512vl:
          `callAvx512vl`
      )
      inc insertIdx
    if nameAvx512cd & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512cd:
          `callAvx512cd`
      )
      inc insertIdx
    if nameAvx512f & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx512f:
          `callAvx512f`
      )
      inc insertIdx
    if nameAvx2 & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx2:
          `callAvx2`
      )
      inc insertIdx
    if nameAvx & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        if cpuHasAvx:
          `callAvx`
      )
      inc insertIdx
    if nameSse2 & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        `callSse2`
      )
      inc insertIdx
      while procedure[6].len > insertIdx:
        procedure[6].del(insertIdx)
  elif defined(arm64):
    if nameNeon & procSignature(procedure) in simdProcs:
      foundSimd = true
      procedure[6].insert(insertIdx, quote do:
        `callNeon`
      )
      inc insertIdx
      while procedure[6].len > insertIdx:
        procedure[6].del(insertIdx)

  return procedure
