// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

import "DPI-C" function void trace_init();
import "DPI-C" function void trace_if(int pc, int insn, logic c, shortint c_insn);
import "DPI-C" function void trace_if_start();
import "DPI-C" function void trace_if_end(int pc, int insn, logic c, shortint c_insn);
import "DPI-C" function void trace_idex(int pc);
import "DPI-C" function void trace_idex_mult_end(int pc);

module ibex_microarchtrace (
  input clk,
  input rst_n,
  input fetch_ready,
  input fetch_valid,
  input [31:0] fetch_pc,
  input [31:0] fetch_insn,
  input fetch_c,
  input [15:0] fetch_c_insn,
  input idex_executing,
  input idex_done,
  input [31:0] idex_pc
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
    fetch_ready_q <= fetch_ready;
    fetch_valid_q <= fetch_valid;
    idex_executing_q <= idex_executing;
    idex_done_q <= idex_done;

    if (active) begin
      if (fetch_ready) begin
        if (fetch_valid) begin
          // Single cycle fetch
          if (!fetch_ready_q || (fetch_ready_q && fetch_valid_q))
            trace_if(fetch_pc, fetch_insn, fetch_c, fetch_c_insn);
          // End multicycle fetch
          if (fetch_ready_q && !fetch_valid_q)
            trace_if_end(fetch_pc, fetch_insn, fetch_c, fetch_c_insn);
        end else begin
          if (!fetch_ready_q || (fetch_ready_q && fetch_valid_q))
            trace_if_start();
        end
      end

      if (idex_executing) begin
        if (idex_done) begin
          if (idex_multicycle)
            trace_idex_mult_end(idex_pc);
          else
            trace_idex(idex_pc);
        end else if (!idex_multicycle)
            trace_idex(idex_pc);
      end
    end
  end
endmodule

module ibex_bind;
  bind ibex_simple_system ibex_microarchtrace u_bind(
    .clk (IO_CLK),
    .rst_n (IO_RST_N),
    .fetch_ready (u_core.u_ibex_core.if_stage_i.fetch_ready),
    .fetch_valid (u_core.u_ibex_core.if_stage_i.fetch_valid),
    .fetch_pc  (u_core.u_ibex_core.if_stage_i.pc_if_o),
    .fetch_insn (u_core.u_ibex_core.if_stage_i.instr_out),
    .fetch_c   (u_core.u_ibex_core.if_stage_i.instr_is_compressed_out),
    .fetch_c_insn (u_core.u_ibex_core.if_stage_i.fetch_rdata[15:0]),
    .idex_executing (u_core.u_ibex_core.id_stage_i.instr_executing),
    .idex_done (u_core.u_ibex_core.id_stage_i.instr_done),
    .idex_pc (u_core.u_ibex_core.id_stage_i.pc_id_i)
  );
endmodule
