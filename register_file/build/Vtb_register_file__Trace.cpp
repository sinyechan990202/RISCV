// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_register_file__Syms.h"


void Vtb_register_file::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vtb_register_file::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[0U])) {
            tracep->chgBit(oldp+0,(vlTOPp->tb_register_file__DOT__tv_rst_n[0]));
            tracep->chgBit(oldp+1,(vlTOPp->tb_register_file__DOT__tv_rst_n[1]));
            tracep->chgBit(oldp+2,(vlTOPp->tb_register_file__DOT__tv_rst_n[2]));
            tracep->chgBit(oldp+3,(vlTOPp->tb_register_file__DOT__tv_rst_n[3]));
            tracep->chgBit(oldp+4,(vlTOPp->tb_register_file__DOT__tv_rst_n[4]));
            tracep->chgBit(oldp+5,(vlTOPp->tb_register_file__DOT__tv_rst_n[5]));
            tracep->chgBit(oldp+6,(vlTOPp->tb_register_file__DOT__tv_rst_n[6]));
            tracep->chgBit(oldp+7,(vlTOPp->tb_register_file__DOT__tv_rst_n[7]));
            tracep->chgBit(oldp+8,(vlTOPp->tb_register_file__DOT__tv_rst_n[8]));
            tracep->chgBit(oldp+9,(vlTOPp->tb_register_file__DOT__tv_rst_n[9]));
            tracep->chgBit(oldp+10,(vlTOPp->tb_register_file__DOT__tv_rst_n[10]));
            tracep->chgBit(oldp+11,(vlTOPp->tb_register_file__DOT__tv_rst_n[11]));
            tracep->chgBit(oldp+12,(vlTOPp->tb_register_file__DOT__tv_rst_n[12]));
            tracep->chgCData(oldp+13,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[0]),5);
            tracep->chgCData(oldp+14,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[1]),5);
            tracep->chgCData(oldp+15,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[2]),5);
            tracep->chgCData(oldp+16,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[3]),5);
            tracep->chgCData(oldp+17,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[4]),5);
            tracep->chgCData(oldp+18,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[5]),5);
            tracep->chgCData(oldp+19,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[6]),5);
            tracep->chgCData(oldp+20,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[7]),5);
            tracep->chgCData(oldp+21,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[8]),5);
            tracep->chgCData(oldp+22,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[9]),5);
            tracep->chgCData(oldp+23,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[10]),5);
            tracep->chgCData(oldp+24,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[11]),5);
            tracep->chgCData(oldp+25,(vlTOPp->tb_register_file__DOT__tv_rs1_addr[12]),5);
            tracep->chgCData(oldp+26,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[0]),5);
            tracep->chgCData(oldp+27,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[1]),5);
            tracep->chgCData(oldp+28,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[2]),5);
            tracep->chgCData(oldp+29,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[3]),5);
            tracep->chgCData(oldp+30,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[4]),5);
            tracep->chgCData(oldp+31,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[5]),5);
            tracep->chgCData(oldp+32,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[6]),5);
            tracep->chgCData(oldp+33,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[7]),5);
            tracep->chgCData(oldp+34,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[8]),5);
            tracep->chgCData(oldp+35,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[9]),5);
            tracep->chgCData(oldp+36,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[10]),5);
            tracep->chgCData(oldp+37,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[11]),5);
            tracep->chgCData(oldp+38,(vlTOPp->tb_register_file__DOT__tv_rs2_addr[12]),5);
            tracep->chgCData(oldp+39,(vlTOPp->tb_register_file__DOT__tv_rd_addr[0]),5);
            tracep->chgCData(oldp+40,(vlTOPp->tb_register_file__DOT__tv_rd_addr[1]),5);
            tracep->chgCData(oldp+41,(vlTOPp->tb_register_file__DOT__tv_rd_addr[2]),5);
            tracep->chgCData(oldp+42,(vlTOPp->tb_register_file__DOT__tv_rd_addr[3]),5);
            tracep->chgCData(oldp+43,(vlTOPp->tb_register_file__DOT__tv_rd_addr[4]),5);
            tracep->chgCData(oldp+44,(vlTOPp->tb_register_file__DOT__tv_rd_addr[5]),5);
            tracep->chgCData(oldp+45,(vlTOPp->tb_register_file__DOT__tv_rd_addr[6]),5);
            tracep->chgCData(oldp+46,(vlTOPp->tb_register_file__DOT__tv_rd_addr[7]),5);
            tracep->chgCData(oldp+47,(vlTOPp->tb_register_file__DOT__tv_rd_addr[8]),5);
            tracep->chgCData(oldp+48,(vlTOPp->tb_register_file__DOT__tv_rd_addr[9]),5);
            tracep->chgCData(oldp+49,(vlTOPp->tb_register_file__DOT__tv_rd_addr[10]),5);
            tracep->chgCData(oldp+50,(vlTOPp->tb_register_file__DOT__tv_rd_addr[11]),5);
            tracep->chgCData(oldp+51,(vlTOPp->tb_register_file__DOT__tv_rd_addr[12]),5);
            tracep->chgIData(oldp+52,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[0]),32);
            tracep->chgIData(oldp+53,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[1]),32);
            tracep->chgIData(oldp+54,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[2]),32);
            tracep->chgIData(oldp+55,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[3]),32);
            tracep->chgIData(oldp+56,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[4]),32);
            tracep->chgIData(oldp+57,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[5]),32);
            tracep->chgIData(oldp+58,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[6]),32);
            tracep->chgIData(oldp+59,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[7]),32);
            tracep->chgIData(oldp+60,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[8]),32);
            tracep->chgIData(oldp+61,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[9]),32);
            tracep->chgIData(oldp+62,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[10]),32);
            tracep->chgIData(oldp+63,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[11]),32);
            tracep->chgIData(oldp+64,(vlTOPp->tb_register_file__DOT__tv_rd_wdata[12]),32);
            tracep->chgBit(oldp+65,(vlTOPp->tb_register_file__DOT__tv_wen[0]));
            tracep->chgBit(oldp+66,(vlTOPp->tb_register_file__DOT__tv_wen[1]));
            tracep->chgBit(oldp+67,(vlTOPp->tb_register_file__DOT__tv_wen[2]));
            tracep->chgBit(oldp+68,(vlTOPp->tb_register_file__DOT__tv_wen[3]));
            tracep->chgBit(oldp+69,(vlTOPp->tb_register_file__DOT__tv_wen[4]));
            tracep->chgBit(oldp+70,(vlTOPp->tb_register_file__DOT__tv_wen[5]));
            tracep->chgBit(oldp+71,(vlTOPp->tb_register_file__DOT__tv_wen[6]));
            tracep->chgBit(oldp+72,(vlTOPp->tb_register_file__DOT__tv_wen[7]));
            tracep->chgBit(oldp+73,(vlTOPp->tb_register_file__DOT__tv_wen[8]));
            tracep->chgBit(oldp+74,(vlTOPp->tb_register_file__DOT__tv_wen[9]));
            tracep->chgBit(oldp+75,(vlTOPp->tb_register_file__DOT__tv_wen[10]));
            tracep->chgBit(oldp+76,(vlTOPp->tb_register_file__DOT__tv_wen[11]));
            tracep->chgBit(oldp+77,(vlTOPp->tb_register_file__DOT__tv_wen[12]));
            tracep->chgIData(oldp+78,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[0]),32);
            tracep->chgIData(oldp+79,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[1]),32);
            tracep->chgIData(oldp+80,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[2]),32);
            tracep->chgIData(oldp+81,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[3]),32);
            tracep->chgIData(oldp+82,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[4]),32);
            tracep->chgIData(oldp+83,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[5]),32);
            tracep->chgIData(oldp+84,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[6]),32);
            tracep->chgIData(oldp+85,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[7]),32);
            tracep->chgIData(oldp+86,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[8]),32);
            tracep->chgIData(oldp+87,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[9]),32);
            tracep->chgIData(oldp+88,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[10]),32);
            tracep->chgIData(oldp+89,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[11]),32);
            tracep->chgIData(oldp+90,(vlTOPp->tb_register_file__DOT__tv_rs1_exp[12]),32);
            tracep->chgIData(oldp+91,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[0]),32);
            tracep->chgIData(oldp+92,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[1]),32);
            tracep->chgIData(oldp+93,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[2]),32);
            tracep->chgIData(oldp+94,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[3]),32);
            tracep->chgIData(oldp+95,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[4]),32);
            tracep->chgIData(oldp+96,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[5]),32);
            tracep->chgIData(oldp+97,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[6]),32);
            tracep->chgIData(oldp+98,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[7]),32);
            tracep->chgIData(oldp+99,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[8]),32);
            tracep->chgIData(oldp+100,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[9]),32);
            tracep->chgIData(oldp+101,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[10]),32);
            tracep->chgIData(oldp+102,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[11]),32);
            tracep->chgIData(oldp+103,(vlTOPp->tb_register_file__DOT__tv_rs2_exp[12]),32);
            tracep->chgBit(oldp+104,(vlTOPp->tb_register_file__DOT__tv_neg_chk[0]));
            tracep->chgBit(oldp+105,(vlTOPp->tb_register_file__DOT__tv_neg_chk[1]));
            tracep->chgBit(oldp+106,(vlTOPp->tb_register_file__DOT__tv_neg_chk[2]));
            tracep->chgBit(oldp+107,(vlTOPp->tb_register_file__DOT__tv_neg_chk[3]));
            tracep->chgBit(oldp+108,(vlTOPp->tb_register_file__DOT__tv_neg_chk[4]));
            tracep->chgBit(oldp+109,(vlTOPp->tb_register_file__DOT__tv_neg_chk[5]));
            tracep->chgBit(oldp+110,(vlTOPp->tb_register_file__DOT__tv_neg_chk[6]));
            tracep->chgBit(oldp+111,(vlTOPp->tb_register_file__DOT__tv_neg_chk[7]));
            tracep->chgBit(oldp+112,(vlTOPp->tb_register_file__DOT__tv_neg_chk[8]));
            tracep->chgBit(oldp+113,(vlTOPp->tb_register_file__DOT__tv_neg_chk[9]));
            tracep->chgBit(oldp+114,(vlTOPp->tb_register_file__DOT__tv_neg_chk[10]));
            tracep->chgBit(oldp+115,(vlTOPp->tb_register_file__DOT__tv_neg_chk[11]));
            tracep->chgBit(oldp+116,(vlTOPp->tb_register_file__DOT__tv_neg_chk[12]));
        }
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[1U])) {
            tracep->chgBit(oldp+117,(vlTOPp->tb_register_file__DOT__rst_n));
            tracep->chgCData(oldp+118,(vlTOPp->tb_register_file__DOT__rs1_addr),5);
            tracep->chgCData(oldp+119,(vlTOPp->tb_register_file__DOT__rs2_addr),5);
            tracep->chgCData(oldp+120,(vlTOPp->tb_register_file__DOT__rd_addr),5);
            tracep->chgIData(oldp+121,(vlTOPp->tb_register_file__DOT__rd_wdata),32);
            tracep->chgBit(oldp+122,(vlTOPp->tb_register_file__DOT__wen));
            tracep->chgBit(oldp+123,(vlTOPp->tb_register_file__DOT__init_done));
        }
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[2U])) {
            tracep->chgIData(oldp+124,(vlTOPp->tb_register_file__DOT__test_idx),32);
            tracep->chgIData(oldp+125,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[0]),32);
            tracep->chgIData(oldp+126,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[1]),32);
            tracep->chgIData(oldp+127,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[2]),32);
            tracep->chgIData(oldp+128,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[3]),32);
            tracep->chgIData(oldp+129,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[4]),32);
            tracep->chgIData(oldp+130,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[5]),32);
            tracep->chgIData(oldp+131,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[6]),32);
            tracep->chgIData(oldp+132,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[7]),32);
            tracep->chgIData(oldp+133,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[8]),32);
            tracep->chgIData(oldp+134,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[9]),32);
            tracep->chgIData(oldp+135,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[10]),32);
            tracep->chgIData(oldp+136,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[11]),32);
            tracep->chgIData(oldp+137,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[12]),32);
            tracep->chgIData(oldp+138,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[13]),32);
            tracep->chgIData(oldp+139,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[14]),32);
            tracep->chgIData(oldp+140,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[15]),32);
            tracep->chgIData(oldp+141,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[16]),32);
            tracep->chgIData(oldp+142,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[17]),32);
            tracep->chgIData(oldp+143,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[18]),32);
            tracep->chgIData(oldp+144,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[19]),32);
            tracep->chgIData(oldp+145,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[20]),32);
            tracep->chgIData(oldp+146,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[21]),32);
            tracep->chgIData(oldp+147,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[22]),32);
            tracep->chgIData(oldp+148,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[23]),32);
            tracep->chgIData(oldp+149,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[24]),32);
            tracep->chgIData(oldp+150,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[25]),32);
            tracep->chgIData(oldp+151,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[26]),32);
            tracep->chgIData(oldp+152,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[27]),32);
            tracep->chgIData(oldp+153,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[28]),32);
            tracep->chgIData(oldp+154,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[29]),32);
            tracep->chgIData(oldp+155,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[30]),32);
            tracep->chgIData(oldp+156,(vlTOPp->tb_register_file__DOT__dut__DOT__reg_file[31]),32);
            tracep->chgIData(oldp+157,(vlTOPp->tb_register_file__DOT__dut__DOT__unnamedblk1__DOT__i),32);
        }
        tracep->chgBit(oldp+158,(vlTOPp->clk));
        tracep->chgIData(oldp+159,(vlTOPp->tb_register_file__DOT__rs1_rdata),32);
        tracep->chgIData(oldp+160,(vlTOPp->tb_register_file__DOT__rs2_rdata),32);
        tracep->chgIData(oldp+161,(vlTOPp->tb_register_file__DOT__pass_cnt),32);
        tracep->chgIData(oldp+162,(vlTOPp->tb_register_file__DOT__fail_cnt),32);
    }
}

void Vtb_register_file::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vtb_register_file__Syms* __restrict vlSymsp = static_cast<Vtb_register_file__Syms*>(userp);
    Vtb_register_file* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
        vlTOPp->__Vm_traceActivity[1U] = 0U;
        vlTOPp->__Vm_traceActivity[2U] = 0U;
    }
}
