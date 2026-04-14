// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VTB_REGISTER_FILE_H_
#define _VTB_REGISTER_FILE_H_  // guard

#include "verilated_heavy.h"

//==========

class Vtb_register_file__Syms;
class Vtb_register_file_VerilatedVcd;


//----------

VL_MODULE(Vtb_register_file) {
  public:
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*0:0*/ tb_register_file__DOT__rst_n;
    CData/*4:0*/ tb_register_file__DOT__rs1_addr;
    CData/*4:0*/ tb_register_file__DOT__rs2_addr;
    CData/*4:0*/ tb_register_file__DOT__rd_addr;
    CData/*0:0*/ tb_register_file__DOT__wen;
    CData/*0:0*/ tb_register_file__DOT__init_done;
    IData/*31:0*/ tb_register_file__DOT__rs1_rdata;
    IData/*31:0*/ tb_register_file__DOT__rs2_rdata;
    IData/*31:0*/ tb_register_file__DOT__rd_wdata;
    IData/*31:0*/ tb_register_file__DOT__test_idx;
    IData/*31:0*/ tb_register_file__DOT__pass_cnt;
    IData/*31:0*/ tb_register_file__DOT__fail_cnt;
    IData/*31:0*/ tb_register_file__DOT__dut__DOT__unnamedblk1__DOT__i;
    CData/*0:0*/ tb_register_file__DOT__tv_rst_n[13];
    CData/*4:0*/ tb_register_file__DOT__tv_rs1_addr[13];
    CData/*4:0*/ tb_register_file__DOT__tv_rs2_addr[13];
    CData/*4:0*/ tb_register_file__DOT__tv_rd_addr[13];
    IData/*31:0*/ tb_register_file__DOT__tv_rd_wdata[13];
    CData/*0:0*/ tb_register_file__DOT__tv_wen[13];
    IData/*31:0*/ tb_register_file__DOT__tv_rs1_exp[13];
    IData/*31:0*/ tb_register_file__DOT__tv_rs2_exp[13];
    CData/*0:0*/ tb_register_file__DOT__tv_neg_chk[13];
    IData/*31:0*/ tb_register_file__DOT__dut__DOT__reg_file[32];
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ __Vclklast__TOP__clk;
    CData/*0:0*/ __Vm_traceActivity[3];
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vtb_register_file__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vtb_register_file);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vtb_register_file(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vtb_register_file();
    /// Trace signals in the model; called by application code
    void trace(VerilatedVcdC* tfp, int levels, int options = 0);
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vtb_register_file__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vtb_register_file__Syms* symsp, bool first);
  private:
    static QData _change_request(Vtb_register_file__Syms* __restrict vlSymsp);
    static QData _change_request_1(Vtb_register_file__Syms* __restrict vlSymsp);
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vtb_register_file__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vtb_register_file__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vtb_register_file__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _initial__TOP__3(Vtb_register_file__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _multiclk__TOP__4(Vtb_register_file__Syms* __restrict vlSymsp);
    static void _sequent__TOP__1(Vtb_register_file__Syms* __restrict vlSymsp);
    static void _sequent__TOP__2(Vtb_register_file__Syms* __restrict vlSymsp);
  private:
    static void traceChgSub0(void* userp, VerilatedVcd* tracep);
    static void traceChgTop0(void* userp, VerilatedVcd* tracep);
    static void traceCleanup(void* userp, VerilatedVcd* /*unused*/);
    static void traceFullSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceFullTop0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitTop(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    void traceRegister(VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
