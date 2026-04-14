// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_register_file__Syms.h"


//======================

void Vtb_register_file::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vtb_register_file::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vtb_register_file::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vtb_register_file::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vtb_register_file::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+159,"clk", false,-1);
        tracep->declBit(c+159,"tb_register_file clk", false,-1);
        tracep->declBit(c+118,"tb_register_file rst_n", false,-1);
        tracep->declBus(c+119,"tb_register_file rs1_addr", false,-1, 4,0);
        tracep->declBus(c+120,"tb_register_file rs2_addr", false,-1, 4,0);
        tracep->declBus(c+160,"tb_register_file rs1_rdata", false,-1, 31,0);
        tracep->declBus(c+161,"tb_register_file rs2_rdata", false,-1, 31,0);
        tracep->declBus(c+121,"tb_register_file rd_addr", false,-1, 4,0);
        tracep->declBus(c+122,"tb_register_file rd_wdata", false,-1, 31,0);
        tracep->declBit(c+123,"tb_register_file wen", false,-1);
        tracep->declBit(c+124,"tb_register_file init_done", false,-1);
        tracep->declBus(c+164,"tb_register_file NUM_TESTS", false,-1, 31,0);
        {int i; for (i=0; i<13; i++) {
                tracep->declBit(c+1+i*1,"tb_register_file tv_rst_n", true,(i+0));}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBus(c+14+i*1,"tb_register_file tv_rs1_addr", true,(i+0), 4,0);}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBus(c+27+i*1,"tb_register_file tv_rs2_addr", true,(i+0), 4,0);}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBus(c+40+i*1,"tb_register_file tv_rd_addr", true,(i+0), 4,0);}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBus(c+53+i*1,"tb_register_file tv_rd_wdata", true,(i+0), 31,0);}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBit(c+66+i*1,"tb_register_file tv_wen", true,(i+0));}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBus(c+79+i*1,"tb_register_file tv_rs1_exp", true,(i+0), 31,0);}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBus(c+92+i*1,"tb_register_file tv_rs2_exp", true,(i+0), 31,0);}}
        {int i; for (i=0; i<13; i++) {
                tracep->declBit(c+105+i*1,"tb_register_file tv_neg_chk", true,(i+0));}}
        tracep->declBus(c+125,"tb_register_file test_idx", false,-1, 31,0);
        tracep->declBus(c+162,"tb_register_file pass_cnt", false,-1, 31,0);
        tracep->declBus(c+163,"tb_register_file fail_cnt", false,-1, 31,0);
        tracep->declBit(c+159,"tb_register_file dut clk", false,-1);
        tracep->declBit(c+118,"tb_register_file dut rst_n", false,-1);
        tracep->declBus(c+119,"tb_register_file dut rs1_addr", false,-1, 4,0);
        tracep->declBus(c+120,"tb_register_file dut rs2_addr", false,-1, 4,0);
        tracep->declBus(c+160,"tb_register_file dut rs1_rdata", false,-1, 31,0);
        tracep->declBus(c+161,"tb_register_file dut rs2_rdata", false,-1, 31,0);
        tracep->declBus(c+121,"tb_register_file dut rd_addr", false,-1, 4,0);
        tracep->declBus(c+122,"tb_register_file dut rd_wdata", false,-1, 31,0);
        tracep->declBit(c+123,"tb_register_file dut wen", false,-1);
        {int i; for (i=0; i<32; i++) {
                tracep->declBus(c+126+i*1,"tb_register_file dut reg_file", true,(i+0), 31,0);}}
        tracep->declBus(c+158,"tb_register_file dut unnamedblk1 i", false,-1, 31,0);
    }
}

