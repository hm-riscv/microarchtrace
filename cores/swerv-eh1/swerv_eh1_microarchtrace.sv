// Copyright Munich University of Applied Sciences.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

import "DPI-C" function void trace_init();
import "DPI-C" function void trace_aln(int pc);
import "DPI-C" function void trace_dec(int pc);
import "DPI-C" function void trace_ex1(int pc);
import "DPI-C" function void trace_ex2(int pc);
import "DPI-C" function void trace_ex3(int pc);
import "DPI-C" function void trace_commit(int pc);
import "DPI-C" function void trace_wb(int pc);

module swerv_eh1_microarchtrace(
    input clk,

    // Fetch
    input fe1_valid0,
    input fe1_valid1,
    input fe2_valid0,
    input fe2_valid1,
    input aln_valid0,
    input [31:0] aln_pc0,
    input aln_valid1,
    input [31:0] aln_pc1,
    // Decode
    input dec_valid0,
    input [31:0] dec_pc0,
    input dec_valid1,
    input [31:0] dec_pc1,
    // Execute
    input ex1_valid0,
    input [31:0] ex1_pc0,
    input ex1_valid1,
    input [31:0] ex1_pc1,
    input ex2_valid0,
    input [31:0] ex2_pc0,
    input ex2_valid1,
    input [31:0] ex2_pc1,
    input ex3_valid0,
    input [31:0] ex3_pc0,
    input ex3_valid1,
    input [31:0] ex3_pc1,
    // Commit
    input commit_valid0,
    input [31:0] commit_pc0,
    input commit_valid1,
    input [31:0] commit_pc1,
    // Writeback
    input wb_valid0,
    input [31:0] wb_pc0,
    input wb_valid1,
    input [31:0] wb_pc1
);

    initial begin
        trace_init();
    end

    always @(negedge clk) begin
        // Writeback
        if (wb_valid0) trace_wb(wb_pc0);
        if (wb_valid1) trace_wb(wb_pc1);
        if (commit_valid0) trace_commit(commit_pc0);
        if (commit_valid1) trace_commit(commit_pc1);
        // Execute
        if (ex1_valid0) trace_ex1(ex1_pc0);
        if (ex1_valid1) trace_ex1(ex1_pc1);
        if (ex2_valid0) trace_ex2(ex2_pc0);
        if (ex2_valid1) trace_ex2(ex2_pc1);
        if (ex3_valid0) trace_ex3(ex3_pc0);
        if (ex3_valid1) trace_ex3(ex3_pc1);
        // Decode
        if (dec_valid0) trace_dec(dec_pc0);
        if (dec_valid1) trace_dec(dec_pc1);
        // Fetch
        if (aln_valid0) trace_aln(aln_pc0);
        if (aln_valid1) trace_aln(aln_pc1);
    end

endmodule
