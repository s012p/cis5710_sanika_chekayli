// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_fst_c.h"
#include "Vtop__Syms.h"


VL_ATTR_COLD void Vtop___024root__trace_init_sub__TOP__0(Vtop___024root* vlSelf, VerilatedFst* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_init_sub__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBus(c+1,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+2,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+3,0,"sum",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+4,0,"carry_out",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("rca4", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+5,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+6,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+7,0,"sum",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+8,0,"carry_out",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+9,0,"cout0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("a0", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+10,0,"cin",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+11,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+12,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+13,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+14,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+15,0,"cout_tmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("a0", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+16,0,"cin",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+18,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+19,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+20,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+21,0,"s_tmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+22,0,"cout_tmp1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+23,0,"cout_tmp2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("h0", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+24,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+25,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+26,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+27,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("h1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+28,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+29,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+30,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+31,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("a1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+32,0,"cin",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+33,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+34,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+35,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+36,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+37,0,"s_tmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+38,0,"cout_tmp1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+39,0,"cout_tmp2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("h0", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+40,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+41,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+42,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("h1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+44,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+45,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+46,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+47,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("a1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+48,0,"cin",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+49,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+50,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+51,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+52,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+53,0,"cout_tmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("a0", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+54,0,"cin",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+55,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+56,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+57,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+58,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+59,0,"s_tmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+60,0,"cout_tmp1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+61,0,"cout_tmp2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("h0", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+62,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+63,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+64,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+65,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("h1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+66,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+67,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+68,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+69,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("a1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+70,0,"cin",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+71,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+72,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+73,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+74,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+75,0,"s_tmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+76,0,"cout_tmp1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+77,0,"cout_tmp2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("h0", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+78,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+79,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+80,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+81,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("h1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+82,0,"a",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+83,0,"b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+84,0,"s",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+85,0,"cout",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vtop___024root__trace_init_top(Vtop___024root* vlSelf, VerilatedFst* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_init_top\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtop___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vtop___024root__trace_const_0(void* voidSelf, VerilatedFst::Buffer* bufp);
VL_ATTR_COLD void Vtop___024root__trace_full_0(void* voidSelf, VerilatedFst::Buffer* bufp);
void Vtop___024root__trace_chg_0(void* voidSelf, VerilatedFst::Buffer* bufp);
void Vtop___024root__trace_cleanup(void* voidSelf, VerilatedFst* /*unused*/);

VL_ATTR_COLD void Vtop___024root__trace_register(Vtop___024root* vlSelf, VerilatedFst* tracep) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_register\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vtop___024root__trace_const_0, 0U, vlSelf);
    tracep->addFullCb(&Vtop___024root__trace_full_0, 0U, vlSelf);
    tracep->addChgCb(&Vtop___024root__trace_chg_0, 0U, vlSelf);
    tracep->addCleanupCb(&Vtop___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vtop___024root__trace_const_0(void* voidSelf, VerilatedFst::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_const_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
}

VL_ATTR_COLD void Vtop___024root__trace_full_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp);

VL_ATTR_COLD void Vtop___024root__trace_full_0(void* voidSelf, VerilatedFst::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_full_0\n"); );
    // Init
    Vtop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtop___024root*>(voidSelf);
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    Vtop___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtop___024root__trace_full_0_sub_0(Vtop___024root* vlSelf, VerilatedFst::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root__trace_full_0_sub_0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullCData(oldp+1,(vlSelfRef.a),4);
    bufp->fullCData(oldp+2,(vlSelfRef.b),4);
    bufp->fullCData(oldp+3,(vlSelfRef.sum),4);
    bufp->fullBit(oldp+4,(vlSelfRef.carry_out));
    bufp->fullCData(oldp+5,(vlSelfRef.rca4__DOT__a),4);
    bufp->fullCData(oldp+6,(vlSelfRef.rca4__DOT__b),4);
    bufp->fullCData(oldp+7,(vlSelfRef.rca4__DOT__sum),4);
    bufp->fullBit(oldp+8,(vlSelfRef.rca4__DOT__carry_out));
    bufp->fullBit(oldp+9,(vlSelfRef.rca4__DOT__cout0));
    bufp->fullBit(oldp+10,(vlSelfRef.rca4__DOT__a0__DOT__cin));
    bufp->fullCData(oldp+11,(vlSelfRef.rca4__DOT__a0__DOT__a),2);
    bufp->fullCData(oldp+12,(vlSelfRef.rca4__DOT__a0__DOT__b),2);
    bufp->fullCData(oldp+13,(vlSelfRef.rca4__DOT__a0__DOT__s),2);
    bufp->fullBit(oldp+14,(vlSelfRef.rca4__DOT__a0__DOT__cout));
    bufp->fullBit(oldp+15,(vlSelfRef.rca4__DOT__a0__DOT__cout_tmp));
    bufp->fullBit(oldp+16,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cin));
    bufp->fullBit(oldp+17,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__a));
    bufp->fullBit(oldp+18,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__b));
    bufp->fullBit(oldp+19,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s));
    bufp->fullBit(oldp+20,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout));
    bufp->fullBit(oldp+21,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp));
    bufp->fullBit(oldp+22,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout_tmp1));
    bufp->fullBit(oldp+23,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout_tmp2));
    bufp->fullBit(oldp+24,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__a));
    bufp->fullBit(oldp+25,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__b));
    bufp->fullBit(oldp+26,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__s));
    bufp->fullBit(oldp+27,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__cout));
    bufp->fullBit(oldp+28,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__a));
    bufp->fullBit(oldp+29,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__b));
    bufp->fullBit(oldp+30,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__s));
    bufp->fullBit(oldp+31,(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__cout));
    bufp->fullBit(oldp+32,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cin));
    bufp->fullBit(oldp+33,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__a));
    bufp->fullBit(oldp+34,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__b));
    bufp->fullBit(oldp+35,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s));
    bufp->fullBit(oldp+36,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout));
    bufp->fullBit(oldp+37,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s_tmp));
    bufp->fullBit(oldp+38,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout_tmp1));
    bufp->fullBit(oldp+39,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout_tmp2));
    bufp->fullBit(oldp+40,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__a));
    bufp->fullBit(oldp+41,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__b));
    bufp->fullBit(oldp+42,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__s));
    bufp->fullBit(oldp+43,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__cout));
    bufp->fullBit(oldp+44,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__a));
    bufp->fullBit(oldp+45,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__b));
    bufp->fullBit(oldp+46,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__s));
    bufp->fullBit(oldp+47,(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__cout));
    bufp->fullBit(oldp+48,(vlSelfRef.rca4__DOT__a1__DOT__cin));
    bufp->fullCData(oldp+49,(vlSelfRef.rca4__DOT__a1__DOT__a),2);
    bufp->fullCData(oldp+50,(vlSelfRef.rca4__DOT__a1__DOT__b),2);
    bufp->fullCData(oldp+51,(vlSelfRef.rca4__DOT__a1__DOT__s),2);
    bufp->fullBit(oldp+52,(vlSelfRef.rca4__DOT__a1__DOT__cout));
    bufp->fullBit(oldp+53,(vlSelfRef.rca4__DOT__a1__DOT__cout_tmp));
    bufp->fullBit(oldp+54,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cin));
    bufp->fullBit(oldp+55,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__a));
    bufp->fullBit(oldp+56,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__b));
    bufp->fullBit(oldp+57,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s));
    bufp->fullBit(oldp+58,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout));
    bufp->fullBit(oldp+59,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s_tmp));
    bufp->fullBit(oldp+60,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout_tmp1));
    bufp->fullBit(oldp+61,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout_tmp2));
    bufp->fullBit(oldp+62,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__a));
    bufp->fullBit(oldp+63,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__b));
    bufp->fullBit(oldp+64,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__s));
    bufp->fullBit(oldp+65,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__cout));
    bufp->fullBit(oldp+66,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__a));
    bufp->fullBit(oldp+67,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__b));
    bufp->fullBit(oldp+68,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__s));
    bufp->fullBit(oldp+69,(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__cout));
    bufp->fullBit(oldp+70,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cin));
    bufp->fullBit(oldp+71,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__a));
    bufp->fullBit(oldp+72,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__b));
    bufp->fullBit(oldp+73,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s));
    bufp->fullBit(oldp+74,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout));
    bufp->fullBit(oldp+75,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s_tmp));
    bufp->fullBit(oldp+76,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout_tmp1));
    bufp->fullBit(oldp+77,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout_tmp2));
    bufp->fullBit(oldp+78,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__a));
    bufp->fullBit(oldp+79,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__b));
    bufp->fullBit(oldp+80,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__s));
    bufp->fullBit(oldp+81,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__cout));
    bufp->fullBit(oldp+82,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__a));
    bufp->fullBit(oldp+83,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__b));
    bufp->fullBit(oldp+84,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__s));
    bufp->fullBit(oldp+85,(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__cout));
}
