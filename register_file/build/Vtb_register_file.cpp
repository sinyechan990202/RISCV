// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_register_file.h for the primary calling header

#include "Vtb_register_file.h"
#include "Vtb_register_file__Syms.h"

//==========

void Vtb_register_file::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_register_file::eval\n"); );
    Vtb_register_file__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("testbench/tb_register_file.sv", 28, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vtb_register_file::_eval_initial_loop(Vtb_register_file__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("testbench/tb_register_file.sv", 28, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vtb_register_file::_sequent__TOP__1(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_sequent__TOP__1\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    CData/*0:0*/ __Vtask_tb_register_file__DOT__check_result__0__mismatch;
    IData/*31:0*/ __Vtask_tb_register_file__DOT__check_result__0__idx;
    std::string __Vtask_tb_register_file__DOT__check_result__0__phase_str;
    // Body
    vlTOPp->tb_register_file__DOT__init_done = 1U;
    if (VL_GTS_III(1,32,32, 0xdU, vlTOPp->tb_register_file__DOT__test_idx)) {
        if (((0xcU >= (0xfU & vlTOPp->tb_register_file__DOT__test_idx)) 
             & vlTOPp->tb_register_file__DOT__tv_neg_chk
             [(0xfU & vlTOPp->tb_register_file__DOT__test_idx)])) {
            __Vtask_tb_register_file__DOT__check_result__0__idx 
                = vlTOPp->tb_register_file__DOT__test_idx;
            __Vtask_tb_register_file__DOT__check_result__0__phase_str = 
                std::string("negedge");
            __Vtask_tb_register_file__DOT__check_result__0__mismatch 
                = ((vlTOPp->tb_register_file__DOT__rs1_rdata 
                    != ((0xcU >= (0xfU & __Vtask_tb_register_file__DOT__check_result__0__idx))
                         ? vlTOPp->tb_register_file__DOT__tv_rs1_exp
                        [(0xfU & __Vtask_tb_register_file__DOT__check_result__0__idx)]
                         : 0U)) | (vlTOPp->tb_register_file__DOT__rs2_rdata 
                                   != ((0xcU >= (0xfU 
                                                 & __Vtask_tb_register_file__DOT__check_result__0__idx))
                                        ? vlTOPp->tb_register_file__DOT__tv_rs2_exp
                                       [(0xfU & __Vtask_tb_register_file__DOT__check_result__0__idx)]
                                        : 0U)));
            if (VL_UNLIKELY(__Vtask_tb_register_file__DOT__check_result__0__mismatch)) {
                VL_WRITEF("[%0t] %%Error: tb_register_file.sv:273: Assertion failed in %Ntb_register_file: [FAIL] test[%02d] @%@ | rs1:0x%08x(exp:0x%08x)  rs2:0x%08x(exp:0x%08x)\n",
                          64,VL_TIME_UNITED_Q(1000),
                          vlSymsp->name(),32,__Vtask_tb_register_file__DOT__check_result__0__idx,
                          64,&(__Vtask_tb_register_file__DOT__check_result__0__phase_str),
                          32,vlTOPp->tb_register_file__DOT__rs1_rdata,
                          32,((0xcU >= (0xfU & __Vtask_tb_register_file__DOT__check_result__0__idx))
                               ? vlTOPp->tb_register_file__DOT__tv_rs1_exp
                              [(0xfU & __Vtask_tb_register_file__DOT__check_result__0__idx)]
                               : 0U),32,vlTOPp->tb_register_file__DOT__rs2_rdata,
                          32,((0xcU >= (0xfU & __Vtask_tb_register_file__DOT__check_result__0__idx))
                               ? vlTOPp->tb_register_file__DOT__tv_rs2_exp
                              [(0xfU & __Vtask_tb_register_file__DOT__check_result__0__idx)]
                               : 0U));
                vlTOPp->tb_register_file__DOT__fail_cnt 
                    = ((IData)(1U) + vlTOPp->tb_register_file__DOT__fail_cnt);
                VL_STOP_MT("testbench/tb_register_file.sv", 273, "");
            } else {
                VL_WRITEF("[PASS] test[%02d] @%@ | rs1=0x%08x  rs2=0x%08x\n",
                          32,__Vtask_tb_register_file__DOT__check_result__0__idx,
                          64,&(__Vtask_tb_register_file__DOT__check_result__0__phase_str),
                          32,vlTOPp->tb_register_file__DOT__rs1_rdata,
                          32,vlTOPp->tb_register_file__DOT__rs2_rdata);
                vlTOPp->tb_register_file__DOT__pass_cnt 
                    = ((IData)(1U) + vlTOPp->tb_register_file__DOT__pass_cnt);
            }
        }
        vlTOPp->tb_register_file__DOT__rst_n = ((0xcU 
                                                 >= 
                                                 (0xfU 
                                                  & vlTOPp->tb_register_file__DOT__test_idx)) 
                                                & vlTOPp->tb_register_file__DOT__tv_rst_n
                                                [(0xfU 
                                                  & vlTOPp->tb_register_file__DOT__test_idx)]);
        if ((0xcU >= (0xfU & vlTOPp->tb_register_file__DOT__test_idx))) {
            vlTOPp->tb_register_file__DOT__rs1_addr 
                = vlTOPp->tb_register_file__DOT__tv_rs1_addr
                [(0xfU & vlTOPp->tb_register_file__DOT__test_idx)];
            vlTOPp->tb_register_file__DOT__rs2_addr 
                = vlTOPp->tb_register_file__DOT__tv_rs2_addr
                [(0xfU & vlTOPp->tb_register_file__DOT__test_idx)];
            vlTOPp->tb_register_file__DOT__rd_addr 
                = vlTOPp->tb_register_file__DOT__tv_rd_addr
                [(0xfU & vlTOPp->tb_register_file__DOT__test_idx)];
            vlTOPp->tb_register_file__DOT__rd_wdata 
                = vlTOPp->tb_register_file__DOT__tv_rd_wdata
                [(0xfU & vlTOPp->tb_register_file__DOT__test_idx)];
            vlTOPp->tb_register_file__DOT__wen = (vlTOPp->tb_register_file__DOT__tv_wen
                                                  [
                                                  (0xfU 
                                                   & vlTOPp->tb_register_file__DOT__test_idx)] 
                                                  & 1U);
        } else {
            vlTOPp->tb_register_file__DOT__rs1_addr = 0U;
            vlTOPp->tb_register_file__DOT__rs2_addr = 0U;
            vlTOPp->tb_register_file__DOT__rd_addr = 0U;
            vlTOPp->tb_register_file__DOT__rd_wdata = 0U;
            vlTOPp->tb_register_file__DOT__wen = 0U;
        }
    }
}

VL_INLINE_OPT void Vtb_register_file::_sequent__TOP__2(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_sequent__TOP__2\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    CData/*0:0*/ __Vtask_tb_register_file__DOT__check_result__1__mismatch;
    CData/*4:0*/ __Vdlyvdim0__tb_register_file__DOT__dut__DOT__reg_file__v0;
    CData/*0:0*/ __Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v0;
    CData/*0:0*/ __Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v1;
    IData/*31:0*/ __Vtask_tb_register_file__DOT__check_result__1__idx;
    IData/*31:0*/ __Vdlyvval__tb_register_file__DOT__dut__DOT__reg_file__v0;
    std::string __Vtask_tb_register_file__DOT__check_result__1__phase_str;
    // Body
    if ((1U & (~ (IData)(vlTOPp->tb_register_file__DOT__rst_n)))) {
        vlTOPp->tb_register_file__DOT__dut__DOT__unnamedblk1__DOT__i = 0x20U;
    }
    if (vlTOPp->tb_register_file__DOT__init_done) {
        if (VL_GTS_III(1,32,32, 0xdU, vlTOPp->tb_register_file__DOT__test_idx)) {
            if ((1U & (~ ((0xcU >= (0xfU & vlTOPp->tb_register_file__DOT__test_idx)) 
                          & vlTOPp->tb_register_file__DOT__tv_neg_chk
                          [(0xfU & vlTOPp->tb_register_file__DOT__test_idx)])))) {
                __Vtask_tb_register_file__DOT__check_result__1__idx 
                    = vlTOPp->tb_register_file__DOT__test_idx;
                __Vtask_tb_register_file__DOT__check_result__1__phase_str = 
                    std::string("posedge");
                __Vtask_tb_register_file__DOT__check_result__1__mismatch 
                    = ((vlTOPp->tb_register_file__DOT__rs1_rdata 
                        != ((0xcU >= (0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx))
                             ? vlTOPp->tb_register_file__DOT__tv_rs1_exp
                            [(0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx)]
                             : 0U)) | (vlTOPp->tb_register_file__DOT__rs2_rdata 
                                       != ((0xcU >= 
                                            (0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx))
                                            ? vlTOPp->tb_register_file__DOT__tv_rs2_exp
                                           [(0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx)]
                                            : 0U)));
                if (VL_UNLIKELY(__Vtask_tb_register_file__DOT__check_result__1__mismatch)) {
                    VL_WRITEF("[%0t] %%Error: tb_register_file.sv:273: Assertion failed in %Ntb_register_file: [FAIL] test[%02d] @%@ | rs1:0x%08x(exp:0x%08x)  rs2:0x%08x(exp:0x%08x)\n",
                              64,VL_TIME_UNITED_Q(1000),
                              vlSymsp->name(),32,__Vtask_tb_register_file__DOT__check_result__1__idx,
                              64,&(__Vtask_tb_register_file__DOT__check_result__1__phase_str),
                              32,vlTOPp->tb_register_file__DOT__rs1_rdata,
                              32,((0xcU >= (0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx))
                                   ? vlTOPp->tb_register_file__DOT__tv_rs1_exp
                                  [(0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx)]
                                   : 0U),32,vlTOPp->tb_register_file__DOT__rs2_rdata,
                              32,((0xcU >= (0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx))
                                   ? vlTOPp->tb_register_file__DOT__tv_rs2_exp
                                  [(0xfU & __Vtask_tb_register_file__DOT__check_result__1__idx)]
                                   : 0U));
                    vlTOPp->tb_register_file__DOT__fail_cnt 
                        = ((IData)(1U) + vlTOPp->tb_register_file__DOT__fail_cnt);
                    VL_STOP_MT("testbench/tb_register_file.sv", 273, "");
                } else {
                    VL_WRITEF("[PASS] test[%02d] @%@ | rs1=0x%08x  rs2=0x%08x\n",
                              32,__Vtask_tb_register_file__DOT__check_result__1__idx,
                              64,&(__Vtask_tb_register_file__DOT__check_result__1__phase_str),
                              32,vlTOPp->tb_register_file__DOT__rs1_rdata,
                              32,vlTOPp->tb_register_file__DOT__rs2_rdata);
                    vlTOPp->tb_register_file__DOT__pass_cnt 
                        = ((IData)(1U) + vlTOPp->tb_register_file__DOT__pass_cnt);
                }
            }
            vlTOPp->tb_register_file__DOT__test_idx 
                = ((IData)(1U) + vlTOPp->tb_register_file__DOT__test_idx);
        } else {
            if (VL_UNLIKELY(vlTOPp->tb_register_file__DOT__init_done)) {
                VL_WRITEF("========================================\n");
                VL_WRITEF(" RESULT : PASS=%0d  FAIL=%0d  TOTAL=%0d\n",
                          32,vlTOPp->tb_register_file__DOT__pass_cnt,
                          32,vlTOPp->tb_register_file__DOT__fail_cnt,
                          32,(vlTOPp->tb_register_file__DOT__pass_cnt 
                              + vlTOPp->tb_register_file__DOT__fail_cnt));
                if ((0U == vlTOPp->tb_register_file__DOT__fail_cnt)) {
                    VL_WRITEF(" ALL TESTS PASSED\n");
                } else {
                    VL_WRITEF(" *** %0d TEST(S) FAILED ***\n",
                              32,vlTOPp->tb_register_file__DOT__fail_cnt);
                }
                VL_WRITEF("========================================\n");
                VL_FINISH_MT("testbench/tb_register_file.sv", 331, "");
            }
        }
    }
    __Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v0 = 0U;
    __Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v1 = 0U;
    if (vlTOPp->tb_register_file__DOT__rst_n) {
        if (((IData)(vlTOPp->tb_register_file__DOT__wen) 
             & (0U != (IData)(vlTOPp->tb_register_file__DOT__rd_addr)))) {
            __Vdlyvval__tb_register_file__DOT__dut__DOT__reg_file__v0 
                = vlTOPp->tb_register_file__DOT__rd_wdata;
            __Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v0 = 1U;
            __Vdlyvdim0__tb_register_file__DOT__dut__DOT__reg_file__v0 
                = vlTOPp->tb_register_file__DOT__rd_addr;
        }
    } else {
        __Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v1 = 1U;
    }
    if (__Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v0) {
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[__Vdlyvdim0__tb_register_file__DOT__dut__DOT__reg_file__v0] 
            = __Vdlyvval__tb_register_file__DOT__dut__DOT__reg_file__v0;
    }
    if (__Vdlyvset__tb_register_file__DOT__dut__DOT__reg_file__v1) {
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[1U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[2U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[3U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[4U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[5U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[6U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[7U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[8U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[9U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0xaU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0xbU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0xcU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0xdU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0xeU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0xfU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x10U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x11U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x12U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x13U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x14U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x15U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x16U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x17U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x18U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x19U] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x1aU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x1bU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x1cU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x1dU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x1eU] = 0U;
        vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0x1fU] = 0U;
    }
}

VL_INLINE_OPT void Vtb_register_file::_multiclk__TOP__4(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_multiclk__TOP__4\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->tb_register_file__DOT__rs1_rdata = ((((IData)(vlTOPp->tb_register_file__DOT__wen) 
                                                  & ((IData)(vlTOPp->tb_register_file__DOT__rs1_addr) 
                                                     == (IData)(vlTOPp->tb_register_file__DOT__rd_addr))) 
                                                 & (0U 
                                                    != (IData)(vlTOPp->tb_register_file__DOT__rs1_addr)))
                                                 ? vlTOPp->tb_register_file__DOT__rd_wdata
                                                 : 
                                                vlTOPp->tb_register_file__DOT__dut__DOT__reg_file
                                                [vlTOPp->tb_register_file__DOT__rs1_addr]);
    vlTOPp->tb_register_file__DOT__rs2_rdata = ((((IData)(vlTOPp->tb_register_file__DOT__wen) 
                                                  & ((IData)(vlTOPp->tb_register_file__DOT__rs2_addr) 
                                                     == (IData)(vlTOPp->tb_register_file__DOT__rd_addr))) 
                                                 & (0U 
                                                    != (IData)(vlTOPp->tb_register_file__DOT__rs2_addr)))
                                                 ? vlTOPp->tb_register_file__DOT__rd_wdata
                                                 : 
                                                vlTOPp->tb_register_file__DOT__dut__DOT__reg_file
                                                [vlTOPp->tb_register_file__DOT__rs2_addr]);
}

void Vtb_register_file::_eval(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_eval\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((~ (IData)(vlTOPp->clk)) & (IData)(vlTOPp->__Vclklast__TOP__clk))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
        vlTOPp->__Vm_traceActivity[1U] = 1U;
    }
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
        vlTOPp->_sequent__TOP__2(vlSymsp);
        vlTOPp->__Vm_traceActivity[2U] = 1U;
    }
    if (((IData)(vlTOPp->clk) ^ (IData)(vlTOPp->__Vclklast__TOP__clk))) {
        vlTOPp->_multiclk__TOP__4(vlSymsp);
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

VL_INLINE_OPT QData Vtb_register_file::_change_request(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_change_request\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Vtb_register_file::_change_request_1(Vtb_register_file__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_change_request_1\n"); );
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vtb_register_file::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_register_file::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
}
#endif  // VL_DEBUG
