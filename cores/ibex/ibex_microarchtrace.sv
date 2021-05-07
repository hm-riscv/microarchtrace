// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

import "DPI-C" function void trace_init();
import "DPI-C" function void trace_if(int pc, int insn, byte mode, logic c, shortint c_insn);
import "DPI-C" function void trace_if_start();
import "DPI-C" function void trace_if_end(int pc, int insn, byte mode, logic c, shortint c_insn);
import "DPI-C" function void trace_idex(int pc);
import "DPI-C" function void trace_wb(int pc);
import "DPI-C" function void trace_done(int pc);

module ibex_microarchtrace (
  input clk,
  input rst_n,
  input fetch_ready,
  input fetch_valid,
  input [31:0] fetch_pc,
  input [1:0] fetch_mode,
  input [31:0] fetch_insn,
  input fetch_c,
  input [15:0] fetch_c_insn,
  input idex_executing,
  input idex_done,
  input [31:0] idex_pc,
  input wb_en,
  input wb_done,
  input [31:0] wb_pc
);
  reg active;
  reg rst_n_q;
  reg fetch_ready_q, fetch_valid_q;
  reg idex_executing_q, idex_done_q;
  wire idex_multicycle;

  initial begin
    active = 0;
    rst_n_q = 1;
    trace_init();
  end

  always @(posedge clk) begin
    rst_n_q <= rst_n;
    if (rst_n && !rst_n_q)
      active <= 1;
  end

  assign idex_multicycle = idex_executing_q && !idex_done_q;

  always @(posedge clk) begin
    if (active) begin
      fetch_ready_q <= fetch_ready;
      fetch_valid_q <= fetch_valid;
      idex_executing_q <= idex_executing;
      idex_done_q <= idex_done;

      if (wb_en)
        trace_wb(wb_pc);
      if (wb_done)
        trace_done(wb_pc);

      if (idex_executing) begin
        if (idex_done) begin
          if (!idex_multicycle)
            trace_idex(idex_pc);
          trace_done(idex_pc);
        end else if (!idex_multicycle)
            trace_idex(idex_pc);
      end

      if (fetch_ready) begin
        if (fetch_valid) begin
          // Single cycle fetch
          if (!fetch_ready_q || (fetch_ready_q && fetch_valid_q))
            trace_if(fetch_pc, fetch_insn, byte'(fetch_mode), fetch_c, fetch_c_insn);
          // End multicycle fetch
          if (fetch_ready_q && !fetch_valid_q)
            trace_if_end(fetch_pc, fetch_insn, byte'(fetch_mode), fetch_c, fetch_c_insn);
        end else begin
          if (!fetch_ready_q || (fetch_ready_q && fetch_valid_q))
            trace_if_start();
        end
      end
    end
  end
endmodule

