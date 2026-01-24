// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_fst_c.h"
#include "Vtop__Syms.h"


void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp);

void Vtop___024root__trace_chg_0(void* voidSelf, VerilatedFst::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtop___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtop___024root__trace_chg_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_chg_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    bufp->chgCData(oldp+0,(vlSelfRef.a),4);
    bufp->chgCData(oldp+1,(vlSelfRef.b),4);
    bufp->chgCData(oldp+2,(vlSelfRef.sum),4);
    bufp->chgBit(oldp+3,(vlSelfRef.carry_out));
    bufp->chgCData(oldp+4,(vlSelfRef.rca4__DOT__a),4);
    bufp->chgCData(oldp+5,(vlSelfRef.rca4__DOT__b),4);
    bufp->chgCData(oldp+6,(vlSelfRef.rca4__DOT__sum),4);
    bufp->chgBit(oldp+7,(vlSelfRef.rca4__DOT__carry_out));
    bufp->chgBit(oldp+8,(vlSelfRef.rca4__DOT__cout0));
    bufp->chgBit(oldp+9,(vlSelfRef.rca4__DOT__a0__DOT__cin));
    bufp->chgCData(oldp+10,(vlSelfRef.rca4__DOT__a0__DOT__a),2);
    bufp->chgCData(oldp+11,(vlSelfRef.rca4__DOT__a0__DOT__b),2);
    bufp->chgCData(oldp+12,(vlSelfRef.rca4__DOT__a0__DOT__s),2);
    bufp->chgBit(oldp+13,(vlSelfRef.rca4__DOT__a0__DOT__cout));
    bufp->chgBit(oldp+14,(vlSelfRef.rca4__DOT__a0__DOT__cout_tmp));
    bufp->chgBit(oldp+15,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cin));
    bufp->chgBit(oldp+16,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__a));
    bufp->chgBit(oldp+17,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__b));
    bufp->chgBit(oldp+18,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s));
    bufp->chgBit(oldp+19,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout));
    bufp->chgBit(oldp+20,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp));
    bufp->chgBit(oldp+21,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout_tmp1));
    bufp->chgBit(oldp+22,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout_tmp2));
    bufp->chgBit(oldp+23,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__a));
    bufp->chgBit(oldp+24,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__b));
    bufp->chgBit(oldp+25,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__s));
    bufp->chgBit(oldp+26,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__cout));
    bufp->chgBit(oldp+27,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__a));
    bufp->chgBit(oldp+28,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__b));
    bufp->chgBit(oldp+29,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__s));
    bufp->chgBit(oldp+30,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__cout));
    bufp->chgBit(oldp+31,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cin));
    bufp->chgBit(oldp+32,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__a));
    bufp->chgBit(oldp+33,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__b));
    bufp->chgBit(oldp+34,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s));
    bufp->chgBit(oldp+35,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout));
    bufp->chgBit(oldp+36,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s_tmp));
    bufp->chgBit(oldp+37,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout_tmp1));
    bufp->chgBit(oldp+38,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout_tmp2));
    bufp->chgBit(oldp+39,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__a));
    bufp->chgBit(oldp+40,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__b));
    bufp->chgBit(oldp+41,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__s));
    bufp->chgBit(oldp+42,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__cout));
    bufp->chgBit(oldp+43,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__a));
    bufp->chgBit(oldp+44,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__b));
    bufp->chgBit(oldp+45,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__s));
    bufp->chgBit(oldp+46,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__cout));
    bufp->chgBit(oldp+47,(vlSelfRef.rca4__DOT__a1__DOT__cin));
    bufp->chgCData(oldp+48,(vlSelfRef.rca4__DOT__a1__DOT__a),2);
    bufp->chgCData(oldp+49,(vlSelfRef.rca4__DOT__a1__DOT__b),2);
    bufp->chgCData(oldp+50,(vlSelfRef.rca4__DOT__a1__DOT__s),2);
    bufp->chgBit(oldp+51,(vlSelfRef.rca4__DOT__a1__DOT__cout));
    bufp->chgBit(oldp+52,(vlSelfRef.rca4__DOT__a1__DOT__cout_tmp));
    bufp->chgBit(oldp+53,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cin));
    bufp->chgBit(oldp+54,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__a));
    bufp->chgBit(oldp+55,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__b));
    bufp->chgBit(oldp+56,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s));
    bufp->chgBit(oldp+57,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout));
    bufp->chgBit(oldp+58,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s_tmp));
    bufp->chgBit(oldp+59,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout_tmp1));
    bufp->chgBit(oldp+60,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout_tmp2));
    bufp->chgBit(oldp+61,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__a));
    bufp->chgBit(oldp+62,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__b));
    bufp->chgBit(oldp+63,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__s));
    bufp->chgBit(oldp+64,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__cout));
    bufp->chgBit(oldp+65,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__a));
    bufp->chgBit(oldp+66,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__b));
    bufp->chgBit(oldp+67,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__s));
    bufp->chgBit(oldp+68,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__cout));
    bufp->chgBit(oldp+69,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cin));
    bufp->chgBit(oldp+70,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__a));
    bufp->chgBit(oldp+71,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__b));
    bufp->chgBit(oldp+72,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s));
    bufp->chgBit(oldp+73,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout));
    bufp->chgBit(oldp+74,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s_tmp));
    bufp->chgBit(oldp+75,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout_tmp1));
    bufp->chgBit(oldp+76,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout_tmp2));
    bufp->chgBit(oldp+77,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__a));
    bufp->chgBit(oldp+78,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__b));
    bufp->chgBit(oldp+79,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__s));
    bufp->chgBit(oldp+80,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__cout));
    bufp->chgBit(oldp+81,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__a));
    bufp->chgBit(oldp+82,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__b));
    bufp->chgBit(oldp+83,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__s));
    bufp->chgBit(oldp+84,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__cout));
}

void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedFst* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_cleanup\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VlUnpacked<CData/*0:0*/, 1> __Vm_traceActivity;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        __Vm_traceActivity[__Vi0] = 0;
    }
    // Body
    vlSymsp->__Vm_activity = false;
    __Vm_traceActivity[0U] = 0U;
}
