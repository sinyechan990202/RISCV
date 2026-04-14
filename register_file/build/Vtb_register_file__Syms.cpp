// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_register_file__Syms.h"
#include "Vtb_register_file.h"



// FUNCTIONS
Vtb_register_file__Syms::Vtb_register_file__Syms(Vtb_register_file* topp, const char* namep)
    // Setup locals
    : __Vm_namep(namep)
    , __Vm_activity(false)
    , __Vm_baseCode(0)
    , __Vm_didInit(false)
    // Setup submodule names
{
    // Pointer to top level
    TOPp = topp;
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOPp->__Vconfigure(this, true);
    // Setup scopes
    __Vscope_tb_register_file.configure(this, name(), "tb_register_file", "tb_register_file", -9, VerilatedScope::SCOPE_OTHER);
}
