// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

import "DPI-C" function void trace_init();
import "DPI-C" function void trace_if(int pc);
import "DPI-C" function void trace_de(int pc, int insn);
import "DPI-C" function void trace_ex(int pc);
import "DPI-C" function void trace_load(int pc);
import "DPI-C" function void trace_wb(int pc);
import "DPI-C" function void trace_loadwb();

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
  input lsu_nonblock_load_valid,
  input [1:0] wb_valid,
  input [31:0] wb_pc,
  input load_wb_valid
);

  reg first, if_req_q;
  reg [31:0] if_pc_q;

  reg cycle; // debug
  logic next_is_finish;

  initial begin
    first = 1;
    trace_init();
    cycle = 0;
    next_is_finish = 0;
  end

  always @(posedge clk) begin
    cycle <= cycle + 1;
    if_pc_q <= if_pc;
    if_req_q <= if_req;
    first <= first & !if_req;
    if (|wb_valid)
      trace_wb(wb_pc);
    if (load_wb_valid)
      trace_loadwb();
    if (ex_valid) begin
      if (lsu_nonblock_load_valid) begin
        trace_load(ex_pc);
      end else begin
        trace_ex(ex_pc);
      end
    end
    if (de_valid)
      trace_de(de_pc, de_insn);
    if (if_req && (!if_req_q || (if_req_q && (if_pc != if_pc_q))))
      trace_if(if_pc);

    if (de_valid && (de_insn == 32'h00002013)) next_is_finish = 1;
    if (|wb_valid && next_is_finish) $finish();
  end
endmodule
