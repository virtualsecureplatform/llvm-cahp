// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

def WriteALU  : SchedWrite;
def WriteLDST : SchedWrite;

def EmeraldModel : SchedMachineModel {
  let MicroOpBufferSize = 0;
  let IssueWidth = 2;
  let LoadLatency = 2;
  let MispredictPenalty = 2;
  let CompleteModel = 0;
  let PostRAScheduler = 1;
}

def EmeraldALU    : ProcResource<2> { let BufferSize = 0; }
def EmeraldLdSt   : ProcResource<1> { let BufferSize = 0; }

let SchedModel = EmeraldModel in {
  def : WriteRes<WriteALU,  [EmeraldALU]>  { let Latency = 3; }
  def : WriteRes<WriteLDST, [EmeraldLdSt]> { let Latency = 3; }
}