void Vtb_register_file::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vtb_register_file::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vtb_register_file::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullBit(oldp+1,(vlTOPp->tb_register_file__DOT__tv_rst_n[0]));
        tracep->fullBit(oldp+2,(vlTOPp->tb_register_file__DOT__tv_rst_n[1]));
        tracep->fullBit(oldp+3,(vlTOPp->tb_register_file__DOT__tv_rst_n[2]));
        tracep->fullBit(oldp+4,(vlTOPp->tb_register_file__DOT__tv_rst_n[3]));
        tracep->fullBit(oldp+5,(vlTOPp->tb_register_file__DOT__tv_rst_n[4]));
        tracep->fullBit(oldp+6,(vlTOPp->tb_register_file__DOT__tv_rst_n[5]));
        tracep->fullBit(oldp+7,(vlTOPp->tb_register_file__DOT__tv_rst_n[6]));
        tracep->fullBit(oldp+8,(vlTOPp->tb_register_file__DOT__tv_rst_n[7]));
        tracep->fullBit(oldp+9,(vlTOPp->tb_register_file__DOT__tv_rst_n[8]));
        tracep->fullBit(oldp+10,(vlTOPp->tb_register_file__DOT__tv_rst_n[9]));
        tracep->fullBit(oldp+11,(vlTOPp->tb_register_file__DOT__tv_rst_n[10]));
        tracep->fullBit(oldp+12,(vlTOPp->tb_register_file__DOT__tv_rst_n[11]));
        tracep->fullBit(oldp+13,(vlTOPp->tb_register_file__DOT__tv_rst_n[12]));
        tracep->fullCData(oldp+14,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[0]),5);
        tracep->fullCData(oldp+15,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[1]),5);
        tracep->fullCData(oldp+16,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[2]),5);
        tracep->fullCData(oldp+17,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[3]),5);
        tracep->fullCData(oldp+18,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[4]),5);
        tracep->fullCData(oldp+19,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[5]),5);
        tracep->fullCData(oldp+20,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[6]),5);
        tracep->fullCData(oldp+21,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[7]),5);
        tracep->fullCData(oldp+22,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[8]),5);
        tracep->fullCData(oldp+23,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[9]),5);
        tracep->fullCData(oldp+24,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[10]),5);
        tracep->fullCData(oldp+25,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[11]),5);
        tracep->fullCData(oldp+26,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[12]),5);
        tracep->fullCData(oldp+27,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[0]),5);
        tracep->fullCData(oldp+28,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[1]),5);
        tracep->fullCData(oldp+29,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[2]),5);
        tracep->fullCData(oldp+30,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[3]),5);
        tracep->fullCData(oldp+31,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[4]),5);
        tracep->fullCData(oldp+32,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[5]),5);
        tracep->fullCData(oldp+33,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[6]),5);
        tracep->fullCData(oldp+34,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[7]),5);
        tracep->fullCData(oldp+35,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[8]),5);
        tracep->fullCData(oldp+36,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[9]),5);
        tracep->fullCData(oldp+37,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[10]),5);
        tracep->fullCData(oldp+38,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[11]),5);
        tracep->fullCData(oldp+39,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[12]),5);
        tracep->fullCData(oldp+40,(vlTOPp->tb_register_file__DOT__tv_rd_addr[0]),5);
        tracep->fullCData(oldp+41,(vlTOPp->tb_register_file__DOT__tv_rd_addr[1]),5);
        tracep->fullCData(oldp+42,(vlTOPp->tb_register_file__DOT__tv_rd_addr[2]),5);
        tracep->fullCData(oldp+43,(vlTOPp->tb_register_file__DOT__tv_rd_addr[3]),5);
        tracep->fullCData(oldp+44,(vlTOPp->tb_register_file__DOT__tv_rd_addr[4]),5);
        tracep->fullCData(oldp+45,(vlTOPp->tb_register_file__DOT__tv_rd_addr[5]),5);
        tracep->fullCData(oldp+46,(vlTOPp->tb_register_file__DOT__tv_rd_addr[6]),5);
        tracep->fullCData(oldp+47,(vlTOPp->tb_register_file__DOT__tv_rd_addr[7]),5);
        tracep->fullCData(oldp+48,(vlTOPp->tb_register_file__DOT__tv_rd_addr[8]),5);
        tracep->fullCData(oldp+49,(vlTOPp->tb_register_file__DOT__tv_rd_addr[9]),5);
        tracep->fullCData(oldp+50,(vlTOPp->tb_register_file__DOT__tv_rd_addr[10]),5);
        tracep->fullCData(oldp+51,(vlTOPp->tb_register_file__DOT__tv_rd_addr[11]),5);
        tracep->fullCData(oldp+52,(vlTOPp->tb_register_file__DOT__tv_rd_addr[12]),5);
        tracep->fullIData(oldp+53,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[0]),32);
        tracep->fullIData(oldp+54,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[1]),32);
        tracep->fullIData(oldp+55,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[2]),32);
        tracep->fullIData(oldp+56,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[3]),32);
        tracep->fullIData(oldp+57,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[4]),32);
        tracep->fullIData(oldp+58,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[5]),32);
        tracep->fullIData(oldp+59,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[6]),32);
        tracep->fullIData(oldp+60,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[7]),32);
        tracep->fullIData(oldp+61,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[8]),32);
        tracep->fullIData(oldp+62,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[9]),32);
        tracep->fullIData(oldp+63,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[10]),32);
        tracep->fullIData(oldp+64,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[11]),32);
        tracep->fullIData(oldp+65,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[12]),32);
        tracep->fullBit(oldp+66,(vlTOPp->tb_register_file__DOT__tv_wen[0]));
        tracep->fullBit(oldp+67,(vlTOPp->tb_register_file__DOT__tv_wen[1]));
        tracep->fullBit(oldp+68,(vlTOPp->tb_register_file__DOT__tv_wen[2]));
        tracep->fullBit(oldp+69,(vlTOPp->tb_register_file__DOT__tv_wen[3]));
        tracep->fullBit(oldp+70,(vlTOPp->tb_register_file__DOT__tv_wen[4]));
        tracep->fullBit(oldp+71,(vlTOPp->tb_register_file__DOT__tv_wen[5]));
        tracep->fullBit(oldp+72,(vlTOPp->tb_register_file__DOT__tv_wen[6]));
        tracep->fullBit(oldp+73,(vlTOPp->tb_register_file__DOT__tv_wen[7]));
        tracep->fullBit(oldp+74,(vlTOPp->tb_register_file__DOT__tv_wen[8]));
        tracep->fullBit(oldp+75,(vlTOPp->tb_register_file__DOT__tv_wen[9]));
        tracep->fullBit(oldp+76,(vlTOPp->tb_register_file__DOT__tv_wen[10]));
        tracep->fullBit(oldp+77,(vlTOPp->tb_register_file__DOT__tv_wen[11]));
        tracep->fullBit(oldp+78,(vlTOPp->tb_register_file__DOT__tv_wen[12]));
        tracep->fullIData(oldp+79,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[0]),32);
        tracep->fullIData(oldp+80,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[1]),32);
        tracep->fullIData(oldp+81,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[2]),32);
        tracep->fullIData(oldp+82,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[3]),32);
        tracep->fullIData(oldp+83,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[4]),32);
        tracep->fullIData(oldp+84,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[5]),32);
        tracep->fullIData(oldp+85,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[6]),32);
        tracep->fullIData(oldp+86,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[7]),32);
        tracep->fullIData(oldp+87,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[8]),32);
        tracep->fullIData(oldp+88,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[9]),32);
        tracep->fullIData(oldp+89,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[10]),32);
        tracep->fullIData(oldp+90,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[11]),32);
        tracep->fullIData(oldp+91,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[12]),32);
        tracep->fullIData(oldp+92,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[0]),32);
        tracep->fullIData(oldp+93,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[1]),32);
        tracep->fullIData(oldp+94,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[2]),32);
        tracep->fullIData(oldp+95,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[3]),32);
        tracep->fullIData(oldp+96,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[4]),32);
        tracep->fullIData(oldp+97,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[5]),32);
        tracep->fullIData(oldp+98,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[6]),32);
        tracep->fullIData(oldp+99,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[7]),32);
        tracep->fullIData(oldp+100,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[8]),32);
        tracep->fullIData(oldp+101,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[9]),32);
        tracep->fullIData(oldp+102,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[10]),32);
        tracep->fullIData(oldp+103,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[11]),32);
        tracep->fullIData(oldp+104,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[12]),32);
        tracep->fullBit(oldp+105,(vlTOPp->tb_register_file__DOT__tv_neg_chk[0]));
        tracep->fullBit(oldp+106,(vlTOPp->tb_register_file__DOT__tv_neg_chk[1]));
        tracep->fullBit(oldp+107,(vlTOPp->tb_register_file__DOT__tv_neg_chk[2]));
        tracep->fullBit(oldp+108,(vlTOPp->tb_register_file__DOT__tv_neg_chk[3]));
        tracep->fullBit(oldp+109,(vlTOPp->tb_register_file__DOT__tv_neg_chk[4]));
        tracep->fullBit(oldp+110,(vlTOPp->tb_register_file__DOT__tv_neg_chk[5]));
        tracep->fullBit(oldp+111,(vlTOPp->tb_register_file__DOT__tv_neg_chk[6]));
        tracep->fullBit(oldp+112,(vlTOPp->tb_register_file__DOT__tv_neg_chk[7]));
        tracep->fullBit(oldp+113,(vlTOPp->tb_register_file__DOT__tv_neg_chk[8]));
        tracep->fullBit(oldp+114,(vlTOPp->tb_register_file__DOT__tv_neg_chk[9]));
        tracep->fullBit(oldp+115,(vlTOPp->tb_register_file__DOT__tv_neg_chk[10]));
        tracep->fullBit(oldp+116,(vlTOPp->tb_register_file__DOT__tv_neg_chk[11]));
        tracep->fullBit(oldp+117,(vlTOPp->tb_register_file__DOT__tv_neg_chk[12]));
        tracep->fullBit(oldp+118,(vlTOPp->tb_register_file__DOT__rst_n));
        tracep->fullCData(oldp+119,(vlTOPp->tb_register_file__DOT__rs1_addr),5);
        tracep->fullCData(oldp+120,(vlTOPp->tb_register_file__DOT__rs2_addr),5);
        tracep->fullCData(oldp+121,(vlTOPp->tb_register_file__DOT__rd_addr),5);
        tracep->fullIData(oldp+122,(vlTOPp->tb_register_file__DOT__rd_wdata),32);
        tracep->fullBit(oldp+123,(vlTOPp->tb_register_file__DOT__wen));
        tracep->fullBit(oldp+124,(vlTOPp->tb_register_file__DOT__init_done));
        tracep->fullIData(oldp+125,(vlTOPp->tb_register_file__DOT__test_idx),32);
        tracep->fullIData(oldp+126,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0]),32);
        tracep->fullIData(oldp+127,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[1]),32);
        tracep->fullIData(oldp+128,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[2]),32);
        tracep->fullIData(oldp+129,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[3]),32);
        tracep->fullIData(oldp+130,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[4]),32);
        tracep->fullIData(oldp+131,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[5]),32);
        tracep->fullIData(oldp+132,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[6]),32);
        tracep->fullIData(oldp+133,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[7]),32);
        tracep->fullIData(oldp+134,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[8]),32);
        tracep->fullIData(oldp+135,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[9]),32);
        tracep->fullIData(oldp+136,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[10]),32);
        tracep->fullIData(oldp+137,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[11]),32);
        tracep->fullIData(oldp+138,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[12]),32);
        tracep->fullIData(oldp+139,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[13]),32);
        tracep->fullIData(oldp+140,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[14]),32);
        tracep->fullIData(oldp+141,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[15]),32);
        tracep->fullIData(oldp+142,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[16]),32);
        tracep->fullIData(oldp+143,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[17]),32);
        tracep->fullIData(oldp+144,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[18]),32);
        tracep->fullIData(oldp+145,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[19]),32);
        tracep->fullIData(oldp+146,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[20]),32);
        tracep->fullIData(oldp+147,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[21]),32);
        tracep->fullIData(oldp+148,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[22]),32);
        tracep->fullIData(oldp+149,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[23]),32);
        tracep->fullIData(oldp+150,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[24]),32);
        tracep->fullIData(oldp+151,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[25]),32);
        tracep->fullIData(oldp+152,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[26]),32);
        tracep->fullIData(oldp+153,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[27]),32);
        tracep->fullIData(oldp+154,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[28]),32);
        tracep->fullIData(oldp+155,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[29]),32);
        tracep->fullIData(oldp+156,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[30]),32);
        tracep->fullIData(oldp+157,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[31]),32);
        tracep->fullIData(oldp+158,(vlTOPp->tb_register_file__DOT__dut__DOT__unnamedblk1__DOT__i),32);
        tracep->fullBit(oldp+159,(vlTOPp->clk));
        tracep->fullIData(oldp+160,(vlTOPp->tb_register_file__DOT__rs1_rdata),32);
        tracep->fullIData(oldp+161,(vlTOPp->tb_register_file__DOT__rs2_rdata),32);
        tracep->fullIData(oldp+162,(vlTOPp->tb_register_file__DOT__pass_cnt),32);
        tracep->fullIData(oldp+163,(vlTOPp->tb_register_file__DOT__fail_cnt),32);
        tracep->fullIData(oldp+164,(0xdU),32);
    }
}
