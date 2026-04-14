// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_register_file.h for the primary calling header

#include "Vtb_register_file.h"
#include "Vtb_register_file__Syms.h"

//==========

VL_CTOR_IMP(Vtb_register_file) {
    Vtb_register_file__Syms* __restrict vlSymsp = __VlSymsp = new Vtb_register_file__Syms(this, name());
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vtb_register_file::__Vconfigure(Vtb_register_file__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-9);
    Verilated::timeprecision(-12);
}

Vtb_register_file::~Vtb_register_file() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = NULL);
}

void Vtb_register_file::_initial__TOP__3(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_initial__TOP__3\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->tb_register_file__DOT__init_done = 0U;
    vlTOPp->tb_register_file__DOT__rst_n = 1U;
    vlTOPp->tb_register_file__DOT__rs1_addr = 0U;
    vlTOPp->tb_register_file__DOT__rs2_addr = 0U;
    vlTOPp->tb_register_file__DOT__rd_addr = 0U;
    vlTOPp->tb_register_file__DOT__rd_wdata = 0U;
    vlTOPp->tb_register_file__DOT__wen = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[0U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[0U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[0U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[0U] = 2U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[0U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[0U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[0U] = 0xdeadbeefU;
    vlTOPp->tb_register_file__DOT__tv_wen[0U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[0U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[1U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[1U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[1U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[1U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[1U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[1U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[1U] = 0xffffffffU;
    vlTOPp->tb_register_file__DOT__tv_wen[1U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[1U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[2U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[2U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[2U] = 0xabcd1234U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[2U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[2U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[2U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[2U] = 0xabcd1234U;
    vlTOPp->tb_register_file__DOT__tv_wen[2U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[2U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[3U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[3U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[3U] = 0xabcd1234U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[3U] = 2U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[3U] = 0x5555aaaaU;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[3U] = 2U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[3U] = 0x5555aaaaU;
    vlTOPp->tb_register_file__DOT__tv_wen[3U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[3U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[4U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[4U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[4U] = 0xabcd1234U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[4U] = 2U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[4U] = 0x5555aaaaU;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[4U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[4U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_wen[4U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[4U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[5U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[5U] = 3U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[5U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[5U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[5U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[5U] = 3U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[5U] = 0xcafebabeU;
    vlTOPp->tb_register_file__DOT__tv_wen[5U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[5U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[6U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[6U] = 3U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[6U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[6U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[6U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[6U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[6U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_wen[6U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[6U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[7U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[7U] = 5U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[7U] = 0x12345678U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[7U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[7U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[7U] = 5U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[7U] = 0x12345678U;
    vlTOPp->tb_register_file__DOT__tv_wen[7U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[7U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[8U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[8U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[8U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[8U] = 6U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[8U] = 0xfedcba98U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[8U] = 6U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[8U] = 0xfedcba98U;
    vlTOPp->tb_register_file__DOT__tv_wen[8U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[8U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[9U] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[9U] = 5U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[9U] = 0x12345678U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[9U] = 6U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[9U] = 0xfedcba98U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[9U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[9U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_wen[9U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[9U] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[0xaU] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[0xaU] = 0x1fU;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[0xaU] = 0xffff0000U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[0xaU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[0xaU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[0xaU] = 0x1fU;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[0xaU] = 0xffff0000U;
    vlTOPp->tb_register_file__DOT__tv_wen[0xaU] = 1U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[0xaU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_wen[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[0xbU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rst_n[0xcU] = 1U;
    vlTOPp->tb_register_file__DOT__tv_rs1_addr[0xcU] = 0x1fU;
    vlTOPp->tb_register_file__DOT__tv_rs1_exp[0xcU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rs2_addr[0xcU] = 5U;
    vlTOPp->tb_register_file__DOT__tv_rs2_exp[0xcU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_addr[0xcU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_rd_wdata[0xcU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_wen[0xcU] = 0U;
    vlTOPp->tb_register_file__DOT__tv_neg_chk[0xcU] = 0U;
}

void Vtb_register_file::_eval_initial(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_eval_initial\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
    vlTOPp->_initial__TOP__3(vlSymsp);
    vlTOPp->__Vm_traceActivity[2U] = 1U;
    vlTOPp->__Vm_traceActivity[1U] = 1U;
    vlTOPp->__Vm_traceActivity[0U] = 1U;
}

void Vtb_register_file::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::final\n"); );
    // Variables
    Vtb_register_file__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vtb_register_file::_eval_settle(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_eval_settle\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_multiclk__TOP__4(vlSymsp);
}

void Vtb_register_file::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    tb_register_file__DOT__rst_n = VL_RAND_RESET_I(1);
    tb_register_file__DOT__rs1_addr = VL_RAND_RESET_I(5);
    tb_register_file__DOT__rs2_addr = VL_RAND_RESET_I(5);
    tb_register_file__DOT__rs1_rdata = VL_RAND_RESET_I(32);
    tb_register_file__DOT__rs2_rdata = VL_RAND_RESET_I(32);
    tb_register_file__DOT__rd_addr = VL_RAND_RESET_I(5);
    tb_register_file__DOT__rd_wdata = VL_RAND_RESET_I(32);
    tb_register_file__DOT__wen = VL_RAND_RESET_I(1);
    tb_register_file__DOT__init_done = VL_RAND_RESET_I(1);
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_rst_n[__Vi0] = VL_RAND_RESET_I(1);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_rs1_addr[__Vi0] = VL_RAND_RESET_I(5);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_rs2_addr[__Vi0] = VL_RAND_RESET_I(5);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_rd_addr[__Vi0] = VL_RAND_RESET_I(5);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_rd_wdata[__Vi0] = VL_RAND_RESET_I(32);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_wen[__Vi0] = VL_RAND_RESET_I(1);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_rs1_exp[__Vi0] = VL_RAND_RESET_I(32);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_rs2_exp[__Vi0] = VL_RAND_RESET_I(32);
    }}
    { int __Vi0=0; for (; __Vi0<13; ++__Vi0) {
            tb_register_file__DOT__tv_neg_chk[__Vi0] = VL_RAND_RESET_I(1);
    }}
    tb_register_file__DOT__test_idx = 0;
    tb_register_file__DOT__pass_cnt = 0;
    tb_register_file__DOT__fail_cnt = 0;
    { int __Vi0=0; for (; __Vi0<32; ++__Vi0) {
            tb_register_file__DOT__dut__DOT__reg_file[__Vi0] = VL_RAND_RESET_I(32);
    }}
    tb_register_file__DOT__dut__DOT__unnamedblk1__DOT__i = 0;
    { int __Vi0=0; for (; __Vi0<3; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
