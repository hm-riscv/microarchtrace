// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

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
