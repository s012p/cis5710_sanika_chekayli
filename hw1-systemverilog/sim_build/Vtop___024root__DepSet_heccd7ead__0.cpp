// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtop.h for the primary calling header

#include "Vtop__pch.h"
#include "Vtop___024root.h"

void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf);

void Vtop___024root___eval_ico(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_ico\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered.word(0U))) {
        Vtop___024root___ico_sequent__TOP__0(vlSelf);
    }
}

VL_INLINE_OPT void Vtop___024root___ico_sequent__TOP__0(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___ico_sequent__TOP__0\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.rca4__DOT__a = vlSelfRef.a;
    vlSelfRef.rca4__DOT__b = vlSelfRef.b;
    vlSelfRef.rca4__DOT__a0__DOT__a = (3U & ((IData)(vlSelfRef.a) 
                                             >> 0U));
    vlSelfRef.rca4__DOT__a0__DOT__b = (3U & ((IData)(vlSelfRef.b) 
                                             >> 0U));
    vlSelfRef.rca4__DOT__a1__DOT__a = (3U & ((IData)(vlSelfRef.a) 
                                             >> 2U));
    vlSelfRef.rca4__DOT__a1__DOT__b = (3U & ((IData)(vlSelfRef.b) 
                                             >> 2U));
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cin = vlSelfRef.rca4__DOT__a0__DOT__cin;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__a = (1U 
                                                & ((IData)(vlSelfRef.a) 
                                                   >> 0U));
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__b = (1U 
                                                & ((IData)(vlSelfRef.b) 
                                                   >> 0U));
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__a = (1U 
                                                & ((IData)(vlSelfRef.a) 
                                                   >> 1U));
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__b = (1U 
                                                & ((IData)(vlSelfRef.b) 
                                                   >> 1U));
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__a = (1U 
                                                & ((IData)(vlSelfRef.a) 
                                                   >> 2U));
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__b = (1U 
                                                & ((IData)(vlSelfRef.b) 
                                                   >> 2U));
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__a = (1U 
                                                & ((IData)(vlSelfRef.a) 
                                                   >> 3U));
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__b = (1U 
                                                & ((IData)(vlSelfRef.b) 
                                                   >> 3U));
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__cout 
        = (1U & (((IData)(vlSelfRef.a) & (IData)(vlSelfRef.b)) 
                 >> 3U));
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp = 
        (1U & ((IData)(vlSelfRef.a) ^ (IData)(vlSelfRef.b)));
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s_tmp = 
        (1U & (((IData)(vlSelfRef.a) ^ (IData)(vlSelfRef.b)) 
               >> 3U));
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__cout 
        = (1U & (((IData)(vlSelfRef.a) & (IData)(vlSelfRef.b)) 
                 >> 2U));
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s_tmp = 
        (1U & (((IData)(vlSelfRef.a) ^ (IData)(vlSelfRef.b)) 
               >> 2U));
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__cout 
        = (1U & (((IData)(vlSelfRef.a) & (IData)(vlSelfRef.b)) 
                 >> 1U));
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s_tmp = 
        (1U & (((IData)(vlSelfRef.a) ^ (IData)(vlSelfRef.b)) 
               >> 1U));
    vlSelfRef.rca4__DOT__a0__DOT__cout_tmp = (1U & 
                                              ((IData)(vlSelfRef.a) 
                                               & (IData)(vlSelfRef.b)));
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__b 
        = vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cin;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__a 
        = vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__a;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__b 
        = vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__b;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__a 
        = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__a;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__b 
        = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__b;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__a 
        = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__a;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__b 
        = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__b;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__a 
        = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__a;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__b 
        = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__b;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout_tmp1 
        = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__cout;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__a 
        = vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s = vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__s 
        = vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__s 
        = vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__a 
        = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__s 
        = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout_tmp1 
        = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__cout;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__a 
        = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__s 
        = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout_tmp1 
        = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__cout;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__a 
        = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__s 
        = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout = vlSelfRef.rca4__DOT__a0__DOT__cout_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__cout_tmp1 
        = vlSelfRef.rca4__DOT__a0__DOT__cout_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__cout 
        = vlSelfRef.rca4__DOT__a0__DOT__cout_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cin = vlSelfRef.rca4__DOT__a0__DOT__cout_tmp;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__s 
        = ((IData)(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s_tmp) 
           ^ (IData)(vlSelfRef.rca4__DOT__a0__DOT__cout_tmp));
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__cout 
        = ((IData)(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s_tmp) 
           & (IData)(vlSelfRef.rca4__DOT__a0__DOT__cout_tmp));
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__b 
        = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cin;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__s = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__s;
    vlSelfRef.rca4__DOT__a0__DOT__s = (((IData)(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__s) 
                                        << 1U) | (IData)(vlSelfRef.rca4__DOT__a0__DOT__a0__DOT__s_tmp));
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout_tmp2 
        = vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__cout;
    vlSelfRef.rca4__DOT__cout0 = ((IData)(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__cout) 
                                  | (IData)(vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__cout));
    vlSelfRef.rca4__DOT__a0__DOT__cout = vlSelfRef.rca4__DOT__cout0;
    vlSelfRef.rca4__DOT__a0__DOT__a1__DOT__cout = vlSelfRef.rca4__DOT__cout0;
    vlSelfRef.rca4__DOT__a1__DOT__cin = vlSelfRef.rca4__DOT__cout0;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__s 
        = ((IData)(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s_tmp) 
           ^ (IData)(vlSelfRef.rca4__DOT__cout0));
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__cout 
        = ((IData)(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s_tmp) 
           & (IData)(vlSelfRef.rca4__DOT__cout0));
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cin = vlSelfRef.rca4__DOT__a1__DOT__cin;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__s = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__s;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout_tmp2 
        = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__cout;
    vlSelfRef.rca4__DOT__a1__DOT__cout_tmp = ((IData)(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__cout) 
                                              | (IData)(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__cout));
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__b 
        = vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cin;
    vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__cout = vlSelfRef.rca4__DOT__a1__DOT__cout_tmp;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cin = vlSelfRef.rca4__DOT__a1__DOT__cout_tmp;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__s 
        = ((IData)(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s_tmp) 
           ^ (IData)(vlSelfRef.rca4__DOT__a1__DOT__cout_tmp));
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__cout 
        = ((IData)(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s_tmp) 
           & (IData)(vlSelfRef.rca4__DOT__a1__DOT__cout_tmp));
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__b 
        = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cin;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__s = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__s;
    vlSelfRef.rca4__DOT__a1__DOT__s = (((IData)(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__s) 
                                        << 1U) | (IData)(vlSelfRef.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__s));
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout_tmp2 
        = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__cout;
    vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout = ((IData)(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__cout) 
                                                   | (IData)(vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__cout));
    vlSelfRef.rca4__DOT__sum = (((IData)(vlSelfRef.rca4__DOT__a1__DOT__s) 
                                 << 2U) | (IData)(vlSelfRef.rca4__DOT__a0__DOT__s));
    vlSelfRef.carry_out = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout;
    vlSelfRef.rca4__DOT__carry_out = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout;
    vlSelfRef.rca4__DOT__a1__DOT__cout = vlSelfRef.rca4__DOT__a1__DOT__a1__DOT__cout;
    vlSelfRef.sum = vlSelfRef.rca4__DOT__sum;
}

