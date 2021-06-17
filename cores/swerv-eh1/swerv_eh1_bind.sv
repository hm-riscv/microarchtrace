// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module swerv_eh1_bind;
  bind tb_top swerv_eh1_microarchtrace u_bind(
    .clk(core_clk),
    .fe1_valid0(0),
    .fe1_valid1(0),
    .fe2_valid0(0),
    .fe2_valid1(0),
    .aln_valid0(tb_top.rvtop.swerv.ifu.aln.ifu_i0_valid),
    .aln_valid1(tb_top.rvtop.swerv.ifu.aln.ifu_i1_valid),
    .aln_pc0({tb_top.rvtop.swerv.ifu.aln.ifu_i0_pc,1'b0}),
    .aln_pc1({tb_top.rvtop.swerv.ifu.aln.ifu_i1_pc,1'b0}),
    .dec_valid0(tb_top.rvtop.swerv.dec.dec_i0_decode_d),
    .dec_valid1(tb_top.rvtop.swerv.dec.dec_i1_decode_d),
    .dec_pc0({tb_top.rvtop.swerv.dec.dec_i0_pc_d,1'b0}),
    .dec_pc1({tb_top.rvtop.swerv.dec.dec_i1_pc_d,1'b0}),
    .dec_insn0(tb_top.rvtop.swerv.dec.dec_i0_instr_d),
    .dec_insn1(tb_top.rvtop.swerv.dec.dec_i1_instr_d),
    .ex1_valid0(tb_top.rvtop.swerv.dec.decode.i0_e1_ctl_en),
    .ex1_valid1(tb_top.rvtop.swerv.dec.decode.i1_e1_ctl_en),
    .ex1_pc0({tb_top.rvtop.swerv.dec.decode.i0_pc_e1,1'b0}),
    .ex1_pc1({tb_top.rvtop.swerv.dec.decode.i1_pc_e1,1'b0}),
    .ex2_valid0(tb_top.rvtop.swerv.dec.decode.i0_e2_ctl_en),
    .ex2_valid1(tb_top.rvtop.swerv.dec.decode.i1_e2_ctl_en),
    .ex2_pc0({tb_top.rvtop.swerv.dec.decode.i0_pc_e2,1'b0}),
    .ex2_pc1({tb_top.rvtop.swerv.dec.decode.i1_pc_e2,1'b0}),
    .ex3_valid0(tb_top.rvtop.swerv.dec.decode.i0_e3_ctl_en),
    .ex3_valid1(tb_top.rvtop.swerv.dec.decode.i1_e3_ctl_en),
    .ex3_pc0({tb_top.rvtop.swerv.dec.decode.i0_pc_e3,1'b0}),
    .ex3_pc1({tb_top.rvtop.swerv.dec.decode.i1_pc_e3,1'b0}),
    .commit_valid0(tb_top.rvtop.swerv.dec.decode.i0_e4_ctl_en),
    .commit_valid1(tb_top.rvtop.swerv.dec.decode.i1_e4_ctl_en),
    .commit_pc0({tb_top.rvtop.swerv.dec.decode.i0_pc_e4,1'b0}),
    .commit_pc1({tb_top.rvtop.swerv.dec.decode.i1_pc_e4,1'b0}),
    .wb_valid0(tb_top.rvtop.swerv.dec.dec_tlu_i0_valid_wb1),
    .wb_valid1(tb_top.rvtop.swerv.dec.dec_tlu_i1_valid_wb1),
    .wb_pc0({tb_top.rvtop.swerv.dec.dec_i0_pc_wb1,1'b0}),
    .wb_pc1({tb_top.rvtop.swerv.dec.dec_i1_pc_wb1,1'b0})
  );
endmodule
