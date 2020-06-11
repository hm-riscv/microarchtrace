// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
module swerv_el2_bind;
  bind el2_swerv swerv_el2_microarchtrace u_bind(
    .clk (clk),
    .if_req (rvtop.swerv.ifu.ifc_fetch_req_bf),
    .if_pc ({rvtop.swerv.ifu.ifc_fetch_addr_bf, 1'b0}),
    .de_valid (rvtop.swerv.dec.dec_i0_decode_d),
    .de_pc ({rvtop.swerv.dec.dec_i0_pc_d, 1'b0}),
    .de_insn (rvtop.swerv.dec.dec_i0_instr_d),
    .de_compact (~rvtop.swerv.dec.dec_i0_pc4_d),
    .ex_valid (rvtop.swerv.dec.decode.i0_pipe_en[2]),
    .ex_pc ({rvtop.swerv.dec.exu_i0_pc_x,1'b0}),
    .wb_valid (rv_trace_pkt.rv_i_valid_ip),
    .wb_pc (rv_trace_pkt.rv_i_address_ip)
  );
endmodule
