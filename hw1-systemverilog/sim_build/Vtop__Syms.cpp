// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtop__pch.h"
#include "Vtop.h"
#include "Vtop___024root.h"

// FUNCTIONS
Vtop__Syms::~Vtop__Syms()
{

    // Tear down scope hierarchy
    __Vhier.remove(0, &__Vscope_rca4);
    __Vhier.remove(&__Vscope_rca4, &__Vscope_rca4__a0);
    __Vhier.remove(&__Vscope_rca4, &__Vscope_rca4__a1);
    __Vhier.remove(&__Vscope_rca4__a0, &__Vscope_rca4__a0__a0);
    __Vhier.remove(&__Vscope_rca4__a0, &__Vscope_rca4__a0__a1);
    __Vhier.remove(&__Vscope_rca4__a0__a0, &__Vscope_rca4__a0__a0__h0);
    __Vhier.remove(&__Vscope_rca4__a0__a0, &__Vscope_rca4__a0__a0__h1);
    __Vhier.remove(&__Vscope_rca4__a0__a1, &__Vscope_rca4__a0__a1__h0);
    __Vhier.remove(&__Vscope_rca4__a0__a1, &__Vscope_rca4__a0__a1__h1);
    __Vhier.remove(&__Vscope_rca4__a1, &__Vscope_rca4__a1__a0);
    __Vhier.remove(&__Vscope_rca4__a1, &__Vscope_rca4__a1__a1);
    __Vhier.remove(&__Vscope_rca4__a1__a0, &__Vscope_rca4__a1__a0__h0);
    __Vhier.remove(&__Vscope_rca4__a1__a0, &__Vscope_rca4__a1__a0__h1);
    __Vhier.remove(&__Vscope_rca4__a1__a1, &__Vscope_rca4__a1__a1__h0);
    __Vhier.remove(&__Vscope_rca4__a1__a1, &__Vscope_rca4__a1__a1__h1);

}