void Vtop___024root___eval_triggers__ico(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__ico(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__ico\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VicoExecute;
    // Body
    Vtop___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = vlSelfRef.__VicoTriggered.any();
    if (__VicoExecute) {
        Vtop___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

void Vtop___024root___eval_act(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtop___024root___eval_nba(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

void Vtop___024root___eval_triggers__act(Vtop___024root* vlSelf);

bool Vtop___024root___eval_phase__act(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__act\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    VlTriggerVec<0> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vtop___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelfRef.__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelfRef.__VactTriggered, vlSelfRef.__VnbaTriggered);
        vlSelfRef.__VnbaTriggered.thisOr(vlSelfRef.__VactTriggered);
        Vtop___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vtop___024root___eval_phase__nba(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_phase__nba\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelfRef.__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vtop___024root___eval_nba(vlSelf);
        vlSelfRef.__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__ico(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__nba(Vtop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vtop___024root___dump_triggers__act(Vtop___024root* vlSelf);
#endif  // VL_DEBUG

void Vtop___024root___eval(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Init
    IData/*31:0*/ __VicoIterCount;
    CData/*0:0*/ __VicoContinue;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    __VicoContinue = 1U;
    while (__VicoContinue) {
        if (VL_UNLIKELY((0x64U < __VicoIterCount))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__ico(vlSelf);
#endif
            VL_FATAL_MT("/workspaces/cis5710-sp26/hw1-systemverilog/rca.sv", 43, "", "Input combinational region did not converge.");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
        __VicoContinue = 0U;
        if (Vtop___024root___eval_phase__ico(vlSelf)) {
            __VicoContinue = 1U;
        }
        vlSelfRef.__VicoFirstIteration = 0U;
    }
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vtop___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("/workspaces/cis5710-sp26/hw1-systemverilog/rca.sv", 43, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelfRef.__VactIterCount = 0U;
        vlSelfRef.__VactContinue = 1U;
        while (vlSelfRef.__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelfRef.__VactIterCount))) {
#ifdef VL_DEBUG
                Vtop___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("/workspaces/cis5710-sp26/hw1-systemverilog/rca.sv", 43, "", "Active region did not converge.");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactContinue = 0U;
            if (Vtop___024root___eval_phase__act(vlSelf)) {
                vlSelfRef.__VactContinue = 1U;
            }
        }
        if (Vtop___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vtop___024root___eval_debug_assertions(Vtop___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtop___024root___eval_debug_assertions\n"); );
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY((vlSelfRef.a & 0xf0U))) {
        Verilated::overWidthError("a");}
    if (VL_UNLIKELY((vlSelfRef.b & 0xf0U))) {
        Verilated::overWidthError("b");}
}
#endif  // VL_DEBUG
