// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

import "DPI-C" function void trace_init();
import "DPI-C" function void trace_if(int pc);
import "DPI-C" function void trace_de(int pc, int insn);
import "DPI-C" function void trace_ex(int pc);
import "DPI-C" function void trace_wb(int pc);

module swerv_el2_microarchtrace (
  input clk,

  input if_req,
  input [31:0] if_pc,
  input de_valid,
  input [31:0] de_pc,
  input [31:0] de_insn,
  input de_compact,
  input ex_valid,
  input [31:0] ex_pc,

  input [1:0] wb_valid,
  input [31:0] wb_pc
);

  reg first, if_req_q;
  reg [31:0] if_pc_q;

  reg cycle; // debug

  initial begin
    first = 1;
    trace_init();
    cycle = 0;
  end

  always @(posedge clk) begin
    cycle <= cycle + 1;
    if_pc_q <= if_pc;
    if_req_q <= if_req;
    first <= first & !if_req;
    if (|wb_valid)
      trace_wb(wb_pc);
    if (ex_valid)
      trace_ex(ex_pc);
    if (de_valid)
      trace_de(de_pc, de_insn);
    if (if_req && (!if_req_q || (if_req_q && (if_pc != if_pc_q))))
      trace_if(if_pc);
  end
endmodule