Vtop__Syms::Vtop__Syms(VerilatedContext* contextp, const char* namep, Vtop* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
        // Check resources
        Verilated::stackCheck(25);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-9);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscope_TOP.configure(this, name(), "TOP", "TOP", "<null>", 0, VerilatedScope::SCOPE_OTHER);
    __Vscope_rca4.configure(this, name(), "rca4", "rca4", "rca4", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a0.configure(this, name(), "rca4.a0", "a0", "fulladder2", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a0__a0.configure(this, name(), "rca4.a0.a0", "a0", "fulladder1", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a0__a0__h0.configure(this, name(), "rca4.a0.a0.h0", "h0", "halfadder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a0__a0__h1.configure(this, name(), "rca4.a0.a0.h1", "h1", "halfadder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a0__a1.configure(this, name(), "rca4.a0.a1", "a1", "fulladder1", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a0__a1__h0.configure(this, name(), "rca4.a0.a1.h0", "h0", "halfadder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a0__a1__h1.configure(this, name(), "rca4.a0.a1.h1", "h1", "halfadder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a1.configure(this, name(), "rca4.a1", "a1", "fulladder2", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a1__a0.configure(this, name(), "rca4.a1.a0", "a0", "fulladder1", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a1__a0__h0.configure(this, name(), "rca4.a1.a0.h0", "h0", "halfadder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a1__a0__h1.configure(this, name(), "rca4.a1.a0.h1", "h1", "halfadder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a1__a1.configure(this, name(), "rca4.a1.a1", "a1", "fulladder1", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a1__a1__h0.configure(this, name(), "rca4.a1.a1.h0", "h0", "halfadder", -9, VerilatedScope::SCOPE_MODULE);
    __Vscope_rca4__a1__a1__h1.configure(this, name(), "rca4.a1.a1.h1", "h1", "halfadder", -9, VerilatedScope::SCOPE_MODULE);

    // Set up scope hierarchy
    __Vhier.add(0, &__Vscope_rca4);
    __Vhier.add(&__Vscope_rca4, &__Vscope_rca4__a0);
    __Vhier.add(&__Vscope_rca4, &__Vscope_rca4__a1);
    __Vhier.add(&__Vscope_rca4__a0, &__Vscope_rca4__a0__a0);
    __Vhier.add(&__Vscope_rca4__a0, &__Vscope_rca4__a0__a1);
    __Vhier.add(&__Vscope_rca4__a0__a0, &__Vscope_rca4__a0__a0__h0);
    __Vhier.add(&__Vscope_rca4__a0__a0, &__Vscope_rca4__a0__a0__h1);
    __Vhier.add(&__Vscope_rca4__a0__a1, &__Vscope_rca4__a0__a1__h0);
    __Vhier.add(&__Vscope_rca4__a0__a1, &__Vscope_rca4__a0__a1__h1);
    __Vhier.add(&__Vscope_rca4__a1, &__Vscope_rca4__a1__a0);
    __Vhier.add(&__Vscope_rca4__a1, &__Vscope_rca4__a1__a1);
    __Vhier.add(&__Vscope_rca4__a1__a0, &__Vscope_rca4__a1__a0__h0);
    __Vhier.add(&__Vscope_rca4__a1__a0, &__Vscope_rca4__a1__a0__h1);
    __Vhier.add(&__Vscope_rca4__a1__a1, &__Vscope_rca4__a1__a1__h0);
    __Vhier.add(&__Vscope_rca4__a1__a1, &__Vscope_rca4__a1__a1__h1);

    // Setup export functions
    for (int __Vfinal = 0; __Vfinal < 2; ++__Vfinal) {
        __Vscope_TOP.varInsert(__Vfinal,"a", &(TOP.a), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,1 ,3,0);
        __Vscope_TOP.varInsert(__Vfinal,"b", &(TOP.b), false, VLVT_UINT8,VLVD_IN|VLVF_PUB_RW,1 ,3,0);
        __Vscope_TOP.varInsert(__Vfinal,"carry_out", &(TOP.carry_out), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,0);
        __Vscope_TOP.varInsert(__Vfinal,"sum", &(TOP.sum), false, VLVT_UINT8,VLVD_OUT|VLVF_PUB_RW,1 ,3,0);
        __Vscope_rca4.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,3,0);
        __Vscope_rca4.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,3,0);
        __Vscope_rca4.varInsert(__Vfinal,"carry_out", &(TOP.rca4__DOT__carry_out), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4.varInsert(__Vfinal,"cout0", &(TOP.rca4__DOT__cout0), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4.varInsert(__Vfinal,"sum", &(TOP.rca4__DOT__sum), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,3,0);
        __Vscope_rca4__a0.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a0__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_rca4__a0.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a0__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_rca4__a0.varInsert(__Vfinal,"cin", &(TOP.rca4__DOT__a0__DOT__cin), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a0__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0.varInsert(__Vfinal,"cout_tmp", &(TOP.rca4__DOT__a0__DOT__cout_tmp), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a0__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a0__DOT__a0__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a0__DOT__a0__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"cin", &(TOP.rca4__DOT__a0__DOT__a0__DOT__cin), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a0__DOT__a0__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"cout_tmp1", &(TOP.rca4__DOT__a0__DOT__a0__DOT__cout_tmp1), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"cout_tmp2", &(TOP.rca4__DOT__a0__DOT__a0__DOT__cout_tmp2), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a0__DOT__a0__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0.varInsert(__Vfinal,"s_tmp", &(TOP.rca4__DOT__a0__DOT__a0__DOT__s_tmp), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h0.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h0.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h0.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h0.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h0__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h1.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h1.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h1.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a0__h1.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a0__DOT__a0__DOT__h1__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a0__DOT__a1__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a0__DOT__a1__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"cin", &(TOP.rca4__DOT__a0__DOT__a1__DOT__cin), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a0__DOT__a1__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"cout_tmp1", &(TOP.rca4__DOT__a0__DOT__a1__DOT__cout_tmp1), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"cout_tmp2", &(TOP.rca4__DOT__a0__DOT__a1__DOT__cout_tmp2), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a0__DOT__a1__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1.varInsert(__Vfinal,"s_tmp", &(TOP.rca4__DOT__a0__DOT__a1__DOT__s_tmp), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h0.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h0.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h0.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h0.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h0__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h1.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h1.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h1.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a0__a1__h1.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a0__DOT__a1__DOT__h1__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a1__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_rca4__a1.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a1__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_rca4__a1.varInsert(__Vfinal,"cin", &(TOP.rca4__DOT__a1__DOT__cin), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a1__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1.varInsert(__Vfinal,"cout_tmp", &(TOP.rca4__DOT__a1__DOT__cout_tmp), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a1__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,1 ,1,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a1__DOT__a0__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a1__DOT__a0__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"cin", &(TOP.rca4__DOT__a1__DOT__a0__DOT__cin), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a1__DOT__a0__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"cout_tmp1", &(TOP.rca4__DOT__a1__DOT__a0__DOT__cout_tmp1), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"cout_tmp2", &(TOP.rca4__DOT__a1__DOT__a0__DOT__cout_tmp2), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a1__DOT__a0__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0.varInsert(__Vfinal,"s_tmp", &(TOP.rca4__DOT__a1__DOT__a0__DOT__s_tmp), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h0.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h0.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h0.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h0.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h0__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h1.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h1.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h1.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a0__h1.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a1__DOT__a0__DOT__h1__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a1__DOT__a1__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a1__DOT__a1__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"cin", &(TOP.rca4__DOT__a1__DOT__a1__DOT__cin), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a1__DOT__a1__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"cout_tmp1", &(TOP.rca4__DOT__a1__DOT__a1__DOT__cout_tmp1), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"cout_tmp2", &(TOP.rca4__DOT__a1__DOT__a1__DOT__cout_tmp2), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a1__DOT__a1__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1.varInsert(__Vfinal,"s_tmp", &(TOP.rca4__DOT__a1__DOT__a1__DOT__s_tmp), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h0.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h0.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h0.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h0.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h0__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h1.varInsert(__Vfinal,"a", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__a), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h1.varInsert(__Vfinal,"b", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__b), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h1.varInsert(__Vfinal,"cout", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__cout), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
        __Vscope_rca4__a1__a1__h1.varInsert(__Vfinal,"s", &(TOP.rca4__DOT__a1__DOT__a1__DOT__h1__DOT__s), false, VLVT_UINT8,VLVD_NODIR|VLVF_PUB_RW,0);
    }
}
