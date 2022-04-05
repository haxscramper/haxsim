import ./syntaxes, std/options

type
  ICode* = enum
    opADD_RegMem_B_Reg_B           = (0x00_00_00'u64, "ADD r/m8 r8")
    opADD_RegMem_V_Reg_V           = (0x01_00_00'u64, "ADD r/m16/32 r16/32")
    opADD_Reg_B_RegMem_B           = (0x02_00_00'u64, "ADD r8 r/m8")
    opADD_Reg_V_RegMem_V           = (0x03_00_00'u64, "ADD r16/32 r/m16/32")
    opADD_AL_B_Imm_B               = (0x04_00_00'u64, "ADD AL imm8")
    opADD_EAX_D_Imm_V              = (0x05_00_00'u64, "ADD EAX imm16/32")
    opPUSH_ES_W                    = (0x06_00_00'u64, "PUSH ES")
    opPOP_ES_W                     = (0x07_00_00'u64, "POP ES")
    opOR_RegMem_B_Reg_B            = (0x08_00_00'u64, "OR r/m8 r8")
    opOR_RegMem_V_Reg_V            = (0x09_00_00'u64, "OR r/m16/32 r16/32")
    opOR_Reg_B_RegMem_B            = (0x0A_00_00'u64, "OR r8 r/m8")
    opOR_Reg_V_RegMem_V            = (0x0B_00_00'u64, "OR r16/32 r/m16/32")
    opOR_AL_B_Imm_B                = (0x0C_00_00'u64, "OR AL imm8")
    opOR_EAX_D_Imm_V               = (0x0D_00_00'u64, "OR EAX imm16/32")
    opPUSH_CS_W                    = (0x0E_00_00'u64, "PUSH CS")
    opSLDT_Mem_W_LDTR_W            = (0x0F_00_00'u64, "SLDT m16 LDTR")
    opSTR_Mem_W_TR_W               = (0x0F_00_01'u64, "STR m16 TR")
    opLLDT_LDTR_W_RegMem_W         = (0x0F_00_02'u64, "LLDT LDTR r/m16")
    opLTR_TR_W_RegMem_W            = (0x0F_00_03'u64, "LTR TR r/m16")
    opVERR_RegMem_W                = (0x0F_00_04'u64, "VERR r/m16")
    opVERW_RegMem_W                = (0x0F_00_05'u64, "VERW r/m16")
    opSGDT_Mem_P_GDTR_W            = (0x0F_00_10'u64, "SGDT M16&32 GDTR")
    opSIDT_Mem_P_IDTR_W            = (0x0F_00_11'u64, "SIDT M16&32 IDTR")
    opLGDT_GDTR_W_Mem_P            = (0x0F_00_12'u64, "LGDT GDTR m16&32")
    opLIDT_IDTR_W_Mem_P            = (0x0F_00_13'u64, "LIDT IDTR M16&32")
    opSMSW_Mem_W_MSW_W             = (0x0F_00_14'u64, "SMSW m16 MSW")
    opLMSW_MSW_W_RegMem_W          = (0x0F_00_16'u64, "LMSW MSW r/m16")
    opLAR_Reg_V_Mem_W              = (0x0F_00_20'u64, "LAR r16/32 m16")
    opLSL_Reg_V_Mem_W              = (0x0F_00_30'u64, "LSL r16/32 m16")
    opCLTS_CR_F                    = (0x0F_00_60'u64, "CLTS CR0")
    opUD2                          = (0x0F_00_B0'u64, "UD2")
    opMOV_Reg_D_CR_F               = (0x0F_02_00'u64, "MOV r32 CRn")
    opMOV_Reg_D_DR_F               = (0x0F_02_10'u64, "MOV r32 DRn")
    opMOV_CR_F_Reg_D               = (0x0F_02_20'u64, "MOV CRn r32")
    opMOV_DR_F_Reg_D               = (0x0F_02_30'u64, "MOV DRn r32")
    opJO_Imm_V                     = (0x0F_08_00'u64, "JO rel16/32")
    opJNO_Imm_V                    = (0x0F_08_10'u64, "JNO rel16/32")
    opJB_Imm_V                     = (0x0F_08_20'u64, "JB rel16/32")
    opJNB_Imm_V                    = (0x0F_08_30'u64, "JNB rel16/32")
    opJZ_Imm_V                     = (0x0F_08_40'u64, "JZ rel16/32")
    opJNZ_Imm_V                    = (0x0F_08_50'u64, "JNZ rel16/32")
    opJBE_Imm_V                    = (0x0F_08_60'u64, "JBE rel16/32")
    opJNBE_Imm_V                   = (0x0F_08_70'u64, "JNBE rel16/32")
    opJS_Imm_V                     = (0x0F_08_80'u64, "JS rel16/32")
    opJNS_Imm_V                    = (0x0F_08_90'u64, "JNS rel16/32")
    opJP_Imm_V                     = (0x0F_08_A0'u64, "JP rel16/32")
    opJNP_Imm_V                    = (0x0F_08_B0'u64, "JNP rel16/32")
    opJL_Imm_V                     = (0x0F_08_C0'u64, "JL rel16/32")
    opJNL_Imm_V                    = (0x0F_08_D0'u64, "JNL rel16/32")
    opJLE_Imm_V                    = (0x0F_08_E0'u64, "JLE rel16/32")
    opJNLE_Imm_V                   = (0x0F_08_F0'u64, "JNLE rel16/32")
    opSETO_RegMem_B                = (0x0F_09_00'u64, "SETO r/m8")
    opSETNO_RegMem_B               = (0x0F_09_10'u64, "SETNO r/m8")
    opSETB_RegMem_B                = (0x0F_09_20'u64, "SETB r/m8")
    opSETNB_RegMem_B               = (0x0F_09_30'u64, "SETNB r/m8")
    opSETZ_RegMem_B                = (0x0F_09_40'u64, "SETZ r/m8")
    opSETNZ_RegMem_B               = (0x0F_09_50'u64, "SETNZ r/m8")
    opSETBE_RegMem_B               = (0x0F_09_60'u64, "SETBE r/m8")
    opSETNBE_RegMem_B              = (0x0F_09_70'u64, "SETNBE r/m8")
    opSETS_RegMem_B                = (0x0F_09_80'u64, "SETS r/m8")
    opSETNS_RegMem_B               = (0x0F_09_90'u64, "SETNS r/m8")
    opSETP_RegMem_B                = (0x0F_09_A0'u64, "SETP r/m8")
    opSETNP_RegMem_B               = (0x0F_09_B0'u64, "SETNP r/m8")
    opSETL_RegMem_B                = (0x0F_09_C0'u64, "SETL r/m8")
    opSETNL_RegMem_B               = (0x0F_09_D0'u64, "SETNL r/m8")
    opSETLE_RegMem_B               = (0x0F_09_E0'u64, "SETLE r/m8")
    opSETNLE_RegMem_B              = (0x0F_09_F0'u64, "SETNLE r/m8")
    opPUSH_FS_W                    = (0x0F_0A_00'u64, "PUSH FS")
    opPOP_FS_W                     = (0x0F_0A_10'u64, "POP FS")
    opBT_RegMem_V_Reg_V            = (0x0F_0A_30'u64, "BT r/m16/32 r16/32")
    opSHLD_RegMem_V_Reg_V_Imm_B    = (0x0F_0A_40'u64, "SHLD r/m16/32 r16/32 imm8")
    opSHLD_RegMem_V_Reg_V_CL_B     = (0x0F_0A_50'u64, "SHLD r/m16/32 r16/32 CL")
    opPUSH_GS_B                    = (0x0F_0A_80'u64, "PUSH GS")
    opPOP_GS_B                     = (0x0F_0A_90'u64, "POP GS")
    opBTS_RegMem_V_Reg_V           = (0x0F_0A_B0'u64, "BTS r/m16/32 r16/32")
    opSHRD_RegMem_V_Reg_V_Imm_B    = (0x0F_0A_C0'u64, "SHRD r/m16/32 r16/32 imm8")
    opSHRD_RegMem_V_Reg_V_CL_B     = (0x0F_0A_D0'u64, "SHRD r/m16/32 r16/32 CL")
    opIMUL_Reg_V_RegMem_V          = (0x0F_0A_F0'u64, "IMUL r16/32 r/m16/32")
    opLSS_SS_B_Reg_V_Mem_P         = (0x0F_0B_20'u64, "LSS SS r16/32 m16:16/32")
    opBTR_RegMem_V_Reg_V           = (0x0F_0B_30'u64, "BTR r/m16/32 r16/32")
    opLFS_FS_W_Reg_V_Mem_P         = (0x0F_0B_40'u64, "LFS FS r16/32 m16:16/32")
    opLGS_GS_B_Reg_V_Mem_P         = (0x0F_0B_50'u64, "LGS GS r16/32 m16:16/32")
    opMOVZX_Reg_V_RegMem_B         = (0x0F_0B_60'u64, "MOVZX r16/32 r/m8")
    opMOVZX_Reg_V_RegMem_W         = (0x0F_0B_70'u64, "MOVZX r16/32 r/m16")
    opBT_RegMem_V_Imm_B            = (0x0F_0B_A4'u64, "BT r/m16/32 imm8")
    opBTS_RegMem_V_Imm_B           = (0x0F_0B_A5'u64, "BTS r/m16/32 imm8")
    opBTR_RegMem_V_Imm_B           = (0x0F_0B_A6'u64, "BTR r/m16/32 imm8")
    opBTC_RegMem_V_Imm_B           = (0x0F_0B_A7'u64, "BTC r/m16/32 imm8")
    opBTC_RegMem_V_Reg_V           = (0x0F_0B_B0'u64, "BTC r/m16/32 r16/32")
    opBSF_Reg_V_RegMem_V           = (0x0F_0B_C0'u64, "BSF r16/32 r/m16/32")
    opBSR_Reg_V_RegMem_V           = (0x0F_0B_D0'u64, "BSR r16/32 r/m16/32")
    opMOVSX_Reg_V_RegMem_B         = (0x0F_0B_E0'u64, "MOVSX r16/32 r/m8")
    opMOVSX_Reg_V_RegMem_W         = (0x0F_0B_F0'u64, "MOVSX r16/32 r/m16")
    opADC_RegMem_B_Reg_B           = (0x10_00_00'u64, "ADC r/m8 r8")
    opADC_RegMem_V_Reg_V           = (0x11_00_00'u64, "ADC r/m16/32 r16/32")
    opADC_Reg_B_RegMem_B           = (0x12_00_00'u64, "ADC r8 r/m8")
    opADC_Reg_V_RegMem_V           = (0x13_00_00'u64, "ADC r16/32 r/m16/32")
    opADC_AL_B_Imm_B               = (0x14_00_00'u64, "ADC AL imm8")
    opADC_EAX_D_Imm_V              = (0x15_00_00'u64, "ADC eAX imm16/32")
    opPUSH_SS_B                    = (0x16_00_00'u64, "PUSH SS")
    opPOP_SS_B                     = (0x17_00_00'u64, "POP SS")
    opSBB_RegMem_B_Reg_B           = (0x18_00_00'u64, "SBB r/m8 r8")
    opSBB_RegMem_V_Reg_V           = (0x19_00_00'u64, "SBB r/m16/32 r16/32")
    opSBB_Reg_B_RegMem_B           = (0x1A_00_00'u64, "SBB r8 r/m8")
    opSBB_Reg_V_RegMem_V           = (0x1B_00_00'u64, "SBB r16/32 r/m16/32")
    opSBB_AL_B_Imm_B               = (0x1C_00_00'u64, "SBB AL imm8")
    opSBB_EAX_D_Imm_V              = (0x1D_00_00'u64, "SBB eAX imm16/32")
    opPUSH_DS_W                    = (0x1E_00_00'u64, "PUSH DS")
    opPOP_DS_W                     = (0x1F_00_00'u64, "POP DS")
    opAND_RegMem_B_Reg_B           = (0x20_00_00'u64, "AND r/m8 r8")
    opAND_RegMem_V_Reg_V           = (0x21_00_00'u64, "AND r/m16/32 r16/32")
    opAND_Reg_B_RegMem_B           = (0x22_00_00'u64, "AND r8 r/m8")
    opAND_Reg_V_RegMem_V           = (0x23_00_00'u64, "AND r16/32 r/m16/32")
    opAND_AL_B_Imm_B               = (0x24_00_00'u64, "AND AL imm8")
    opAND_EAX_D_Imm_V              = (0x25_00_00'u64, "AND eAX imm16/32")
    opES_ES_W                      = (0x26_00_00'u64, "ES ES")
    opDAA_AL_B                     = (0x27_00_00'u64, "DAA AL")
    opSUB_RegMem_B_Reg_B           = (0x28_00_00'u64, "SUB r/m8 r8")
    opSUB_RegMem_V_Reg_V           = (0x29_00_00'u64, "SUB r/m16/32 r16/32")
    opSUB_Reg_B_RegMem_B           = (0x2A_00_00'u64, "SUB r8 r/m8")
    opSUB_Reg_V_RegMem_V           = (0x2B_00_00'u64, "SUB r16/32 r/m16/32")
    opSUB_AL_B_Imm_B               = (0x2C_00_00'u64, "SUB AL imm8")
    opSUB_EAX_D_Imm_V              = (0x2D_00_00'u64, "SUB eAX imm16/32")
    opCS_CS_W                      = (0x2E_00_00'u64, "CS CS")
    opDAS_AL_B                     = (0x2F_00_00'u64, "DAS AL")
    opXOR_RegMem_B_Reg_B           = (0x30_00_00'u64, "XOR r/m8 r8")
    opXOR_RegMem_V_Reg_V           = (0x31_00_00'u64, "XOR r/m16/32 r16/32")
    opXOR_Reg_B_RegMem_B           = (0x32_00_00'u64, "XOR r8 r/m8")
    opXOR_Reg_V_RegMem_V           = (0x33_00_00'u64, "XOR r16/32 r/m16/32")
    opXOR_AL_B_Imm_B               = (0x34_00_00'u64, "XOR AL imm8")
    opXOR_EAX_D_Imm_V              = (0x35_00_00'u64, "XOR eAX imm16/32")
    opSS_SS_B                      = (0x36_00_00'u64, "SS SS")
    opAAA_AL_B_AH_B                = (0x37_00_00'u64, "AAA AL AH")
    opCMP_RegMem_B_Reg_B           = (0x38_00_00'u64, "CMP r/m8 r8")
    opCMP_RegMem_V_Reg_V           = (0x39_00_00'u64, "CMP r/m16/32 r16/32")
    opCMP_Reg_B_RegMem_B           = (0x3A_00_00'u64, "CMP r8 r/m8")
    opCMP_Reg_V_RegMem_V           = (0x3B_00_00'u64, "CMP r16/32 r/m16/32")
    opCMP_AL_B_Imm_B               = (0x3C_00_00'u64, "CMP AL imm8")
    opCMP_EAX_D_Imm_V              = (0x3D_00_00'u64, "CMP eAX imm16/32")
    opDS_DS_W                      = (0x3E_00_00'u64, "DS DS")
    opAAS_AL_B_AH_B                = (0x3F_00_00'u64, "AAS AL AH")
    opINC_EAX_D                    = (0x40_00_00'u64, "INC EAX")
    opINC_ECX_D                    = (0x41_00_00'u64, "INC ECX")
    opINC_EDX_D                    = (0x42_00_00'u64, "INC EDX")
    opINC_EBX_D                    = (0x43_00_00'u64, "INC EBX")
    opINC_ESP_D                    = (0x44_00_00'u64, "INC ESP")
    opINC_EBP_D                    = (0x45_00_00'u64, "INC EBP")
    opINC_ESI_D                    = (0x46_00_00'u64, "INC ESI")
    opINC_EDI_D                    = (0x47_00_00'u64, "INC EDI")
    opDEC_EAX_D                    = (0x48_00_00'u64, "DEC EAX")
    opDEC_ECX_D                    = (0x49_00_00'u64, "DEC ECX")
    opDEC_EDX_D                    = (0x4A_00_00'u64, "DEC EDX")
    opDEC_EBX_D                    = (0x4B_00_00'u64, "DEC EBX")
    opDEC_ESP_D                    = (0x4C_00_00'u64, "DEC ESP")
    opDEC_EBP_D                    = (0x4D_00_00'u64, "DEC EBP")
    opDEC_ESI_D                    = (0x4E_00_00'u64, "DEC ESI")
    opDEC_EDI_D                    = (0x4F_00_00'u64, "DEC EDI")
    opPUSH_EAX_D                   = (0x50_00_00'u64, "PUSH EAX")
    opPUSH_ECX_D                   = (0x51_00_00'u64, "PUSH ECX")
    opPUSH_EDX_D                   = (0x52_00_00'u64, "PUSH EDX")
    opPUSH_EBX_D                   = (0x53_00_00'u64, "PUSH EBX")
    opPUSH_ESP_D                   = (0x54_00_00'u64, "PUSH ESP")
    opPUSH_EBP_D                   = (0x55_00_00'u64, "PUSH EBP")
    opPUSH_ESI_D                   = (0x56_00_00'u64, "PUSH ESI")
    opPUSH_EDI_D                   = (0x57_00_00'u64, "PUSH EDI")
    opPOP_EAX_D                    = (0x58_00_00'u64, "POP EAX")
    opPOP_ECX_D                    = (0x59_00_00'u64, "POP ECX")
    opPOP_EDX_D                    = (0x5A_00_00'u64, "POP EDX")
    opPOP_EBX_D                    = (0x5B_00_00'u64, "POP EBX")
    opPOP_ESP_D                    = (0x5C_00_00'u64, "POP ESP")
    opPOP_EBP_D                    = (0x5D_00_00'u64, "POP EBP")
    opPOP_ESI_D                    = (0x5E_00_00'u64, "POP ESI")
    opPOP_EDI_D                    = (0x5F_00_00'u64, "POP EDI")
    opPUSHA_AX_W_CX_W_DX_W_STACK_V = (0x60_00_00'u64, "PUSHA AX CX DX ...")
    opPOPA_DI_W_SI_W_BP_W_STACK_V  = (0x61_00_00'u64, "POPA DI SI BP ...")
    opBOUND_Reg_V_Mem_A_EFLAGS_D   = (0x62_00_00'u64, "BOUND r16/32 m16/32&16/32 eFlags")
    opARPL_RegMem_W_Reg_W          = (0x63_00_00'u64, "ARPL r/m16 r16")
    opFS_FS_W                      = (0x64_00_00'u64, "FS FS")
    opGS_GS_B                      = (0x65_00_00'u64, "GS GS")
    opPUSH_Imm_V                   = (0x68_00_00'u64, "PUSH imm16/32")
    opIMUL_Reg_V_RegMem_V_Imm_V    = (0x69_00_00'u64, "IMUL r16/32 r/m16/32 imm16/32")
    opPUSH_Imm_B                   = (0x6A_00_00'u64, "PUSH imm8")
    opIMUL_Reg_V_RegMem_V_Imm_B    = (0x6B_00_00'u64, "IMUL r16/32 r/m16/32 imm8")
    opINS_Mem_B_DX_W               = (0x6C_00_00'u64, "INS m8 DX")
    opINS_Mem_V_DX_W               = (0x6D_00_00'u64, "INS m16/32 DX")
    opOUTS_DX_W_Mem_B              = (0x6E_00_00'u64, "OUTS DX m8")
    opOUTS_DX_W_Mem_V              = (0x6F_00_00'u64, "OUTS DX m16/32")
    opJO_Imm_B                     = (0x70_00_00'u64, "JO rel8")
    opJNO_Imm_B                    = (0x71_00_00'u64, "JNO rel8")
    opJC_Imm_B                     = (0x72_00_00'u64, "JC rel8")
    opJNC_Imm_B                    = (0x73_00_00'u64, "JNC rel8")
    opJZ_Imm_B                     = (0x74_00_00'u64, "JZ rel8")
    opJNZ_Imm_B                    = (0x75_00_00'u64, "JNZ rel8")
    opJBE_Imm_B                    = (0x76_00_00'u64, "JBE rel8")
    opJNBE_Imm_B                   = (0x77_00_00'u64, "JNBE rel8")
    opJS_Imm_B                     = (0x78_00_00'u64, "JS rel8")
    opJNS_Imm_B                    = (0x79_00_00'u64, "JNS rel8")
    opJP_Imm_B                     = (0x7A_00_00'u64, "JP rel8")
    opJNP_Imm_B                    = (0x7B_00_00'u64, "JNP rel8")
    opJL_Imm_B                     = (0x7C_00_00'u64, "JL rel8")
    opJNL_Imm_B                    = (0x7D_00_00'u64, "JNL rel8")
    opJLE_Imm_B                    = (0x7E_00_00'u64, "JLE rel8")
    opJG_Imm_B                     = (0x7F_00_00'u64, "JG rel8")
    opADD_RegMem_B_Imm_B           = (0x80_00_00'u64, "ADD r/m8 imm8")
    opOR_RegMem_B_Imm_B            = (0x80_00_01'u64, "OR r/m8 imm8")
    opADC_RegMem_B_Imm_B           = (0x80_00_02'u64, "ADC r/m8 imm8")
    opSBB_RegMem_B_Imm_B           = (0x80_00_03'u64, "SBB r/m8 imm8")
    opAND_RegMem_B_Imm_B           = (0x80_00_04'u64, "AND r/m8 imm8")
    opSUB_RegMem_B_Imm_B           = (0x80_00_05'u64, "SUB r/m8 imm8")
    opXOR_RegMem_B_Imm_B           = (0x80_00_06'u64, "XOR r/m8 imm8")
    opCMP_RegMem_B_Imm_B           = (0x80_00_07'u64, "CMP r/m8 imm8")
    opADD_RegMem_V_Imm_V           = (0x81_00_00'u64, "ADD r/m16/32 imm16/32")
    opOR_RegMem_V_Imm_V            = (0x81_00_01'u64, "OR r/m16/32 imm16/32")
    opADC_RegMem_V_Imm_V           = (0x81_00_02'u64, "ADC r/m16/32 imm16/32")
    opSBB_RegMem_V_Imm_V           = (0x81_00_03'u64, "SBB r/m16/32 imm16/32")
    opAND_RegMem_V_Imm_V           = (0x81_00_04'u64, "AND r/m16/32 imm16/32")
    opSUB_RegMem_V_Imm_V           = (0x81_00_05'u64, "SUB r/m16/32 imm16/32")
    opXOR_RegMem_V_Imm_V           = (0x81_00_06'u64, "XOR r/m16/32 imm16/32")
    opCMP_RegMem_V_Imm_V           = (0x81_00_07'u64, "CMP r/m16/32 imm16/32")
    opTEST_RegMem_B_Reg_B          = (0x84_00_00'u64, "TEST r/m8 r8")
    opTEST_RegMem_V_Reg_V          = (0x85_00_00'u64, "TEST r/m16/32 r16/32")
    opXCHG_Reg_B_RegMem_B          = (0x86_00_00'u64, "XCHG r8 r/m8")
    opXCHG_Reg_V_RegMem_V          = (0x87_00_00'u64, "XCHG r16/32 r/m16/32")
    opMOV_RegMem_B_Reg_B           = (0x88_00_00'u64, "MOV r/m8 r8")
    opMOV_RegMem_V_Reg_V           = (0x89_00_00'u64, "MOV r/m16/32 r16/32")
    opMOV_Reg_B_RegMem_B           = (0x8A_00_00'u64, "MOV r8 r/m8")
    opMOV_Reg_V_RegMem_V           = (0x8B_00_00'u64, "MOV r16/32 r/m16/32")
    opMOV_Mem_W_SREG_W             = (0x8C_00_00'u64, "MOV m16 Sreg")
    opLEA_Reg_V_Mem_V              = (0x8D_00_00'u64, "LEA r16/32 m16/32")
    opMOV_SREG_W_RegMem_W          = (0x8E_00_00'u64, "MOV Sreg r/m16")
    opPOP_RegMem_V                 = (0x8F_00_00'u64, "POP r/m16/32")
    opXCHG_EAX_D_EAX_D             = (0x90_00_00'u64, "XCHG EAX eAX")
    opXCHG_ECX_D_EAX_D             = (0x91_00_00'u64, "XCHG ECX eAX")
    opXCHG_EDX_D_EAX_D             = (0x92_00_00'u64, "XCHG EDX eAX")
    opXCHG_EBX_D_EAX_D             = (0x93_00_00'u64, "XCHG EBX eAX")
    opXCHG_ESP_D_EAX_D             = (0x94_00_00'u64, "XCHG ESP eAX")
    opXCHG_EBP_D_EAX_D             = (0x95_00_00'u64, "XCHG EBP eAX")
    opXCHG_ESI_D_EAX_D             = (0x96_00_00'u64, "XCHG ESI eAX")
    opXCHG_EDI_D_EAX_D             = (0x97_00_00'u64, "XCHG EDI eAX")
    opCWDE_EAX_D_AX_W              = (0x98_00_00'u64, "CWDE EAX AX")
    opCDQ_EDX_D_EAX_D              = (0x99_00_00'u64, "CDQ EDX EAX")
    opCALLF_A_P                    = (0x9A_00_00'u64, "CALLF ptr16:16/32")
    opPUSHFD_EFLAGS_D              = (0x9C_00_00'u64, "PUSHFD EFlags")
    opPOPFD_EFLAGS_D               = (0x9D_00_00'u64, "POPFD EFlags")
    opSAHF_AH_B                    = (0x9E_00_00'u64, "SAHF AH")
    opLAHF_AH_B                    = (0x9F_00_00'u64, "LAHF AH")
    opMOV_AL_B_Imm_B               = (0xA0_00_00'u64, "MOV AL moffs8")
    opMOV_EAX_D_Imm_V              = (0xA1_00_00'u64, "MOV eAX moffs16/32")
    opMOV_Imm_B_AL_B               = (0xA2_00_00'u64, "MOV moffs8 AL")
    opMOV_Imm_V_EAX_D              = (0xA3_00_00'u64, "MOV moffs16/32 eAX")
    opMOVS_Mem_B_Mem_B             = (0xA4_00_00'u64, "MOVS m8 m8")
    opMOVS_Mem_V_Mem_V             = (0xA5_00_00'u64, "MOVS m16/32 m16/32")
    opCMPS_Mem_B_Mem_B             = (0xA6_00_00'u64, "CMPS m8 m8")
    opCMPS_Mem_V_Mem_V             = (0xA7_00_00'u64, "CMPS m16/32 m16/32")
    opTEST_AL_B_Imm_B              = (0xA8_00_00'u64, "TEST AL imm8")
    opTEST_EAX_D_Imm_V             = (0xA9_00_00'u64, "TEST eAX imm16/32")
    opSTOS_Mem_B_AL_B              = (0xAA_00_00'u64, "STOS m8 AL")
    opSTOS_Mem_V_EAX_D             = (0xAB_00_00'u64, "STOS m16/32 eAX")
    opLODS_AL_B_Mem_B              = (0xAC_00_00'u64, "LODS AL m8")
    opLODS_EAX_D_Mem_V             = (0xAD_00_00'u64, "LODS eAX m16/32")
    opSCAS_Mem_B_AL_B              = (0xAE_00_00'u64, "SCAS m8 AL")
    opSCAS_Mem_V_EAX_D             = (0xAF_00_00'u64, "SCAS m16/32 eAX")
    opMOV_Reg_B_Imm_B              = (0xB0_00_00'u64, "MOV r8 imm8")
    opMOV_Reg_V_Imm_V              = (0xB8_00_00'u64, "MOV r16/32 imm16/32")
    opROL_RegMem_B_Imm_B           = (0xC0_00_00'u64, "ROL r/m8 imm8")
    opROR_RegMem_B_Imm_B           = (0xC0_00_01'u64, "ROR r/m8 imm8")
    opRCL_RegMem_B_Imm_B           = (0xC0_00_02'u64, "RCL r/m8 imm8")
    opRCR_RegMem_B_Imm_B           = (0xC0_00_03'u64, "RCR r/m8 imm8")
    opSHL_RegMem_B_Imm_B           = (0xC0_00_04'u64, "SHL r/m8 imm8")
    opSHR_RegMem_B_Imm_B           = (0xC0_00_05'u64, "SHR r/m8 imm8")
    opSAL_RegMem_B_Imm_B           = (0xC0_00_06'u64, "SAL r/m8 imm8")
    opSAR_RegMem_B_Imm_B           = (0xC0_00_07'u64, "SAR r/m8 imm8")
    opROL_RegMem_V_Imm_B           = (0xC1_00_00'u64, "ROL r/m16/32 imm8")
    opROR_RegMem_V_Imm_B           = (0xC1_00_01'u64, "ROR r/m16/32 imm8")
    opRCL_RegMem_V_Imm_B           = (0xC1_00_02'u64, "RCL r/m16/32 imm8")
    opRCR_RegMem_V_Imm_B           = (0xC1_00_03'u64, "RCR r/m16/32 imm8")
    opSHL_RegMem_V_Imm_B           = (0xC1_00_04'u64, "SHL r/m16/32 imm8")
    opSHR_RegMem_V_Imm_B           = (0xC1_00_05'u64, "SHR r/m16/32 imm8")
    opSAL_RegMem_V_Imm_B           = (0xC1_00_06'u64, "SAL r/m16/32 imm8")
    opSAR_RegMem_V_Imm_B           = (0xC1_00_07'u64, "SAR r/m16/32 imm8")
    opRETN_Imm_W                   = (0xC2_00_00'u64, "RETN imm16")
    opRETN                         = (0xC3_00_00'u64, "RETN")
    opLES_ES_W_Reg_V_Mem_P         = (0xC4_00_00'u64, "LES ES r16/32 m16:16/32")
    opLDS_DS_W_Reg_V_Mem_P         = (0xC5_00_00'u64, "LDS DS r16/32 m16:16/32")
    opMOV_RegMem_B_Imm_B           = (0xC6_00_00'u64, "MOV r/m8 imm8")
    opMOV_RegMem_V_Imm_V           = (0xC7_00_00'u64, "MOV r/m16/32 imm16/32")
    opENTER_EBP_D_Imm_W_Imm_B      = (0xC8_00_00'u64, "ENTER eBP imm16 imm8")
    opLEAVE_EBP_D                  = (0xC9_00_00'u64, "LEAVE eBP")
    opRETF_Imm_W                   = (0xCA_00_00'u64, "RETF imm16")
    opRETF                         = (0xCB_00_00'u64, "RETF")
    opINT_Three_B_EFLAGS_D         = (0xCC_00_00'u64, "INT 3 eFlags")
    opINT_Imm_B_EFLAGS_D           = (0xCD_00_00'u64, "INT imm8 eFlags")
    opINTO_EFLAGS_D                = (0xCE_00_00'u64, "INTO eFlags")
    opIRET_EFLAGS_D                = (0xCF_00_00'u64, "IRET eFlags")
    opROL_RegMem_B_One_B           = (0xD0_00_00'u64, "ROL r/m8 1")
    opROR_RegMem_B_One_B           = (0xD0_00_01'u64, "ROR r/m8 1")
    opRCL_RegMem_B_One_B           = (0xD0_00_02'u64, "RCL r/m8 1")
    opRCR_RegMem_B_One_B           = (0xD0_00_03'u64, "RCR r/m8 1")
    opSHL_RegMem_B_One_B           = (0xD0_00_04'u64, "SHL r/m8 1")
    opSHR_RegMem_B_One_B           = (0xD0_00_05'u64, "SHR r/m8 1")
    opSAL_RegMem_B_One_B           = (0xD0_00_06'u64, "SAL r/m8 1")
    opSAR_RegMem_B_One_B           = (0xD0_00_07'u64, "SAR r/m8 1")
    opROL_RegMem_V_One_B           = (0xD1_00_00'u64, "ROL r/m16/32 1")
    opROR_RegMem_V_One_B           = (0xD1_00_01'u64, "ROR r/m16/32 1")
    opRCL_RegMem_V_One_B           = (0xD1_00_02'u64, "RCL r/m16/32 1")
    opRCR_RegMem_V_One_B           = (0xD1_00_03'u64, "RCR r/m16/32 1")
    opSHL_RegMem_V_One_B           = (0xD1_00_04'u64, "SHL r/m16/32 1")
    opSHR_RegMem_V_One_B           = (0xD1_00_05'u64, "SHR r/m16/32 1")
    opSAL_RegMem_V_One_B           = (0xD1_00_06'u64, "SAL r/m16/32 1")
    opSAR_RegMem_V_One_B           = (0xD1_00_07'u64, "SAR r/m16/32 1")
    opROL_RegMem_B_CL_B            = (0xD2_00_00'u64, "ROL r/m8 CL")
    opROR_RegMem_B_CL_B            = (0xD2_00_01'u64, "ROR r/m8 CL")
    opRCL_RegMem_B_CL_B            = (0xD2_00_02'u64, "RCL r/m8 CL")
    opRCR_RegMem_B_CL_B            = (0xD2_00_03'u64, "RCR r/m8 CL")
    opSHL_RegMem_B_CL_B            = (0xD2_00_04'u64, "SHL r/m8 CL")
    opSHR_RegMem_B_CL_B            = (0xD2_00_05'u64, "SHR r/m8 CL")
    opSAL_RegMem_B_CL_B            = (0xD2_00_06'u64, "SAL r/m8 CL")
    opSAR_RegMem_B_CL_B            = (0xD2_00_07'u64, "SAR r/m8 CL")
    opROL_RegMem_V_CL_B            = (0xD3_00_00'u64, "ROL r/m16/32 CL")
    opROR_RegMem_V_CL_B            = (0xD3_00_01'u64, "ROR r/m16/32 CL")
    opRCL_RegMem_V_CL_B            = (0xD3_00_02'u64, "RCL r/m16/32 CL")
    opRCR_RegMem_V_CL_B            = (0xD3_00_03'u64, "RCR r/m16/32 CL")
    opSHL_RegMem_V_CL_B            = (0xD3_00_04'u64, "SHL r/m16/32 CL")
    opSHR_RegMem_V_CL_B            = (0xD3_00_05'u64, "SHR r/m16/32 CL")
    opSAL_RegMem_V_CL_B            = (0xD3_00_06'u64, "SAL r/m16/32 CL")
    opSAR_RegMem_V_CL_B            = (0xD3_00_07'u64, "SAR r/m16/32 CL")
    opAMX_AL_B_AH_B_Imm_B          = (0xD4_00_00'u64, "AMX AL AH imm8")
    opAAM_AL_B_AH_B                = (0xD4_00_A0'u64, "AAM AL AH")
    opADX_AL_B_AH_B_Imm_B          = (0xD5_00_00'u64, "ADX AL AH imm8")
    opAAD_AL_B_AH_B                = (0xD5_00_A0'u64, "AAD AL AH")
    opSALC_AL_B                    = (0xD6_00_00'u64, "SALC AL")
    opXLAT_AL_B_Mem_B              = (0xD7_00_00'u64, "XLAT AL m8")
    opLOOPNZ_ECX_D_Imm_B           = (0xE0_00_00'u64, "LOOPNZ eCX rel8")
    opLOOPZ_ECX_D_Imm_B            = (0xE1_00_00'u64, "LOOPZ eCX rel8")
    opLOOP_ECX_D_Imm_B             = (0xE2_00_00'u64, "LOOP eCX rel8")
    opJCXZ_Imm_B_CX_W              = (0xE3_00_00'u64, "JCXZ rel8 CX")
    opIN_AL_B_Imm_B                = (0xE4_00_00'u64, "IN AL imm8")
    opIN_EAX_D_Imm_B               = (0xE5_00_00'u64, "IN eAX imm8")
    opOUT_Imm_B_AL_B               = (0xE6_00_00'u64, "OUT imm8 AL")
    opOUT_Imm_B_EAX_D              = (0xE7_00_00'u64, "OUT imm8 eAX")
    opCALL_Imm_V                   = (0xE8_00_00'u64, "CALL rel16/32")
    opJMP_Imm_V                    = (0xE9_00_00'u64, "JMP rel16/32")
    opJMPF_A_P                     = (0xEA_00_00'u64, "JMPF ptr16:16/32")
    opJMP_Imm_B                    = (0xEB_00_00'u64, "JMP rel8")
    opIN_AL_B_DX_W                 = (0xEC_00_00'u64, "IN AL DX")
    opIN_EAX_D_DX_W                = (0xED_00_00'u64, "IN eAX DX")
    opOUT_DX_W_AL_B                = (0xEE_00_00'u64, "OUT DX AL")
    opOUT_DX_W_EAX_D               = (0xEF_00_00'u64, "OUT DX eAX")
    opLOCK                         = (0xF0_00_00'u64, "LOCK")
    opINT1_EFLAGS_D                = (0xF1_00_00'u64, "INT1 eFlags")
    opREPNZ_ECX_D                  = (0xF2_00_00'u64, "REPNZ eCX")
    opREPZ_ECX_D                   = (0xF3_00_00'u64, "REPZ eCX")
    opHLT                          = (0xF4_00_00'u64, "HLT")
    opCMC                          = (0xF5_00_00'u64, "CMC")
    opTEST_RegMem_B_Imm_B          = (0xF6_00_00'u64, "TEST r/m8 imm8")
    opNOT_RegMem_B                 = (0xF6_00_02'u64, "NOT r/m8")
    opNEG_RegMem_B                 = (0xF6_00_03'u64, "NEG r/m8")
    opMUL_AX_W_AL_B_RegMem_B       = (0xF6_00_04'u64, "MUL AX AL r/m8")
    opIMUL_AX_W_AL_B_RegMem_B      = (0xF6_00_05'u64, "IMUL AX AL r/m8")
    opDIV_AL_B_AH_B_AX_W_RegMem_B  = (0xF6_00_06'u64, "DIV AL AH AX r/m8")
    opIDIV_AL_B_AH_B_AX_W_RegMem_B = (0xF6_00_07'u64, "IDIV AL AH AX r/m8")
    opTEST_RegMem_V_Imm_V          = (0xF7_00_00'u64, "TEST r/m16/32 imm16/32")
    opNOT_RegMem_V                 = (0xF7_00_02'u64, "NOT r/m16/32")
    opNEG_RegMem_V                 = (0xF7_00_03'u64, "NEG r/m16/32")
    opMUL_EDX_D_EAX_D_RegMem_V     = (0xF7_00_04'u64, "MUL eDX eAX r/m16/32")
    opIMUL_EDX_D_EAX_D_RegMem_V    = (0xF7_00_05'u64, "IMUL eDX eAX r/m16/32")
    opDIV_EDX_D_EAX_D_RegMem_V     = (0xF7_00_06'u64, "DIV eDX eAX r/m16/32")
    opIDIV_EDX_D_EAX_D_RegMem_V    = (0xF7_00_07'u64, "IDIV eDX eAX r/m16/32")
    opCLC                          = (0xF8_00_00'u64, "CLC")
    opSTC                          = (0xF9_00_00'u64, "STC")
    opCLI                          = (0xFA_00_00'u64, "CLI")
    opSTI                          = (0xFB_00_00'u64, "STI")
    opCLD                          = (0xFC_00_00'u64, "CLD")
    opSTD                          = (0xFD_00_00'u64, "STD")
    opINC_RegMem_B                 = (0xFE_00_00'u64, "INC r/m8")
    opDEC_RegMem_B                 = (0xFE_00_01'u64, "DEC r/m8")
    opINC_RegMem_V                 = (0xFF_00_00'u64, "INC r/m16/32")
    opDEC_RegMem_V                 = (0xFF_00_01'u64, "DEC r/m16/32")
    opCALL_RegMem_V                = (0xFF_00_02'u64, "CALL r/m16/32")
    opCALLF_Mem_P                  = (0xFF_00_03'u64, "CALLF m16:16/32")
    opJMP_RegMem_V                 = (0xFF_00_04'u64, "JMP r/m16/32")
    opJMPF_Mem_P                   = (0xFF_00_05'u64, "JMPF m16:16/32")
    opPUSH_RegMem_V                = (0xFF_00_06'u64, "PUSH r/m16/32")
  ICodeMnemonic* = enum
    opMneMOVSX        = "MOVSX"
    opMnePOPFD        = "POPFD"
    opMneJZ           = "JZ"
    opMneSTR          = "STR"
    opMneSIDT         = "SIDT"
    opMneDAS          = "DAS"
    opMneSS           = "SS"
    opMneSTOS         = "STOS"
    opMneSCAS         = "SCAS"
    opMneJP           = "JP"
    opMneDAA          = "DAA"
    opMneTEST         = "TEST"
    opMneLAR          = "LAR"
    opMneRETN         = "RETN"
    opMneLOOP         = "LOOP"
    opMneNEG          = "NEG"
    opMneSTI          = "STI"
    opMneSETS         = "SETS"
    opMneOUT          = "OUT"
    opMneNOT          = "NOT"
    opMneSTD          = "STD"
    opMneDS           = "DS"
    opMneSETNL        = "SETNL"
    opMneLLDT         = "LLDT"
    opMneREPZ         = "REPZ"
    opMneCLTS         = "CLTS"
    opMneGS           = "GS"
    opMneVERR         = "VERR"
    opMneJNBE         = "JNBE"
    opMneLEA          = "LEA"
    opMneJC           = "JC"
    opMneVERW         = "VERW"
    opMneLMSW         = "LMSW"
    opMneJB           = "JB"
    opMneIDIV         = "IDIV"
    opMneAAA          = "AAA"
    opMneSMSW         = "SMSW"
    opMneAND          = "AND"
    opMneSHLD         = "SHLD"
    opMnePOP          = "POP"
    opMneXOR          = "XOR"
    opMneCWDE         = "CWDE"
    opMneLOCK         = "LOCK"
    opMneCMC          = "CMC"
    opMneSETL         = "SETL"
    opMneJNLE         = "JNLE"
    opMneBTS          = "BTS"
    opMneSETNBE       = "SETNBE"
    opMneCS           = "CS"
    opMneHLT          = "HLT"
    opMneLODS         = "LODS"
    opMneJG           = "JG"
    opMneROR          = "ROR"
    opMneIRET         = "IRET"
    opMneJNP          = "JNP"
    opMneSBB          = "SBB"
    opMneLES          = "LES"
    opMneSETZ         = "SETZ"
    opMneAAM          = "AAM"
    opMneADD          = "ADD"
    opMneJNZ          = "JNZ"
    opMneLAHF         = "LAHF"
    opMneADX          = "ADX"
    opMneINT1         = "INT1"
    opMneBSF          = "BSF"
    opMneCLI          = "CLI"
    opMneAMX          = "AMX"
    opMneJNC          = "JNC"
    opMneJBE          = "JBE"
    opMneLTR          = "LTR"
    opMneAAS          = "AAS"
    opMneSETO         = "SETO"
    opMnePUSHA        = "PUSHA"
    opMneJNS          = "JNS"
    opMneSETNB        = "SETNB"
    opMneFS           = "FS"
    opMneBT           = "BT"
    opMneINS          = "INS"
    opMneLGS          = "LGS"
    opMneLFS          = "LFS"
    opMneLOOPNZ       = "LOOPNZ"
    opMneSETB         = "SETB"
    opMneAAD          = "AAD"
    opMneLIDT         = "LIDT"
    opMneBOUND        = "BOUND"
    opMneDEC          = "DEC"
    opMneCLC          = "CLC"
    opMneLDS          = "LDS"
    opMneSHR          = "SHR"
    opMneSLDT         = "SLDT"
    opMneCALLF        = "CALLF"
    opMneSGDT         = "SGDT"
    opMneSUB          = "SUB"
    opMneOUTS         = "OUTS"
    opMneIMUL         = "IMUL"
    opMneINT          = "INT"
    opMneLSS          = "LSS"
    opMneCALL         = "CALL"
    opMneARPL         = "ARPL"
    opMneINTO         = "INTO"
    opMneJMP          = "JMP"
    opMneSTC          = "STC"
    opMneXLAT         = "XLAT"
    opMneCDQ          = "CDQ"
    opMneCMPS         = "CMPS"
    opMneSETNLE       = "SETNLE"
    opMneSAR          = "SAR"
    opMneES           = "ES"
    opMneSALC         = "SALC"
    opMneINC          = "INC"
    opMneCMP          = "CMP"
    opMneJCXZ         = "JCXZ"
    opMneBTC          = "BTC"
    opMnePUSH         = "PUSH"
    opMneSETP         = "SETP"
    opMneMUL          = "MUL"
    opMneDIV          = "DIV"
    opMneJNB          = "JNB"
    opMneJS           = "JS"
    opMneSHL          = "SHL"
    opMneLSL          = "LSL"
    opMneJNO          = "JNO"
    opMneCLD          = "CLD"
    opMneSHRD         = "SHRD"
    opMneSAHF         = "SAHF"
    opMneSETNP        = "SETNP"
    opMneROL          = "ROL"
    opMneSAL          = "SAL"
    opMneJMPF         = "JMPF"
    opMneRCR          = "RCR"
    opMneJL           = "JL"
    opMnePOPA         = "POPA"
    opMneREPNZ        = "REPNZ"
    opMneLOOPZ        = "LOOPZ"
    opMneRCL          = "RCL"
    opMneSETNO        = "SETNO"
    opMnePUSHFD       = "PUSHFD"
    opMneRETF         = "RETF"
    opMneSETLE        = "SETLE"
    opMneUD2          = "UD2"
    opMneSETNZ        = "SETNZ"
    opMneMOVS         = "MOVS"
    opMneMOV          = "MOV"
    opMneSETNS        = "SETNS"
    opMneBTR          = "BTR"
    opMneLGDT         = "LGDT"
    opMneADC          = "ADC"
    opMneJO           = "JO"
    opMneSETBE        = "SETBE"
    opMneLEAVE        = "LEAVE"
    opMneBSR          = "BSR"
    opMneJNL          = "JNL"
    opMneOR           = "OR"
    opMneJLE          = "JLE"
    opMneIN           = "IN"
    opMneENTER        = "ENTER"
    opMneMOVZX        = "MOVZX"
    opMneXCHG         = "XCHG"

func getOpcodes*(code: ICodeMnemonic): seq[ICode] =
  case code:
    of opMneMOVSX       : @[ opMOVSX_Reg_V_RegMem_B, opMOVSX_Reg_V_RegMem_W ]
    of opMnePOPFD       : @[ opPOPFD_EFLAGS_D ]
    of opMneJZ          : @[ opJZ_Imm_V, opJZ_Imm_B ]
    of opMneSTR         : @[ opSTR_Mem_W_TR_W ]
    of opMneSIDT        : @[ opSIDT_Mem_P_IDTR_W ]
    of opMneDAS         : @[ opDAS_AL_B ]
    of opMneSS          : @[ opSS_SS_B ]
    of opMneSTOS        : @[ opSTOS_Mem_B_AL_B, opSTOS_Mem_V_EAX_D ]
    of opMneSCAS        : @[ opSCAS_Mem_B_AL_B, opSCAS_Mem_V_EAX_D ]
    of opMneJP          : @[ opJP_Imm_V, opJP_Imm_B ]
    of opMneDAA         : @[ opDAA_AL_B ]
    of opMneTEST        : @[ opTEST_RegMem_B_Reg_B, opTEST_RegMem_V_Reg_V, opTEST_AL_B_Imm_B, opTEST_EAX_D_Imm_V, opTEST_RegMem_B_Imm_B, opTEST_RegMem_V_Imm_V ]
    of opMneLAR         : @[ opLAR_Reg_V_Mem_W ]
    of opMneRETN        : @[ opRETN_Imm_W, opRETN ]
    of opMneLOOP        : @[ opLOOP_ECX_D_Imm_B ]
    of opMneNEG         : @[ opNEG_RegMem_B, opNEG_RegMem_V ]
    of opMneSTI         : @[ opSTI ]
    of opMneSETS        : @[ opSETS_RegMem_B ]
    of opMneOUT         : @[ opOUT_Imm_B_AL_B, opOUT_Imm_B_EAX_D, opOUT_DX_W_AL_B, opOUT_DX_W_EAX_D ]
    of opMneNOT         : @[ opNOT_RegMem_B, opNOT_RegMem_V ]
    of opMneSTD         : @[ opSTD ]
    of opMneDS          : @[ opDS_DS_W ]
    of opMneSETNL       : @[ opSETNL_RegMem_B ]
    of opMneLLDT        : @[ opLLDT_LDTR_W_RegMem_W ]
    of opMneREPZ        : @[ opREPZ_ECX_D ]
    of opMneCLTS        : @[ opCLTS_CR_F ]
    of opMneGS          : @[ opGS_GS_B ]
    of opMneVERR        : @[ opVERR_RegMem_W ]
    of opMneJNBE        : @[ opJNBE_Imm_V, opJNBE_Imm_B ]
    of opMneLEA         : @[ opLEA_Reg_V_Mem_V ]
    of opMneJC          : @[ opJC_Imm_B ]
    of opMneVERW        : @[ opVERW_RegMem_W ]
    of opMneLMSW        : @[ opLMSW_MSW_W_RegMem_W ]
    of opMneJB          : @[ opJB_Imm_V ]
    of opMneIDIV        : @[ opIDIV_AL_B_AH_B_AX_W_RegMem_B, opIDIV_EDX_D_EAX_D_RegMem_V ]
    of opMneAAA         : @[ opAAA_AL_B_AH_B ]
    of opMneSMSW        : @[ opSMSW_Mem_W_MSW_W ]
    of opMneAND         : @[ opAND_RegMem_B_Reg_B, opAND_RegMem_V_Reg_V, opAND_Reg_B_RegMem_B, opAND_Reg_V_RegMem_V, opAND_AL_B_Imm_B, opAND_EAX_D_Imm_V, opAND_RegMem_B_Imm_B, opAND_RegMem_V_Imm_V ]
    of opMneSHLD        : @[ opSHLD_RegMem_V_Reg_V_Imm_B, opSHLD_RegMem_V_Reg_V_CL_B ]
    of opMnePOP         : @[ opPOP_ES_W, opPOP_FS_W, opPOP_GS_B, opPOP_SS_B, opPOP_DS_W, opPOP_EAX_D, opPOP_ECX_D, opPOP_EDX_D, opPOP_EBX_D, opPOP_ESP_D, opPOP_EBP_D, opPOP_ESI_D, opPOP_EDI_D, opPOP_RegMem_V ]
    of opMneXOR         : @[ opXOR_RegMem_B_Reg_B, opXOR_RegMem_V_Reg_V, opXOR_Reg_B_RegMem_B, opXOR_Reg_V_RegMem_V, opXOR_AL_B_Imm_B, opXOR_EAX_D_Imm_V, opXOR_RegMem_B_Imm_B, opXOR_RegMem_V_Imm_V ]
    of opMneCWDE        : @[ opCWDE_EAX_D_AX_W ]
    of opMneLOCK        : @[ opLOCK ]
    of opMneCMC         : @[ opCMC ]
    of opMneSETL        : @[ opSETL_RegMem_B ]
    of opMneJNLE        : @[ opJNLE_Imm_V ]
    of opMneBTS         : @[ opBTS_RegMem_V_Reg_V, opBTS_RegMem_V_Imm_B ]
    of opMneSETNBE      : @[ opSETNBE_RegMem_B ]
    of opMneCS          : @[ opCS_CS_W ]
    of opMneHLT         : @[ opHLT ]
    of opMneLODS        : @[ opLODS_AL_B_Mem_B, opLODS_EAX_D_Mem_V ]
    of opMneJG          : @[ opJG_Imm_B ]
    of opMneROR         : @[ opROR_RegMem_B_Imm_B, opROR_RegMem_V_Imm_B, opROR_RegMem_B_One_B, opROR_RegMem_V_One_B, opROR_RegMem_B_CL_B, opROR_RegMem_V_CL_B ]
    of opMneIRET        : @[ opIRET_EFLAGS_D ]
    of opMneJNP         : @[ opJNP_Imm_V, opJNP_Imm_B ]
    of opMneSBB         : @[ opSBB_RegMem_B_Reg_B, opSBB_RegMem_V_Reg_V, opSBB_Reg_B_RegMem_B, opSBB_Reg_V_RegMem_V, opSBB_AL_B_Imm_B, opSBB_EAX_D_Imm_V, opSBB_RegMem_B_Imm_B, opSBB_RegMem_V_Imm_V ]
    of opMneLES         : @[ opLES_ES_W_Reg_V_Mem_P ]
    of opMneSETZ        : @[ opSETZ_RegMem_B ]
    of opMneAAM         : @[ opAAM_AL_B_AH_B ]
    of opMneADD         : @[ opADD_RegMem_B_Reg_B, opADD_RegMem_V_Reg_V, opADD_Reg_B_RegMem_B, opADD_Reg_V_RegMem_V, opADD_AL_B_Imm_B, opADD_EAX_D_Imm_V, opADD_RegMem_B_Imm_B, opADD_RegMem_V_Imm_V ]
    of opMneJNZ         : @[ opJNZ_Imm_V, opJNZ_Imm_B ]
    of opMneLAHF        : @[ opLAHF_AH_B ]
    of opMneADX         : @[ opADX_AL_B_AH_B_Imm_B ]
    of opMneINT1        : @[ opINT1_EFLAGS_D ]
    of opMneBSF         : @[ opBSF_Reg_V_RegMem_V ]
    of opMneCLI         : @[ opCLI ]
    of opMneAMX         : @[ opAMX_AL_B_AH_B_Imm_B ]
    of opMneJNC         : @[ opJNC_Imm_B ]
    of opMneJBE         : @[ opJBE_Imm_V, opJBE_Imm_B ]
    of opMneLTR         : @[ opLTR_TR_W_RegMem_W ]
    of opMneAAS         : @[ opAAS_AL_B_AH_B ]
    of opMneSETO        : @[ opSETO_RegMem_B ]
    of opMnePUSHA       : @[ opPUSHA_AX_W_CX_W_DX_W_STACK_V ]
    of opMneJNS         : @[ opJNS_Imm_V, opJNS_Imm_B ]
    of opMneSETNB       : @[ opSETNB_RegMem_B ]
    of opMneFS          : @[ opFS_FS_W ]
    of opMneBT          : @[ opBT_RegMem_V_Reg_V, opBT_RegMem_V_Imm_B ]
    of opMneINS         : @[ opINS_Mem_B_DX_W, opINS_Mem_V_DX_W ]
    of opMneLGS         : @[ opLGS_GS_B_Reg_V_Mem_P ]
    of opMneLFS         : @[ opLFS_FS_W_Reg_V_Mem_P ]
    of opMneLOOPNZ      : @[ opLOOPNZ_ECX_D_Imm_B ]
    of opMneSETB        : @[ opSETB_RegMem_B ]
    of opMneAAD         : @[ opAAD_AL_B_AH_B ]
    of opMneLIDT        : @[ opLIDT_IDTR_W_Mem_P ]
    of opMneBOUND       : @[ opBOUND_Reg_V_Mem_A_EFLAGS_D ]
    of opMneDEC         : @[ opDEC_EAX_D, opDEC_ECX_D, opDEC_EDX_D, opDEC_EBX_D, opDEC_ESP_D, opDEC_EBP_D, opDEC_ESI_D, opDEC_EDI_D, opDEC_RegMem_B, opDEC_RegMem_V ]
    of opMneCLC         : @[ opCLC ]
    of opMneLDS         : @[ opLDS_DS_W_Reg_V_Mem_P ]
    of opMneSHR         : @[ opSHR_RegMem_B_Imm_B, opSHR_RegMem_V_Imm_B, opSHR_RegMem_B_One_B, opSHR_RegMem_V_One_B, opSHR_RegMem_B_CL_B, opSHR_RegMem_V_CL_B ]
    of opMneSLDT        : @[ opSLDT_Mem_W_LDTR_W ]
    of opMneCALLF       : @[ opCALLF_A_P, opCALLF_Mem_P ]
    of opMneSGDT        : @[ opSGDT_Mem_P_GDTR_W ]
    of opMneSUB         : @[ opSUB_RegMem_B_Reg_B, opSUB_RegMem_V_Reg_V, opSUB_Reg_B_RegMem_B, opSUB_Reg_V_RegMem_V, opSUB_AL_B_Imm_B, opSUB_EAX_D_Imm_V, opSUB_RegMem_B_Imm_B, opSUB_RegMem_V_Imm_V ]
    of opMneOUTS        : @[ opOUTS_DX_W_Mem_B, opOUTS_DX_W_Mem_V ]
    of opMneIMUL        : @[ opIMUL_Reg_V_RegMem_V, opIMUL_Reg_V_RegMem_V_Imm_V, opIMUL_Reg_V_RegMem_V_Imm_B, opIMUL_AX_W_AL_B_RegMem_B, opIMUL_EDX_D_EAX_D_RegMem_V ]
    of opMneINT         : @[ opINT_Three_B_EFLAGS_D, opINT_Imm_B_EFLAGS_D ]
    of opMneLSS         : @[ opLSS_SS_B_Reg_V_Mem_P ]
    of opMneCALL        : @[ opCALL_Imm_V, opCALL_RegMem_V ]
    of opMneARPL        : @[ opARPL_RegMem_W_Reg_W ]
    of opMneINTO        : @[ opINTO_EFLAGS_D ]
    of opMneJMP         : @[ opJMP_Imm_V, opJMP_Imm_B, opJMP_RegMem_V ]
    of opMneSTC         : @[ opSTC ]
    of opMneXLAT        : @[ opXLAT_AL_B_Mem_B ]
    of opMneCDQ         : @[ opCDQ_EDX_D_EAX_D ]
    of opMneCMPS        : @[ opCMPS_Mem_B_Mem_B, opCMPS_Mem_V_Mem_V ]
    of opMneSETNLE      : @[ opSETNLE_RegMem_B ]
    of opMneSAR         : @[ opSAR_RegMem_B_Imm_B, opSAR_RegMem_V_Imm_B, opSAR_RegMem_B_One_B, opSAR_RegMem_V_One_B, opSAR_RegMem_B_CL_B, opSAR_RegMem_V_CL_B ]
    of opMneES          : @[ opES_ES_W ]
    of opMneSALC        : @[ opSALC_AL_B ]
    of opMneINC         : @[ opINC_EAX_D, opINC_ECX_D, opINC_EDX_D, opINC_EBX_D, opINC_ESP_D, opINC_EBP_D, opINC_ESI_D, opINC_EDI_D, opINC_RegMem_B, opINC_RegMem_V ]
    of opMneCMP         : @[ opCMP_RegMem_B_Reg_B, opCMP_RegMem_V_Reg_V, opCMP_Reg_B_RegMem_B, opCMP_Reg_V_RegMem_V, opCMP_AL_B_Imm_B, opCMP_EAX_D_Imm_V, opCMP_RegMem_B_Imm_B, opCMP_RegMem_V_Imm_V ]
    of opMneJCXZ        : @[ opJCXZ_Imm_B_CX_W ]
    of opMneBTC         : @[ opBTC_RegMem_V_Imm_B, opBTC_RegMem_V_Reg_V ]
    of opMnePUSH        : @[ opPUSH_ES_W, opPUSH_CS_W, opPUSH_FS_W, opPUSH_GS_B, opPUSH_SS_B, opPUSH_DS_W, opPUSH_EAX_D, opPUSH_ECX_D, opPUSH_EDX_D, opPUSH_EBX_D, opPUSH_ESP_D, opPUSH_EBP_D, opPUSH_ESI_D, opPUSH_EDI_D, opPUSH_Imm_V, opPUSH_Imm_B, opPUSH_RegMem_V ]
    of opMneSETP        : @[ opSETP_RegMem_B ]
    of opMneMUL         : @[ opMUL_AX_W_AL_B_RegMem_B, opMUL_EDX_D_EAX_D_RegMem_V ]
    of opMneDIV         : @[ opDIV_AL_B_AH_B_AX_W_RegMem_B, opDIV_EDX_D_EAX_D_RegMem_V ]
    of opMneJNB         : @[ opJNB_Imm_V ]
    of opMneJS          : @[ opJS_Imm_V, opJS_Imm_B ]
    of opMneSHL         : @[ opSHL_RegMem_B_Imm_B, opSHL_RegMem_V_Imm_B, opSHL_RegMem_B_One_B, opSHL_RegMem_V_One_B, opSHL_RegMem_B_CL_B, opSHL_RegMem_V_CL_B ]
    of opMneLSL         : @[ opLSL_Reg_V_Mem_W ]
    of opMneJNO         : @[ opJNO_Imm_V, opJNO_Imm_B ]
    of opMneCLD         : @[ opCLD ]
    of opMneSHRD        : @[ opSHRD_RegMem_V_Reg_V_Imm_B, opSHRD_RegMem_V_Reg_V_CL_B ]
    of opMneSAHF        : @[ opSAHF_AH_B ]
    of opMneSETNP       : @[ opSETNP_RegMem_B ]
    of opMneROL         : @[ opROL_RegMem_B_Imm_B, opROL_RegMem_V_Imm_B, opROL_RegMem_B_One_B, opROL_RegMem_V_One_B, opROL_RegMem_B_CL_B, opROL_RegMem_V_CL_B ]
    of opMneSAL         : @[ opSAL_RegMem_B_Imm_B, opSAL_RegMem_V_Imm_B, opSAL_RegMem_B_One_B, opSAL_RegMem_V_One_B, opSAL_RegMem_B_CL_B, opSAL_RegMem_V_CL_B ]
    of opMneJMPF        : @[ opJMPF_A_P, opJMPF_Mem_P ]
    of opMneRCR         : @[ opRCR_RegMem_B_Imm_B, opRCR_RegMem_V_Imm_B, opRCR_RegMem_B_One_B, opRCR_RegMem_V_One_B, opRCR_RegMem_B_CL_B, opRCR_RegMem_V_CL_B ]
    of opMneJL          : @[ opJL_Imm_V, opJL_Imm_B ]
    of opMnePOPA        : @[ opPOPA_DI_W_SI_W_BP_W_STACK_V ]
    of opMneREPNZ       : @[ opREPNZ_ECX_D ]
    of opMneLOOPZ       : @[ opLOOPZ_ECX_D_Imm_B ]
    of opMneRCL         : @[ opRCL_RegMem_B_Imm_B, opRCL_RegMem_V_Imm_B, opRCL_RegMem_B_One_B, opRCL_RegMem_V_One_B, opRCL_RegMem_B_CL_B, opRCL_RegMem_V_CL_B ]
    of opMneSETNO       : @[ opSETNO_RegMem_B ]
    of opMnePUSHFD      : @[ opPUSHFD_EFLAGS_D ]
    of opMneRETF        : @[ opRETF_Imm_W, opRETF ]
    of opMneSETLE       : @[ opSETLE_RegMem_B ]
    of opMneUD2         : @[ opUD2 ]
    of opMneSETNZ       : @[ opSETNZ_RegMem_B ]
    of opMneMOVS        : @[ opMOVS_Mem_B_Mem_B, opMOVS_Mem_V_Mem_V ]
    of opMneMOV         : @[ opMOV_Reg_D_CR_F, opMOV_Reg_D_DR_F, opMOV_CR_F_Reg_D, opMOV_DR_F_Reg_D, opMOV_RegMem_B_Reg_B, opMOV_RegMem_V_Reg_V, opMOV_Reg_B_RegMem_B, opMOV_Reg_V_RegMem_V, opMOV_Mem_W_SREG_W, opMOV_SREG_W_RegMem_W, opMOV_AL_B_Imm_B, opMOV_EAX_D_Imm_V, opMOV_Imm_B_AL_B, opMOV_Imm_V_EAX_D, opMOV_Reg_B_Imm_B, opMOV_Reg_V_Imm_V, opMOV_RegMem_B_Imm_B, opMOV_RegMem_V_Imm_V ]
    of opMneSETNS       : @[ opSETNS_RegMem_B ]
    of opMneBTR         : @[ opBTR_RegMem_V_Reg_V, opBTR_RegMem_V_Imm_B ]
    of opMneLGDT        : @[ opLGDT_GDTR_W_Mem_P ]
    of opMneADC         : @[ opADC_RegMem_B_Reg_B, opADC_RegMem_V_Reg_V, opADC_Reg_B_RegMem_B, opADC_Reg_V_RegMem_V, opADC_AL_B_Imm_B, opADC_EAX_D_Imm_V, opADC_RegMem_B_Imm_B, opADC_RegMem_V_Imm_V ]
    of opMneJO          : @[ opJO_Imm_V, opJO_Imm_B ]
    of opMneSETBE       : @[ opSETBE_RegMem_B ]
    of opMneLEAVE       : @[ opLEAVE_EBP_D ]
    of opMneBSR         : @[ opBSR_Reg_V_RegMem_V ]
    of opMneJNL         : @[ opJNL_Imm_V, opJNL_Imm_B ]
    of opMneOR          : @[ opOR_RegMem_B_Reg_B, opOR_RegMem_V_Reg_V, opOR_Reg_B_RegMem_B, opOR_Reg_V_RegMem_V, opOR_AL_B_Imm_B, opOR_EAX_D_Imm_V, opOR_RegMem_B_Imm_B, opOR_RegMem_V_Imm_V ]
    of opMneJLE         : @[ opJLE_Imm_V, opJLE_Imm_B ]
    of opMneIN          : @[ opIN_AL_B_Imm_B, opIN_EAX_D_Imm_B, opIN_AL_B_DX_W, opIN_EAX_D_DX_W ]
    of opMneENTER       : @[ opENTER_EBP_D_Imm_W_Imm_B ]
    of opMneMOVZX       : @[ opMOVZX_Reg_V_RegMem_B, opMOVZX_Reg_V_RegMem_W ]
    of opMneXCHG        : @[ opXCHG_Reg_B_RegMem_B, opXCHG_Reg_V_RegMem_V, opXCHG_EAX_D_EAX_D, opXCHG_ECX_D_EAX_D, opXCHG_EDX_D_EAX_D, opXCHG_EBX_D_EAX_D, opXCHG_ESP_D_EAX_D, opXCHG_EBP_D_EAX_D, opXCHG_ESI_D_EAX_D, opXCHG_EDI_D_EAX_D ]


func hasModrm*(code: ICode): bool =
  case code:
    of opADD_RegMem_B_Imm_B, opDIV_EDX_D_EAX_D_RegMem_V, opSGDT_Mem_P_GDTR_W, opROL_RegMem_V_CL_B, opLTR_TR_W_RegMem_W, opIMUL_Reg_V_RegMem_V_Imm_V, opIMUL_Reg_V_RegMem_V_Imm_B, opDEC_RegMem_B, opCMP_RegMem_V_Imm_V, opLMSW_MSW_W_RegMem_W, opROL_RegMem_V_Imm_B, opSAL_RegMem_V_Imm_B, opOR_Reg_V_RegMem_V, opSMSW_Mem_W_MSW_W, opSIDT_Mem_P_IDTR_W, opMOV_Reg_D_CR_F, opSETBE_RegMem_B, opXOR_RegMem_B_Imm_B, opLLDT_LDTR_W_RegMem_W, opMOV_Reg_B_RegMem_B, opMOVZX_Reg_V_RegMem_W, opCMP_RegMem_B_Imm_B, opADD_RegMem_V_Reg_V, opCALL_RegMem_V, opTEST_RegMem_V_Reg_V, opINC_RegMem_V, opSETNZ_RegMem_B, opSETNL_RegMem_B, opMOV_RegMem_V_Imm_V, opXOR_RegMem_B_Reg_B, opINC_RegMem_B, opOR_RegMem_B_Imm_B, opADD_RegMem_V_Imm_V, opDEC_RegMem_V, opLIDT_IDTR_W_Mem_P, opLEA_Reg_V_Mem_V, opNOT_RegMem_B, opJMP_RegMem_V, opNEG_RegMem_B, opADC_RegMem_V_Imm_V, opJNO_Imm_V, opSHR_RegMem_V_CL_B, opIDIV_AL_B_AH_B_AX_W_RegMem_B, opAND_RegMem_V_Imm_V, opXCHG_Reg_B_RegMem_B, opRCL_RegMem_V_Imm_B, opSETNB_RegMem_B, opSAR_RegMem_V_CL_B, opMOV_RegMem_V_Reg_V, opPUSH_RegMem_V, opIDIV_EDX_D_EAX_D_RegMem_V, opSAR_RegMem_V_Imm_B, opRCR_RegMem_V_CL_B, opSUB_Reg_B_RegMem_B, opXOR_RegMem_V_Reg_V, opCMP_RegMem_V_Reg_V, opOR_RegMem_V_Imm_V, opTEST_RegMem_B_Imm_B, opMUL_AX_W_AL_B_RegMem_B, opADD_Reg_B_RegMem_B, opSUB_Reg_V_RegMem_V, opMOV_RegMem_B_Reg_B, opSUB_RegMem_B_Reg_B, opSBB_RegMem_V_Imm_V, opMOV_Reg_B_Imm_B, opSTR_Mem_W_TR_W, opIMUL_Reg_V_RegMem_V, opCALLF_Mem_P, opSETNS_RegMem_B, opTEST_RegMem_V_Imm_V, opSUB_RegMem_V_Reg_V, opRCL_RegMem_V_CL_B, opSETO_RegMem_B, opOR_RegMem_V_Reg_V, opSETNO_RegMem_B, opMOV_SREG_W_RegMem_W, opMOV_Mem_W_SREG_W, opSAL_RegMem_V_CL_B, opADD_Reg_V_RegMem_V, opSHL_RegMem_V_CL_B, opOR_Reg_B_RegMem_B, opROR_RegMem_V_CL_B, opXOR_Reg_V_RegMem_V, opDIV_AL_B_AH_B_AX_W_RegMem_B, opTEST_RegMem_B_Reg_B, opLGDT_GDTR_W_Mem_P, opSHL_RegMem_V_Imm_B, opNOT_RegMem_V, opVERR_RegMem_W, opVERW_RegMem_W, opSETL_RegMem_B, opAND_Reg_B_RegMem_B, opSUB_RegMem_B_Imm_B, opSLDT_Mem_W_LDTR_W, opADC_RegMem_B_Imm_B, opSETLE_RegMem_B, opAND_RegMem_B_Reg_B, opMOVSX_Reg_V_RegMem_B, opSHR_RegMem_V_Imm_B, opXOR_Reg_B_RegMem_B, opAND_Reg_V_RegMem_V, opSETZ_RegMem_B, opRCR_RegMem_V_Imm_B, opSETS_RegMem_B, opMOVZX_Reg_V_RegMem_B, opXCHG_Reg_V_RegMem_V, opJMPF_Mem_P, opAND_RegMem_V_Reg_V, opSUB_RegMem_V_Imm_V, opSBB_RegMem_B_Imm_B, opMOVSX_Reg_V_RegMem_W, opXOR_RegMem_V_Imm_V, opNEG_RegMem_V, opAND_RegMem_B_Imm_B, opSETP_RegMem_B, opSETNLE_RegMem_B, opIMUL_AX_W_AL_B_RegMem_B, opSETNBE_RegMem_B, opMUL_EDX_D_EAX_D_RegMem_V, opIMUL_EDX_D_EAX_D_RegMem_V, opSETB_RegMem_B, opSETNP_RegMem_B, opADD_RegMem_B_Reg_B, opROR_RegMem_V_Imm_B, opMOV_CR_F_Reg_D, opMOV_Reg_V_RegMem_V: true
    else: false

func hasMoffs*(code: ICode): bool =
  case code:
    of opMOV_EAX_D_Imm_V, opMOV_Imm_B_AL_B, opMOV_AL_B_Imm_B, opMOV_Imm_V_EAX_D: true
    else: false

func hasImm8*(code: ICode): bool =
  case code:
    of opJNZ_Imm_B, opADD_RegMem_B_Imm_B, opIMUL_Reg_V_RegMem_V_Imm_B, opJL_Imm_B, opROL_RegMem_V_Imm_B, opSAL_RegMem_V_Imm_B, opOUT_Imm_B_EAX_D, opJNO_Imm_B, opJZ_Imm_B, opJC_Imm_B, opJS_Imm_B, opJP_Imm_B, opXOR_RegMem_B_Imm_B, opJO_Imm_B, opJNL_Imm_B, opJNP_Imm_B, opOUT_Imm_B_AL_B, opJG_Imm_B, opCMP_RegMem_B_Imm_B, opINT_Imm_B_EFLAGS_D, opSHL_RegMem_V_Imm_B, opOR_RegMem_B_Imm_B, opSUB_RegMem_B_Imm_B, opADD_AL_B_Imm_B, opADC_RegMem_B_Imm_B, opJBE_Imm_B, opTEST_AL_B_Imm_B, opSHR_RegMem_V_Imm_B, opIN_AL_B_Imm_B, opJLE_Imm_B, opRCL_RegMem_V_Imm_B, opAND_AL_B_Imm_B, opRCR_RegMem_V_Imm_B, opOR_AL_B_Imm_B, opJNC_Imm_B, opSBB_RegMem_B_Imm_B, opSAR_RegMem_V_Imm_B, opJMP_Imm_B, opJNBE_Imm_B, opJNS_Imm_B, opAND_RegMem_B_Imm_B, opSUB_AL_B_Imm_B, opCMP_AL_B_Imm_B, opPUSH_Imm_B, opROR_RegMem_V_Imm_B, opMOV_Reg_B_Imm_B: true
    else: false

func hasImm16*(code: ICode): bool =
  return false
  # case code:
  #   of :
  #     true

  #   else:
  #     false

func hasImm16_32*(code: ICode): bool =
  case code:
    of opCALL_Imm_V, opIMUL_Reg_V_RegMem_V_Imm_V, opJNZ_Imm_V, opJS_Imm_V, opJL_Imm_V, opADD_EAX_D_Imm_V, opJZ_Imm_V, opJNL_Imm_V, opJBE_Imm_V, opJB_Imm_V, opJMP_Imm_V, opOR_EAX_D_Imm_V, opXCHG_ESP_D_EAX_D, opXCHG_ESI_D_EAX_D, opJNBE_Imm_V, opXCHG_EDI_D_EAX_D, opAND_EAX_D_Imm_V, opPUSH_Imm_V, opMOV_RegMem_V_Imm_V, opJNP_Imm_V, opJNLE_Imm_V, opMOV_Reg_V_Imm_V, opJP_Imm_V, opXOR_EAX_D_Imm_V, opTEST_EAX_D_Imm_V, opJLE_Imm_V, opXCHG_EAX_D_EAX_D, opJNO_Imm_V, opXCHG_EBX_D_EAX_D, opXCHG_EBP_D_EAX_D, opXCHG_ECX_D_EAX_D, opCALLF_A_P, opJNB_Imm_V, opCMP_EAX_D_Imm_V, opXCHG_EDX_D_EAX_D, opJNS_Imm_V, opJMPF_A_P, opJO_Imm_V, opSUB_EAX_D_Imm_V: true
    else: false

func isExtendedOpcode*(code: ICode): bool =
   case code:
     of opADD_RegMem_B_Imm_B, opDIV_EDX_D_EAX_D_RegMem_V, opSGDT_Mem_P_GDTR_W, opROL_RegMem_V_CL_B, opLTR_TR_W_RegMem_W, opBTC_RegMem_V_Imm_B, opDEC_RegMem_B, opCMP_RegMem_V_Imm_V, opLMSW_MSW_W_RegMem_W, opSHR_RegMem_B_Imm_B, opROL_RegMem_V_Imm_B, opSAL_RegMem_V_Imm_B, opSMSW_Mem_W_MSW_W, opSIDT_Mem_P_IDTR_W, opSETBE_RegMem_B, opXOR_RegMem_B_Imm_B, opSAL_RegMem_B_CL_B, opLLDT_LDTR_W_RegMem_W, opCMP_RegMem_B_Imm_B, opCALL_RegMem_V, opRCR_RegMem_B_One_B, opINC_RegMem_V, opSETNZ_RegMem_B, opSETNL_RegMem_B, opMOV_RegMem_V_Imm_V, opROR_RegMem_B_One_B, opINC_RegMem_B, opOR_RegMem_B_Imm_B, opADD_RegMem_V_Imm_V, opDEC_RegMem_V, opLIDT_IDTR_W_Mem_P, opSHL_RegMem_B_One_B, opNOT_RegMem_B, opROL_RegMem_B_CL_B, opJMP_RegMem_V, opBTS_RegMem_V_Imm_B, opNEG_RegMem_B, opADC_RegMem_V_Imm_V, opRCL_RegMem_V_One_B, opSHR_RegMem_V_CL_B, opSAL_RegMem_B_Imm_B, opRCR_RegMem_B_CL_B, opIDIV_AL_B_AH_B_AX_W_RegMem_B, opAND_RegMem_V_Imm_V, opRCL_RegMem_V_Imm_B, opSHL_RegMem_B_Imm_B, opSETNB_RegMem_B, opRCL_RegMem_B_One_B, opSAR_RegMem_V_CL_B, opPUSH_RegMem_V, opBTR_RegMem_V_Imm_B, opROL_RegMem_B_Imm_B, opIDIV_EDX_D_EAX_D_RegMem_V, opSAR_RegMem_V_Imm_B, opRCR_RegMem_V_CL_B, opOR_RegMem_V_Imm_V, opSHR_RegMem_V_One_B, opTEST_RegMem_B_Imm_B, opMUL_AX_W_AL_B_RegMem_B, opRCL_RegMem_B_CL_B, opRCL_RegMem_B_Imm_B, opSAR_RegMem_B_Imm_B, opSBB_RegMem_V_Imm_V, opSTR_Mem_W_TR_W, opCALLF_Mem_P, opSETNS_RegMem_B, opTEST_RegMem_V_Imm_V, opBT_RegMem_V_Imm_B, opRCR_RegMem_B_Imm_B, opRCL_RegMem_V_CL_B, opROR_RegMem_V_One_B, opSETO_RegMem_B, opMOV_RegMem_B_Imm_B, opSETNO_RegMem_B, opSAL_RegMem_V_CL_B, opSAR_RegMem_B_One_B, opSHL_RegMem_V_CL_B, opROR_RegMem_V_CL_B, opROL_RegMem_V_One_B, opDIV_AL_B_AH_B_AX_W_RegMem_B, opSHL_RegMem_V_Imm_B, opLGDT_GDTR_W_Mem_P, opNOT_RegMem_V, opVERR_RegMem_W, opVERW_RegMem_W, opSETL_RegMem_B, opSUB_RegMem_B_Imm_B, opSLDT_Mem_W_LDTR_W, opADC_RegMem_B_Imm_B, opSETLE_RegMem_B, opRCR_RegMem_V_One_B, opSHL_RegMem_V_One_B, opSAR_RegMem_V_One_B, opSHR_RegMem_V_Imm_B, opSETZ_RegMem_B, opRCR_RegMem_V_Imm_B, opSETS_RegMem_B, opROR_RegMem_B_Imm_B, opSHR_RegMem_B_CL_B, opJMPF_Mem_P, opSUB_RegMem_V_Imm_V, opSBB_RegMem_B_Imm_B, opROR_RegMem_B_CL_B, opXOR_RegMem_V_Imm_V, opROL_RegMem_B_One_B, opSAL_RegMem_B_One_B, opNEG_RegMem_V, opAND_RegMem_B_Imm_B, opSETP_RegMem_B, opSETNLE_RegMem_B, opIMUL_AX_W_AL_B_RegMem_B, opSAR_RegMem_B_CL_B, opSETNBE_RegMem_B, opPOP_RegMem_V, opMUL_EDX_D_EAX_D_RegMem_V, opSHL_RegMem_B_CL_B, opSHR_RegMem_B_One_B, opIMUL_EDX_D_EAX_D_RegMem_V, opSETB_RegMem_B, opSETNP_RegMem_B, opROR_RegMem_V_Imm_B, opSAL_RegMem_V_One_B: true
     else: false

func hasImm32*(code: ICode): bool =
  return false
  # case code:
  #   of :
  #     true

  #   else:
  #     false


func getTestedFlags*(code: ICode): set[OpFlagIO] =
  case code:
    of opADD_RegMem_B_Reg_B          : set[OpFlagIO]({})
    of opADD_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opADD_Reg_B_RegMem_B          : set[OpFlagIO]({})
    of opADD_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opADD_AL_B_Imm_B              : set[OpFlagIO]({})
    of opADD_EAX_D_Imm_V             : set[OpFlagIO]({})
    of opPUSH_ES_W                   : set[OpFlagIO]({})
    of opPOP_ES_W                    : set[OpFlagIO]({})
    of opOR_RegMem_B_Reg_B           : set[OpFlagIO]({})
    of opOR_RegMem_V_Reg_V           : set[OpFlagIO]({})
    of opOR_Reg_B_RegMem_B           : set[OpFlagIO]({})
    of opOR_Reg_V_RegMem_V           : set[OpFlagIO]({})
    of opOR_AL_B_Imm_B               : set[OpFlagIO]({})
    of opOR_EAX_D_Imm_V              : set[OpFlagIO]({})
    of opPUSH_CS_W                   : set[OpFlagIO]({})
    of opSLDT_Mem_W_LDTR_W           : set[OpFlagIO]({})
    of opSTR_Mem_W_TR_W              : set[OpFlagIO]({})
    of opLLDT_LDTR_W_RegMem_W        : set[OpFlagIO]({})
    of opLTR_TR_W_RegMem_W           : set[OpFlagIO]({})
    of opVERR_RegMem_W               : set[OpFlagIO]({})
    of opVERW_RegMem_W               : set[OpFlagIO]({})
    of opSGDT_Mem_P_GDTR_W           : set[OpFlagIO]({})
    of opSIDT_Mem_P_IDTR_W           : set[OpFlagIO]({})
    of opLGDT_GDTR_W_Mem_P           : set[OpFlagIO]({})
    of opLIDT_IDTR_W_Mem_P           : set[OpFlagIO]({})
    of opSMSW_Mem_W_MSW_W            : set[OpFlagIO]({})
    of opLMSW_MSW_W_RegMem_W         : set[OpFlagIO]({})
    of opLAR_Reg_V_Mem_W             : set[OpFlagIO]({})
    of opLSL_Reg_V_Mem_W             : set[OpFlagIO]({})
    of opCLTS_CR_F                   : set[OpFlagIO]({})
    of opUD2                         : set[OpFlagIO]({})
    of opMOV_Reg_D_CR_F              : set[OpFlagIO]({})
    of opMOV_Reg_D_DR_F              : set[OpFlagIO]({})
    of opMOV_CR_F_Reg_D              : set[OpFlagIO]({})
    of opMOV_DR_F_Reg_D              : set[OpFlagIO]({})
    of opJO_Imm_V                    : set[OpFlagIO]({opfOverflow, })
    of opJNO_Imm_V                   : set[OpFlagIO]({opfOverflow, })
    of opJB_Imm_V                    : set[OpFlagIO]({opfCarry, })
    of opJNB_Imm_V                   : set[OpFlagIO]({opfCarry, })
    of opJZ_Imm_V                    : set[OpFlagIO]({opfZero, })
    of opJNZ_Imm_V                   : set[OpFlagIO]({opfZero, })
    of opJBE_Imm_V                   : set[OpFlagIO]({opfZero, opfCarry, })
    of opJNBE_Imm_V                  : set[OpFlagIO]({opfZero, opfCarry, })
    of opJS_Imm_V                    : set[OpFlagIO]({opfSigned, })
    of opJNS_Imm_V                   : set[OpFlagIO]({opfSigned, })
    of opJP_Imm_V                    : set[OpFlagIO]({opfParity, })
    of opJNP_Imm_V                   : set[OpFlagIO]({opfParity, })
    of opJL_Imm_V                    : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJNL_Imm_V                   : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJLE_Imm_V                   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opJNLE_Imm_V                  : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opSETO_RegMem_B               : set[OpFlagIO]({opfOverflow, })
    of opSETNO_RegMem_B              : set[OpFlagIO]({opfOverflow, })
    of opSETB_RegMem_B               : set[OpFlagIO]({opfCarry, })
    of opSETNB_RegMem_B              : set[OpFlagIO]({opfCarry, })
    of opSETZ_RegMem_B               : set[OpFlagIO]({opfZero, })
    of opSETNZ_RegMem_B              : set[OpFlagIO]({opfZero, })
    of opSETBE_RegMem_B              : set[OpFlagIO]({opfZero, opfCarry, })
    of opSETNBE_RegMem_B             : set[OpFlagIO]({opfZero, opfCarry, })
    of opSETS_RegMem_B               : set[OpFlagIO]({opfSigned, })
    of opSETNS_RegMem_B              : set[OpFlagIO]({opfSigned, })
    of opSETP_RegMem_B               : set[OpFlagIO]({opfParity, })
    of opSETNP_RegMem_B              : set[OpFlagIO]({opfParity, })
    of opSETL_RegMem_B               : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opSETNL_RegMem_B              : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opSETLE_RegMem_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opSETNLE_RegMem_B             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opPUSH_FS_W                   : set[OpFlagIO]({})
    of opPOP_FS_W                    : set[OpFlagIO]({})
    of opBT_RegMem_V_Reg_V           : set[OpFlagIO]({})
    of opSHLD_RegMem_V_Reg_V_Imm_B   : set[OpFlagIO]({})
    of opSHLD_RegMem_V_Reg_V_CL_B    : set[OpFlagIO]({})
    of opPUSH_GS_B                   : set[OpFlagIO]({})
    of opPOP_GS_B                    : set[OpFlagIO]({})
    of opBTS_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opSHRD_RegMem_V_Reg_V_Imm_B   : set[OpFlagIO]({})
    of opSHRD_RegMem_V_Reg_V_CL_B    : set[OpFlagIO]({})
    of opIMUL_Reg_V_RegMem_V         : set[OpFlagIO]({})
    of opLSS_SS_B_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opBTR_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opLFS_FS_W_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opLGS_GS_B_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opMOVZX_Reg_V_RegMem_B        : set[OpFlagIO]({})
    of opMOVZX_Reg_V_RegMem_W        : set[OpFlagIO]({})
    of opBT_RegMem_V_Imm_B           : set[OpFlagIO]({})
    of opBTS_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opBTR_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opBTC_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opBTC_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opBSF_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opBSR_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opMOVSX_Reg_V_RegMem_B        : set[OpFlagIO]({})
    of opMOVSX_Reg_V_RegMem_W        : set[OpFlagIO]({})
    of opADC_RegMem_B_Reg_B          : set[OpFlagIO]({opfCarry, })
    of opADC_RegMem_V_Reg_V          : set[OpFlagIO]({opfCarry, })
    of opADC_Reg_B_RegMem_B          : set[OpFlagIO]({opfCarry, })
    of opADC_Reg_V_RegMem_V          : set[OpFlagIO]({opfCarry, })
    of opADC_AL_B_Imm_B              : set[OpFlagIO]({opfCarry, })
    of opADC_EAX_D_Imm_V             : set[OpFlagIO]({opfCarry, })
    of opPUSH_SS_B                   : set[OpFlagIO]({})
    of opPOP_SS_B                    : set[OpFlagIO]({})
    of opSBB_RegMem_B_Reg_B          : set[OpFlagIO]({opfCarry, })
    of opSBB_RegMem_V_Reg_V          : set[OpFlagIO]({opfCarry, })
    of opSBB_Reg_B_RegMem_B          : set[OpFlagIO]({opfCarry, })
    of opSBB_Reg_V_RegMem_V          : set[OpFlagIO]({opfCarry, })
    of opSBB_AL_B_Imm_B              : set[OpFlagIO]({opfCarry, })
    of opSBB_EAX_D_Imm_V             : set[OpFlagIO]({opfCarry, })
    of opPUSH_DS_W                   : set[OpFlagIO]({})
    of opPOP_DS_W                    : set[OpFlagIO]({})
    of opAND_RegMem_B_Reg_B          : set[OpFlagIO]({})
    of opAND_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opAND_Reg_B_RegMem_B          : set[OpFlagIO]({})
    of opAND_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opAND_AL_B_Imm_B              : set[OpFlagIO]({})
    of opAND_EAX_D_Imm_V             : set[OpFlagIO]({})
    of opES_ES_W                     : set[OpFlagIO]({})
    of opDAA_AL_B                    : set[OpFlagIO]({opfAbove, opfCarry, })
    of opSUB_RegMem_B_Reg_B          : set[OpFlagIO]({})
    of opSUB_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opSUB_Reg_B_RegMem_B          : set[OpFlagIO]({})
    of opSUB_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opSUB_AL_B_Imm_B              : set[OpFlagIO]({})
    of opSUB_EAX_D_Imm_V             : set[OpFlagIO]({})
    of opCS_CS_W                     : set[OpFlagIO]({})
    of opDAS_AL_B                    : set[OpFlagIO]({opfAbove, opfCarry, })
    of opXOR_RegMem_B_Reg_B          : set[OpFlagIO]({})
    of opXOR_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opXOR_Reg_B_RegMem_B          : set[OpFlagIO]({})
    of opXOR_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opXOR_AL_B_Imm_B              : set[OpFlagIO]({})
    of opXOR_EAX_D_Imm_V             : set[OpFlagIO]({})
    of opSS_SS_B                     : set[OpFlagIO]({})
    of opAAA_AL_B_AH_B               : set[OpFlagIO]({opfAbove, })
    of opCMP_RegMem_B_Reg_B          : set[OpFlagIO]({})
    of opCMP_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opCMP_Reg_B_RegMem_B          : set[OpFlagIO]({})
    of opCMP_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opCMP_AL_B_Imm_B              : set[OpFlagIO]({})
    of opCMP_EAX_D_Imm_V             : set[OpFlagIO]({})
    of opDS_DS_W                     : set[OpFlagIO]({})
    of opAAS_AL_B_AH_B               : set[OpFlagIO]({opfAbove, })
    of opINC_EAX_D                   : set[OpFlagIO]({})
    of opINC_ECX_D                   : set[OpFlagIO]({})
    of opINC_EDX_D                   : set[OpFlagIO]({})
    of opINC_EBX_D                   : set[OpFlagIO]({})
    of opINC_ESP_D                   : set[OpFlagIO]({})
    of opINC_EBP_D                   : set[OpFlagIO]({})
    of opINC_ESI_D                   : set[OpFlagIO]({})
    of opINC_EDI_D                   : set[OpFlagIO]({})
    of opDEC_EAX_D                   : set[OpFlagIO]({})
    of opDEC_ECX_D                   : set[OpFlagIO]({})
    of opDEC_EDX_D                   : set[OpFlagIO]({})
    of opDEC_EBX_D                   : set[OpFlagIO]({})
    of opDEC_ESP_D                   : set[OpFlagIO]({})
    of opDEC_EBP_D                   : set[OpFlagIO]({})
    of opDEC_ESI_D                   : set[OpFlagIO]({})
    of opDEC_EDI_D                   : set[OpFlagIO]({})
    of opPUSH_EAX_D                  : set[OpFlagIO]({})
    of opPUSH_ECX_D                  : set[OpFlagIO]({})
    of opPUSH_EDX_D                  : set[OpFlagIO]({})
    of opPUSH_EBX_D                  : set[OpFlagIO]({})
    of opPUSH_ESP_D                  : set[OpFlagIO]({})
    of opPUSH_EBP_D                  : set[OpFlagIO]({})
    of opPUSH_ESI_D                  : set[OpFlagIO]({})
    of opPUSH_EDI_D                  : set[OpFlagIO]({})
    of opPOP_EAX_D                   : set[OpFlagIO]({})
    of opPOP_ECX_D                   : set[OpFlagIO]({})
    of opPOP_EDX_D                   : set[OpFlagIO]({})
    of opPOP_EBX_D                   : set[OpFlagIO]({})
    of opPOP_ESP_D                   : set[OpFlagIO]({})
    of opPOP_EBP_D                   : set[OpFlagIO]({})
    of opPOP_ESI_D                   : set[OpFlagIO]({})
    of opPOP_EDI_D                   : set[OpFlagIO]({})
    of opPUSHA_AX_W_CX_W_DX_W_STACK_V: set[OpFlagIO]({})
    of opPOPA_DI_W_SI_W_BP_W_STACK_V : set[OpFlagIO]({})
    of opBOUND_Reg_V_Mem_A_EFLAGS_D  : set[OpFlagIO]({})
    of opARPL_RegMem_W_Reg_W         : set[OpFlagIO]({})
    of opFS_FS_W                     : set[OpFlagIO]({})
    of opGS_GS_B                     : set[OpFlagIO]({})
    of opPUSH_Imm_V                  : set[OpFlagIO]({})
    of opIMUL_Reg_V_RegMem_V_Imm_V   : set[OpFlagIO]({})
    of opPUSH_Imm_B                  : set[OpFlagIO]({})
    of opIMUL_Reg_V_RegMem_V_Imm_B   : set[OpFlagIO]({})
    of opINS_Mem_B_DX_W              : set[OpFlagIO]({opfDirection, })
    of opINS_Mem_V_DX_W              : set[OpFlagIO]({opfDirection, })
    of opOUTS_DX_W_Mem_B             : set[OpFlagIO]({opfDirection, })
    of opOUTS_DX_W_Mem_V             : set[OpFlagIO]({opfDirection, })
    of opJO_Imm_B                    : set[OpFlagIO]({opfOverflow, })
    of opJNO_Imm_B                   : set[OpFlagIO]({opfOverflow, })
    of opJC_Imm_B                    : set[OpFlagIO]({opfCarry, })
    of opJNC_Imm_B                   : set[OpFlagIO]({opfCarry, })
    of opJZ_Imm_B                    : set[OpFlagIO]({opfZero, })
    of opJNZ_Imm_B                   : set[OpFlagIO]({opfZero, })
    of opJBE_Imm_B                   : set[OpFlagIO]({opfZero, opfCarry, })
    of opJNBE_Imm_B                  : set[OpFlagIO]({opfZero, opfCarry, })
    of opJS_Imm_B                    : set[OpFlagIO]({opfSigned, })
    of opJNS_Imm_B                   : set[OpFlagIO]({opfSigned, })
    of opJP_Imm_B                    : set[OpFlagIO]({opfParity, })
    of opJNP_Imm_B                   : set[OpFlagIO]({opfParity, })
    of opJL_Imm_B                    : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJNL_Imm_B                   : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJLE_Imm_B                   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opJG_Imm_B                    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opADD_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opOR_RegMem_B_Imm_B           : set[OpFlagIO]({})
    of opADC_RegMem_B_Imm_B          : set[OpFlagIO]({opfCarry, })
    of opSBB_RegMem_B_Imm_B          : set[OpFlagIO]({opfCarry, })
    of opAND_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opSUB_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opXOR_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opCMP_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opADD_RegMem_V_Imm_V          : set[OpFlagIO]({})
    of opOR_RegMem_V_Imm_V           : set[OpFlagIO]({})
    of opADC_RegMem_V_Imm_V          : set[OpFlagIO]({opfCarry, })
    of opSBB_RegMem_V_Imm_V          : set[OpFlagIO]({opfCarry, })
    of opAND_RegMem_V_Imm_V          : set[OpFlagIO]({})
    of opSUB_RegMem_V_Imm_V          : set[OpFlagIO]({})
    of opXOR_RegMem_V_Imm_V          : set[OpFlagIO]({})
    of opCMP_RegMem_V_Imm_V          : set[OpFlagIO]({})
    of opTEST_RegMem_B_Reg_B         : set[OpFlagIO]({})
    of opTEST_RegMem_V_Reg_V         : set[OpFlagIO]({})
    of opXCHG_Reg_B_RegMem_B         : set[OpFlagIO]({})
    of opXCHG_Reg_V_RegMem_V         : set[OpFlagIO]({})
    of opMOV_RegMem_B_Reg_B          : set[OpFlagIO]({})
    of opMOV_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opMOV_Reg_B_RegMem_B          : set[OpFlagIO]({})
    of opMOV_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opMOV_Mem_W_SREG_W            : set[OpFlagIO]({})
    of opLEA_Reg_V_Mem_V             : set[OpFlagIO]({})
    of opMOV_SREG_W_RegMem_W         : set[OpFlagIO]({})
    of opPOP_RegMem_V                : set[OpFlagIO]({})
    of opXCHG_EAX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_ECX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EDX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EBX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_ESP_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EBP_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_ESI_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EDI_D_EAX_D            : set[OpFlagIO]({})
    of opCWDE_EAX_D_AX_W             : set[OpFlagIO]({})
    of opCDQ_EDX_D_EAX_D             : set[OpFlagIO]({})
    of opCALLF_A_P                   : set[OpFlagIO]({})
    of opPUSHFD_EFLAGS_D             : set[OpFlagIO]({})
    of opPOPFD_EFLAGS_D              : set[OpFlagIO]({})
    of opSAHF_AH_B                   : set[OpFlagIO]({})
    of opLAHF_AH_B                   : set[OpFlagIO]({opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_AL_B_Imm_B              : set[OpFlagIO]({})
    of opMOV_EAX_D_Imm_V             : set[OpFlagIO]({})
    of opMOV_Imm_B_AL_B              : set[OpFlagIO]({})
    of opMOV_Imm_V_EAX_D             : set[OpFlagIO]({})
    of opMOVS_Mem_B_Mem_B            : set[OpFlagIO]({opfDirection, })
    of opMOVS_Mem_V_Mem_V            : set[OpFlagIO]({opfDirection, })
    of opCMPS_Mem_B_Mem_B            : set[OpFlagIO]({opfDirection, })
    of opCMPS_Mem_V_Mem_V            : set[OpFlagIO]({opfDirection, })
    of opTEST_AL_B_Imm_B             : set[OpFlagIO]({})
    of opTEST_EAX_D_Imm_V            : set[OpFlagIO]({})
    of opSTOS_Mem_B_AL_B             : set[OpFlagIO]({opfDirection, })
    of opSTOS_Mem_V_EAX_D            : set[OpFlagIO]({opfDirection, })
    of opLODS_AL_B_Mem_B             : set[OpFlagIO]({opfDirection, })
    of opLODS_EAX_D_Mem_V            : set[OpFlagIO]({opfDirection, })
    of opSCAS_Mem_B_AL_B             : set[OpFlagIO]({opfDirection, })
    of opSCAS_Mem_V_EAX_D            : set[OpFlagIO]({opfDirection, })
    of opMOV_Reg_B_Imm_B             : set[OpFlagIO]({})
    of opMOV_Reg_V_Imm_V             : set[OpFlagIO]({})
    of opROL_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opROR_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opRCL_RegMem_B_Imm_B          : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_B_Imm_B          : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opSHR_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opSAL_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opSAR_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opROL_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opROR_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opRCL_RegMem_V_Imm_B          : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_V_Imm_B          : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opSHR_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opSAL_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opSAR_RegMem_V_Imm_B          : set[OpFlagIO]({})
    of opRETN_Imm_W                  : set[OpFlagIO]({})
    of opRETN                        : set[OpFlagIO]({})
    of opLES_ES_W_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opLDS_DS_W_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opMOV_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opMOV_RegMem_V_Imm_V          : set[OpFlagIO]({})
    of opENTER_EBP_D_Imm_W_Imm_B     : set[OpFlagIO]({})
    of opLEAVE_EBP_D                 : set[OpFlagIO]({})
    of opRETF_Imm_W                  : set[OpFlagIO]({})
    of opRETF                        : set[OpFlagIO]({})
    of opINT_Three_B_EFLAGS_D        : set[OpFlagIO]({})
    of opINT_Imm_B_EFLAGS_D          : set[OpFlagIO]({})
    of opINTO_EFLAGS_D               : set[OpFlagIO]({opfOverflow, })
    of opIRET_EFLAGS_D               : set[OpFlagIO]({})
    of opROL_RegMem_B_One_B          : set[OpFlagIO]({})
    of opROR_RegMem_B_One_B          : set[OpFlagIO]({})
    of opRCL_RegMem_B_One_B          : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_B_One_B          : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_B_One_B          : set[OpFlagIO]({})
    of opSHR_RegMem_B_One_B          : set[OpFlagIO]({})
    of opSAL_RegMem_B_One_B          : set[OpFlagIO]({})
    of opSAR_RegMem_B_One_B          : set[OpFlagIO]({})
    of opROL_RegMem_V_One_B          : set[OpFlagIO]({})
    of opROR_RegMem_V_One_B          : set[OpFlagIO]({})
    of opRCL_RegMem_V_One_B          : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_V_One_B          : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_V_One_B          : set[OpFlagIO]({})
    of opSHR_RegMem_V_One_B          : set[OpFlagIO]({})
    of opSAL_RegMem_V_One_B          : set[OpFlagIO]({})
    of opSAR_RegMem_V_One_B          : set[OpFlagIO]({})
    of opROL_RegMem_B_CL_B           : set[OpFlagIO]({})
    of opROR_RegMem_B_CL_B           : set[OpFlagIO]({})
    of opRCL_RegMem_B_CL_B           : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_B_CL_B           : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_B_CL_B           : set[OpFlagIO]({})
    of opSHR_RegMem_B_CL_B           : set[OpFlagIO]({})
    of opSAL_RegMem_B_CL_B           : set[OpFlagIO]({})
    of opSAR_RegMem_B_CL_B           : set[OpFlagIO]({})
    of opROL_RegMem_V_CL_B           : set[OpFlagIO]({})
    of opROR_RegMem_V_CL_B           : set[OpFlagIO]({})
    of opRCL_RegMem_V_CL_B           : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_V_CL_B           : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_V_CL_B           : set[OpFlagIO]({})
    of opSHR_RegMem_V_CL_B           : set[OpFlagIO]({})
    of opSAL_RegMem_V_CL_B           : set[OpFlagIO]({})
    of opSAR_RegMem_V_CL_B           : set[OpFlagIO]({})
    of opAMX_AL_B_AH_B_Imm_B         : set[OpFlagIO]({})
    of opAAM_AL_B_AH_B               : set[OpFlagIO]({})
    of opADX_AL_B_AH_B_Imm_B         : set[OpFlagIO]({})
    of opAAD_AL_B_AH_B               : set[OpFlagIO]({})
    of opSALC_AL_B                   : set[OpFlagIO]({opfCarry, })
    of opXLAT_AL_B_Mem_B             : set[OpFlagIO]({})
    of opLOOPNZ_ECX_D_Imm_B          : set[OpFlagIO]({opfZero, })
    of opLOOPZ_ECX_D_Imm_B           : set[OpFlagIO]({opfZero, })
    of opLOOP_ECX_D_Imm_B            : set[OpFlagIO]({})
    of opJCXZ_Imm_B_CX_W             : set[OpFlagIO]({})
    of opIN_AL_B_Imm_B               : set[OpFlagIO]({})
    of opIN_EAX_D_Imm_B              : set[OpFlagIO]({})
    of opOUT_Imm_B_AL_B              : set[OpFlagIO]({})
    of opOUT_Imm_B_EAX_D             : set[OpFlagIO]({})
    of opCALL_Imm_V                  : set[OpFlagIO]({})
    of opJMP_Imm_V                   : set[OpFlagIO]({})
    of opJMPF_A_P                    : set[OpFlagIO]({})
    of opJMP_Imm_B                   : set[OpFlagIO]({})
    of opIN_AL_B_DX_W                : set[OpFlagIO]({})
    of opIN_EAX_D_DX_W               : set[OpFlagIO]({})
    of opOUT_DX_W_AL_B               : set[OpFlagIO]({})
    of opOUT_DX_W_EAX_D              : set[OpFlagIO]({})
    of opLOCK                        : set[OpFlagIO]({})
    of opINT1_EFLAGS_D               : set[OpFlagIO]({})
    of opREPNZ_ECX_D                 : set[OpFlagIO]({opfZero, })
    of opREPZ_ECX_D                  : set[OpFlagIO]({opfZero, })
    of opHLT                         : set[OpFlagIO]({})
    of opCMC                         : set[OpFlagIO]({opfCarry, })
    of opTEST_RegMem_B_Imm_B         : set[OpFlagIO]({})
    of opNOT_RegMem_B                : set[OpFlagIO]({})
    of opNEG_RegMem_B                : set[OpFlagIO]({})
    of opMUL_AX_W_AL_B_RegMem_B      : set[OpFlagIO]({})
    of opIMUL_AX_W_AL_B_RegMem_B     : set[OpFlagIO]({})
    of opDIV_AL_B_AH_B_AX_W_RegMem_B : set[OpFlagIO]({})
    of opIDIV_AL_B_AH_B_AX_W_RegMem_B: set[OpFlagIO]({})
    of opTEST_RegMem_V_Imm_V         : set[OpFlagIO]({})
    of opNOT_RegMem_V                : set[OpFlagIO]({})
    of opNEG_RegMem_V                : set[OpFlagIO]({})
    of opMUL_EDX_D_EAX_D_RegMem_V    : set[OpFlagIO]({})
    of opIMUL_EDX_D_EAX_D_RegMem_V   : set[OpFlagIO]({})
    of opDIV_EDX_D_EAX_D_RegMem_V    : set[OpFlagIO]({})
    of opIDIV_EDX_D_EAX_D_RegMem_V   : set[OpFlagIO]({})
    of opCLC                         : set[OpFlagIO]({})
    of opSTC                         : set[OpFlagIO]({})
    of opCLI                         : set[OpFlagIO]({})
    of opSTI                         : set[OpFlagIO]({})
    of opCLD                         : set[OpFlagIO]({})
    of opSTD                         : set[OpFlagIO]({})
    of opINC_RegMem_B                : set[OpFlagIO]({})
    of opDEC_RegMem_B                : set[OpFlagIO]({})
    of opINC_RegMem_V                : set[OpFlagIO]({})
    of opDEC_RegMem_V                : set[OpFlagIO]({})
    of opCALL_RegMem_V               : set[OpFlagIO]({})
    of opCALLF_Mem_P                 : set[OpFlagIO]({})
    of opJMP_RegMem_V                : set[OpFlagIO]({})
    of opJMPF_Mem_P                  : set[OpFlagIO]({})
    of opPUSH_RegMem_V               : set[OpFlagIO]({})

func getModifiedFlags*(code: ICode): set[OpFlagIO] =
  case code:
    of opADD_RegMem_B_Reg_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_Reg_B_RegMem_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_AL_B_Imm_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_EAX_D_Imm_V             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_ES_W                   : set[OpFlagIO]({})
    of opPOP_ES_W                    : set[OpFlagIO]({})
    of opOR_RegMem_B_Reg_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_RegMem_V_Reg_V           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_Reg_B_RegMem_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_Reg_V_RegMem_V           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_AL_B_Imm_B               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_EAX_D_Imm_V              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_CS_W                   : set[OpFlagIO]({})
    of opSLDT_Mem_W_LDTR_W           : set[OpFlagIO]({})
    of opSTR_Mem_W_TR_W              : set[OpFlagIO]({})
    of opLLDT_LDTR_W_RegMem_W        : set[OpFlagIO]({})
    of opLTR_TR_W_RegMem_W           : set[OpFlagIO]({})
    of opVERR_RegMem_W               : set[OpFlagIO]({opfZero, })
    of opVERW_RegMem_W               : set[OpFlagIO]({opfZero, })
    of opSGDT_Mem_P_GDTR_W           : set[OpFlagIO]({})
    of opSIDT_Mem_P_IDTR_W           : set[OpFlagIO]({})
    of opLGDT_GDTR_W_Mem_P           : set[OpFlagIO]({})
    of opLIDT_IDTR_W_Mem_P           : set[OpFlagIO]({})
    of opSMSW_Mem_W_MSW_W            : set[OpFlagIO]({})
    of opLMSW_MSW_W_RegMem_W         : set[OpFlagIO]({})
    of opLAR_Reg_V_Mem_W             : set[OpFlagIO]({opfZero, })
    of opLSL_Reg_V_Mem_W             : set[OpFlagIO]({opfZero, })
    of opCLTS_CR_F                   : set[OpFlagIO]({})
    of opUD2                         : set[OpFlagIO]({})
    of opMOV_Reg_D_CR_F              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_Reg_D_DR_F              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_CR_F_Reg_D              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_DR_F_Reg_D              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opJO_Imm_V                    : set[OpFlagIO]({})
    of opJNO_Imm_V                   : set[OpFlagIO]({})
    of opJB_Imm_V                    : set[OpFlagIO]({})
    of opJNB_Imm_V                   : set[OpFlagIO]({})
    of opJZ_Imm_V                    : set[OpFlagIO]({})
    of opJNZ_Imm_V                   : set[OpFlagIO]({})
    of opJBE_Imm_V                   : set[OpFlagIO]({})
    of opJNBE_Imm_V                  : set[OpFlagIO]({})
    of opJS_Imm_V                    : set[OpFlagIO]({})
    of opJNS_Imm_V                   : set[OpFlagIO]({})
    of opJP_Imm_V                    : set[OpFlagIO]({})
    of opJNP_Imm_V                   : set[OpFlagIO]({})
    of opJL_Imm_V                    : set[OpFlagIO]({})
    of opJNL_Imm_V                   : set[OpFlagIO]({})
    of opJLE_Imm_V                   : set[OpFlagIO]({})
    of opJNLE_Imm_V                  : set[OpFlagIO]({})
    of opSETO_RegMem_B               : set[OpFlagIO]({})
    of opSETNO_RegMem_B              : set[OpFlagIO]({})
    of opSETB_RegMem_B               : set[OpFlagIO]({})
    of opSETNB_RegMem_B              : set[OpFlagIO]({})
    of opSETZ_RegMem_B               : set[OpFlagIO]({})
    of opSETNZ_RegMem_B              : set[OpFlagIO]({})
    of opSETBE_RegMem_B              : set[OpFlagIO]({})
    of opSETNBE_RegMem_B             : set[OpFlagIO]({})
    of opSETS_RegMem_B               : set[OpFlagIO]({})
    of opSETNS_RegMem_B              : set[OpFlagIO]({})
    of opSETP_RegMem_B               : set[OpFlagIO]({})
    of opSETNP_RegMem_B              : set[OpFlagIO]({})
    of opSETL_RegMem_B               : set[OpFlagIO]({})
    of opSETNL_RegMem_B              : set[OpFlagIO]({})
    of opSETLE_RegMem_B              : set[OpFlagIO]({})
    of opSETNLE_RegMem_B             : set[OpFlagIO]({})
    of opPUSH_FS_W                   : set[OpFlagIO]({})
    of opPOP_FS_W                    : set[OpFlagIO]({})
    of opBT_RegMem_V_Reg_V           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHLD_RegMem_V_Reg_V_Imm_B   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHLD_RegMem_V_Reg_V_CL_B    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_GS_B                   : set[OpFlagIO]({})
    of opPOP_GS_B                    : set[OpFlagIO]({})
    of opBTS_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHRD_RegMem_V_Reg_V_Imm_B   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHRD_RegMem_V_Reg_V_CL_B    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIMUL_Reg_V_RegMem_V         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opLSS_SS_B_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opBTR_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opLFS_FS_W_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opLGS_GS_B_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opMOVZX_Reg_V_RegMem_B        : set[OpFlagIO]({})
    of opMOVZX_Reg_V_RegMem_W        : set[OpFlagIO]({})
    of opBT_RegMem_V_Imm_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTS_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTR_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTC_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTC_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBSF_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBSR_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOVSX_Reg_V_RegMem_B        : set[OpFlagIO]({})
    of opMOVSX_Reg_V_RegMem_W        : set[OpFlagIO]({})
    of opADC_RegMem_B_Reg_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_Reg_B_RegMem_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_AL_B_Imm_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_EAX_D_Imm_V             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_SS_B                   : set[OpFlagIO]({})
    of opPOP_SS_B                    : set[OpFlagIO]({})
    of opSBB_RegMem_B_Reg_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_Reg_B_RegMem_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_AL_B_Imm_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_EAX_D_Imm_V             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_DS_W                   : set[OpFlagIO]({})
    of opPOP_DS_W                    : set[OpFlagIO]({})
    of opAND_RegMem_B_Reg_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_Reg_B_RegMem_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_AL_B_Imm_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_EAX_D_Imm_V             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opES_ES_W                     : set[OpFlagIO]({})
    of opDAA_AL_B                    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_B_Reg_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_Reg_B_RegMem_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_AL_B_Imm_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_EAX_D_Imm_V             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCS_CS_W                     : set[OpFlagIO]({})
    of opDAS_AL_B                    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_B_Reg_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_Reg_B_RegMem_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_AL_B_Imm_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_EAX_D_Imm_V             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSS_SS_B                     : set[OpFlagIO]({})
    of opAAA_AL_B_AH_B               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_B_Reg_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_V_Reg_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_Reg_B_RegMem_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_Reg_V_RegMem_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_AL_B_Imm_B              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_EAX_D_Imm_V             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opDS_DS_W                     : set[OpFlagIO]({})
    of opAAS_AL_B_AH_B               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opINC_EAX_D                   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opINC_ECX_D                   : set[OpFlagIO]({})
    of opINC_EDX_D                   : set[OpFlagIO]({})
    of opINC_EBX_D                   : set[OpFlagIO]({})
    of opINC_ESP_D                   : set[OpFlagIO]({})
    of opINC_EBP_D                   : set[OpFlagIO]({})
    of opINC_ESI_D                   : set[OpFlagIO]({})
    of opINC_EDI_D                   : set[OpFlagIO]({})
    of opDEC_EAX_D                   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opDEC_ECX_D                   : set[OpFlagIO]({})
    of opDEC_EDX_D                   : set[OpFlagIO]({})
    of opDEC_EBX_D                   : set[OpFlagIO]({})
    of opDEC_ESP_D                   : set[OpFlagIO]({})
    of opDEC_EBP_D                   : set[OpFlagIO]({})
    of opDEC_ESI_D                   : set[OpFlagIO]({})
    of opDEC_EDI_D                   : set[OpFlagIO]({})
    of opPUSH_EAX_D                  : set[OpFlagIO]({})
    of opPUSH_ECX_D                  : set[OpFlagIO]({})
    of opPUSH_EDX_D                  : set[OpFlagIO]({})
    of opPUSH_EBX_D                  : set[OpFlagIO]({})
    of opPUSH_ESP_D                  : set[OpFlagIO]({})
    of opPUSH_EBP_D                  : set[OpFlagIO]({})
    of opPUSH_ESI_D                  : set[OpFlagIO]({})
    of opPUSH_EDI_D                  : set[OpFlagIO]({})
    of opPOP_EAX_D                   : set[OpFlagIO]({})
    of opPOP_ECX_D                   : set[OpFlagIO]({})
    of opPOP_EDX_D                   : set[OpFlagIO]({})
    of opPOP_EBX_D                   : set[OpFlagIO]({})
    of opPOP_ESP_D                   : set[OpFlagIO]({})
    of opPOP_EBP_D                   : set[OpFlagIO]({})
    of opPOP_ESI_D                   : set[OpFlagIO]({})
    of opPOP_EDI_D                   : set[OpFlagIO]({})
    of opPUSHA_AX_W_CX_W_DX_W_STACK_V: set[OpFlagIO]({})
    of opPOPA_DI_W_SI_W_BP_W_STACK_V : set[OpFlagIO]({})
    of opBOUND_Reg_V_Mem_A_EFLAGS_D  : set[OpFlagIO]({opfInterrupt, })
    of opARPL_RegMem_W_Reg_W         : set[OpFlagIO]({opfZero, })
    of opFS_FS_W                     : set[OpFlagIO]({})
    of opGS_GS_B                     : set[OpFlagIO]({})
    of opPUSH_Imm_V                  : set[OpFlagIO]({})
    of opIMUL_Reg_V_RegMem_V_Imm_V   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_Imm_B                  : set[OpFlagIO]({})
    of opIMUL_Reg_V_RegMem_V_Imm_B   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opINS_Mem_B_DX_W              : set[OpFlagIO]({})
    of opINS_Mem_V_DX_W              : set[OpFlagIO]({})
    of opOUTS_DX_W_Mem_B             : set[OpFlagIO]({})
    of opOUTS_DX_W_Mem_V             : set[OpFlagIO]({})
    of opJO_Imm_B                    : set[OpFlagIO]({})
    of opJNO_Imm_B                   : set[OpFlagIO]({})
    of opJC_Imm_B                    : set[OpFlagIO]({})
    of opJNC_Imm_B                   : set[OpFlagIO]({})
    of opJZ_Imm_B                    : set[OpFlagIO]({})
    of opJNZ_Imm_B                   : set[OpFlagIO]({})
    of opJBE_Imm_B                   : set[OpFlagIO]({})
    of opJNBE_Imm_B                  : set[OpFlagIO]({})
    of opJS_Imm_B                    : set[OpFlagIO]({})
    of opJNS_Imm_B                   : set[OpFlagIO]({})
    of opJP_Imm_B                    : set[OpFlagIO]({})
    of opJNP_Imm_B                   : set[OpFlagIO]({})
    of opJL_Imm_B                    : set[OpFlagIO]({})
    of opJNL_Imm_B                   : set[OpFlagIO]({})
    of opJLE_Imm_B                   : set[OpFlagIO]({})
    of opJG_Imm_B                    : set[OpFlagIO]({})
    of opADD_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_RegMem_B_Imm_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_RegMem_V_Imm_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_RegMem_V_Imm_V           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_RegMem_V_Imm_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_RegMem_V_Imm_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_RegMem_V_Imm_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_V_Imm_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_V_Imm_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_V_Imm_V          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_RegMem_B_Reg_B         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_RegMem_V_Reg_V         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXCHG_Reg_B_RegMem_B         : set[OpFlagIO]({})
    of opXCHG_Reg_V_RegMem_V         : set[OpFlagIO]({})
    of opMOV_RegMem_B_Reg_B          : set[OpFlagIO]({})
    of opMOV_RegMem_V_Reg_V          : set[OpFlagIO]({})
    of opMOV_Reg_B_RegMem_B          : set[OpFlagIO]({})
    of opMOV_Reg_V_RegMem_V          : set[OpFlagIO]({})
    of opMOV_Mem_W_SREG_W            : set[OpFlagIO]({})
    of opLEA_Reg_V_Mem_V             : set[OpFlagIO]({})
    of opMOV_SREG_W_RegMem_W         : set[OpFlagIO]({})
    of opPOP_RegMem_V                : set[OpFlagIO]({})
    of opXCHG_EAX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_ECX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EDX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EBX_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_ESP_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EBP_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_ESI_D_EAX_D            : set[OpFlagIO]({})
    of opXCHG_EDI_D_EAX_D            : set[OpFlagIO]({})
    of opCWDE_EAX_D_AX_W             : set[OpFlagIO]({})
    of opCDQ_EDX_D_EAX_D             : set[OpFlagIO]({})
    of opCALLF_A_P                   : set[OpFlagIO]({})
    of opPUSHFD_EFLAGS_D             : set[OpFlagIO]({})
    of opPOPFD_EFLAGS_D              : set[OpFlagIO]({})
    of opSAHF_AH_B                   : set[OpFlagIO]({opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opLAHF_AH_B                   : set[OpFlagIO]({})
    of opMOV_AL_B_Imm_B              : set[OpFlagIO]({})
    of opMOV_EAX_D_Imm_V             : set[OpFlagIO]({})
    of opMOV_Imm_B_AL_B              : set[OpFlagIO]({})
    of opMOV_Imm_V_EAX_D             : set[OpFlagIO]({})
    of opMOVS_Mem_B_Mem_B            : set[OpFlagIO]({})
    of opMOVS_Mem_V_Mem_V            : set[OpFlagIO]({})
    of opCMPS_Mem_B_Mem_B            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMPS_Mem_V_Mem_V            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_AL_B_Imm_B             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_EAX_D_Imm_V            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSTOS_Mem_B_AL_B             : set[OpFlagIO]({})
    of opSTOS_Mem_V_EAX_D            : set[OpFlagIO]({})
    of opLODS_AL_B_Mem_B             : set[OpFlagIO]({})
    of opLODS_EAX_D_Mem_V            : set[OpFlagIO]({})
    of opSCAS_Mem_B_AL_B             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSCAS_Mem_V_EAX_D            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_Reg_B_Imm_B             : set[OpFlagIO]({})
    of opMOV_Reg_V_Imm_V             : set[OpFlagIO]({})
    of opROL_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_B_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_V_Imm_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRETN_Imm_W                  : set[OpFlagIO]({})
    of opRETN                        : set[OpFlagIO]({})
    of opLES_ES_W_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opLDS_DS_W_Reg_V_Mem_P        : set[OpFlagIO]({})
    of opMOV_RegMem_B_Imm_B          : set[OpFlagIO]({})
    of opMOV_RegMem_V_Imm_V          : set[OpFlagIO]({})
    of opENTER_EBP_D_Imm_W_Imm_B     : set[OpFlagIO]({})
    of opLEAVE_EBP_D                 : set[OpFlagIO]({})
    of opRETF_Imm_W                  : set[OpFlagIO]({})
    of opRETF                        : set[OpFlagIO]({})
    of opINT_Three_B_EFLAGS_D        : set[OpFlagIO]({opfInterrupt, })
    of opINT_Imm_B_EFLAGS_D          : set[OpFlagIO]({opfInterrupt, })
    of opINTO_EFLAGS_D               : set[OpFlagIO]({opfInterrupt, })
    of opIRET_EFLAGS_D               : set[OpFlagIO]({})
    of opROL_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_B_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_V_One_B          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_B_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_V_CL_B           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAMX_AL_B_AH_B_Imm_B         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAAM_AL_B_AH_B               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADX_AL_B_AH_B_Imm_B         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAAD_AL_B_AH_B               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSALC_AL_B                   : set[OpFlagIO]({})
    of opXLAT_AL_B_Mem_B             : set[OpFlagIO]({})
    of opLOOPNZ_ECX_D_Imm_B          : set[OpFlagIO]({})
    of opLOOPZ_ECX_D_Imm_B           : set[OpFlagIO]({})
    of opLOOP_ECX_D_Imm_B            : set[OpFlagIO]({})
    of opJCXZ_Imm_B_CX_W             : set[OpFlagIO]({})
    of opIN_AL_B_Imm_B               : set[OpFlagIO]({})
    of opIN_EAX_D_Imm_B              : set[OpFlagIO]({})
    of opOUT_Imm_B_AL_B              : set[OpFlagIO]({})
    of opOUT_Imm_B_EAX_D             : set[OpFlagIO]({})
    of opCALL_Imm_V                  : set[OpFlagIO]({})
    of opJMP_Imm_V                   : set[OpFlagIO]({})
    of opJMPF_A_P                    : set[OpFlagIO]({})
    of opJMP_Imm_B                   : set[OpFlagIO]({})
    of opIN_AL_B_DX_W                : set[OpFlagIO]({})
    of opIN_EAX_D_DX_W               : set[OpFlagIO]({})
    of opOUT_DX_W_AL_B               : set[OpFlagIO]({})
    of opOUT_DX_W_EAX_D              : set[OpFlagIO]({})
    of opLOCK                        : set[OpFlagIO]({})
    of opINT1_EFLAGS_D               : set[OpFlagIO]({opfInterrupt, })
    of opREPNZ_ECX_D                 : set[OpFlagIO]({})
    of opREPZ_ECX_D                  : set[OpFlagIO]({})
    of opHLT                         : set[OpFlagIO]({})
    of opCMC                         : set[OpFlagIO]({opfCarry, })
    of opTEST_RegMem_B_Imm_B         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opNOT_RegMem_B                : set[OpFlagIO]({})
    of opNEG_RegMem_B                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMUL_AX_W_AL_B_RegMem_B      : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIMUL_AX_W_AL_B_RegMem_B     : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opDIV_AL_B_AH_B_AX_W_RegMem_B : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIDIV_AL_B_AH_B_AX_W_RegMem_B: set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_RegMem_V_Imm_V         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opNOT_RegMem_V                : set[OpFlagIO]({})
    of opNEG_RegMem_V                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMUL_EDX_D_EAX_D_RegMem_V    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIMUL_EDX_D_EAX_D_RegMem_V   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opDIV_EDX_D_EAX_D_RegMem_V    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIDIV_EDX_D_EAX_D_RegMem_V   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCLC                         : set[OpFlagIO]({opfCarry, })
    of opSTC                         : set[OpFlagIO]({opfCarry, })
    of opCLI                         : set[OpFlagIO]({opfInterrupt, })
    of opSTI                         : set[OpFlagIO]({opfInterrupt, })
    of opCLD                         : set[OpFlagIO]({opfDirection, })
    of opSTD                         : set[OpFlagIO]({opfDirection, })
    of opINC_RegMem_B                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opDEC_RegMem_B                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opINC_RegMem_V                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opDEC_RegMem_V                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opCALL_RegMem_V               : set[OpFlagIO]({})
    of opCALLF_Mem_P                 : set[OpFlagIO]({})
    of opJMP_RegMem_V                : set[OpFlagIO]({})
    of opJMPF_Mem_P                  : set[OpFlagIO]({})
    of opPUSH_RegMem_V               : set[OpFlagIO]({})

func getUsedOperands*(code: ICode): array[4, Option[(OpAddrKind, OpDataKind)]] =
  const nop = none((OpAddrKind, OpDataKind))
  const
    DaF = opFlag
    DaA = opData1616_3232
    DaB = opData8
    DaD = opData32
    DaW = opData16
    DaV = opData16_32
    DaP = opData48
    AdOne = opAddrImm1
    AdThree = opAddrImm3
    AdImm = opAddrImm
    AdReg = opAddrReg
    AdMem = opAddrMem
    AdRegMem = opAddrRegMem
    AdA = opAddrPtr
    AdAX = opAddrGRegAX
    AdAH = opAddrGRegAH
    AdAL = opAddrGRegAL
    AdDI = opAddrGRegDI
    AdDX = opAddrGRegDX
    AdBP = opAddrGRegBP
    AdCL = opAddrGRegCL
    AdSI = opAddrGRegSI
    AdEAX = opAddrGRegEAX
    AdEBX = opAddrGRegEBX
    AdECX = opAddrGRegECX
    AdEDX = opAddrGRegEDX
    AdEDI = opAddrGRegEDI
    AdEBP = opAddrGRegEBP
    AdESI = opAddrGRegESI
    AdESP = opAddrGRegESP
    AdSREG = opAddrSReg
    AdDS = opAddrSRegDS
    AdES = opAddrSRegES
    AdCX = opAddrSRegCX
    AdFS = opAddrSRegFS
    AdCS = opAddrSRegCS
    AdGS = opAddrSRegGS
    AdSS = opAddrSRegSS
    AdGDTR = opAddrDTregGDTR
    AdIDTR = opAddrDTregIDTR
    AdLDTR = opAddrDTregLDTR
    AdTR = opAddrDTregTR
    AdMSW = opAddrMSW
    AdCR = opAddrCR
    AdDR = opAddrDR
    AdSTACK = opAddrStack
    AdEFLAGS = opAddrEflags
  case code:
    of opADD_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opADD_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opADD_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opADD_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opADD_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opADD_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opPUSH_ES_W                   : [some((AdES, DaW))       , nop                     , nop                     , nop                     , ]
    of opPOP_ES_W                    : [some((AdES, DaW))       , nop                     , nop                     , nop                     , ]
    of opOR_RegMem_B_Reg_B           : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opOR_RegMem_V_Reg_V           : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opOR_Reg_B_RegMem_B           : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opOR_Reg_V_RegMem_V           : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opOR_AL_B_Imm_B               : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opOR_EAX_D_Imm_V              : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opPUSH_CS_W                   : [some((AdCS, DaW))       , nop                     , nop                     , nop                     , ]
    of opSLDT_Mem_W_LDTR_W           : [some((AdMem, DaW))      , some((AdLDTR, DaW))     , nop                     , nop                     , ]
    of opSTR_Mem_W_TR_W              : [some((AdMem, DaW))      , some((AdTR, DaW))       , nop                     , nop                     , ]
    of opLLDT_LDTR_W_RegMem_W        : [some((AdLDTR, DaW))     , some((AdRegMem, DaW))   , nop                     , nop                     , ]
    of opLTR_TR_W_RegMem_W           : [some((AdTR, DaW))       , some((AdRegMem, DaW))   , nop                     , nop                     , ]
    of opVERR_RegMem_W               : [some((AdRegMem, DaW))   , nop                     , nop                     , nop                     , ]
    of opVERW_RegMem_W               : [some((AdRegMem, DaW))   , nop                     , nop                     , nop                     , ]
    of opSGDT_Mem_P_GDTR_W           : [some((AdMem, DaP))      , some((AdGDTR, DaW))     , nop                     , nop                     , ]
    of opSIDT_Mem_P_IDTR_W           : [some((AdMem, DaP))      , some((AdIDTR, DaW))     , nop                     , nop                     , ]
    of opLGDT_GDTR_W_Mem_P           : [some((AdGDTR, DaW))     , some((AdMem, DaP))      , nop                     , nop                     , ]
    of opLIDT_IDTR_W_Mem_P           : [some((AdIDTR, DaW))     , some((AdMem, DaP))      , nop                     , nop                     , ]
    of opSMSW_Mem_W_MSW_W            : [some((AdMem, DaW))      , some((AdMSW, DaW))      , nop                     , nop                     , ]
    of opLMSW_MSW_W_RegMem_W         : [some((AdMSW, DaW))      , some((AdRegMem, DaW))   , nop                     , nop                     , ]
    of opLAR_Reg_V_Mem_W             : [some((AdReg, DaV))      , some((AdMem, DaW))      , nop                     , nop                     , ]
    of opLSL_Reg_V_Mem_W             : [some((AdReg, DaV))      , some((AdMem, DaW))      , nop                     , nop                     , ]
    of opCLTS_CR_F                   : [some((AdCR, DaF))       , nop                     , nop                     , nop                     , ]
    of opUD2                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opMOV_Reg_D_CR_F              : [some((AdReg, DaD))      , some((AdCR, DaF))       , nop                     , nop                     , ]
    of opMOV_Reg_D_DR_F              : [some((AdReg, DaD))      , some((AdDR, DaF))       , nop                     , nop                     , ]
    of opMOV_CR_F_Reg_D              : [some((AdCR, DaF))       , some((AdReg, DaD))      , nop                     , nop                     , ]
    of opMOV_DR_F_Reg_D              : [some((AdDR, DaF))       , some((AdReg, DaD))      , nop                     , nop                     , ]
    of opJO_Imm_V                    : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNO_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJB_Imm_V                    : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNB_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJZ_Imm_V                    : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNZ_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJBE_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNBE_Imm_V                  : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJS_Imm_V                    : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNS_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJP_Imm_V                    : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNP_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJL_Imm_V                    : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNL_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJLE_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJNLE_Imm_V                  : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opSETO_RegMem_B               : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNO_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETB_RegMem_B               : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNB_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETZ_RegMem_B               : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNZ_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETBE_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNBE_RegMem_B             : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETS_RegMem_B               : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNS_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETP_RegMem_B               : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNP_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETL_RegMem_B               : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNL_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETLE_RegMem_B              : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opSETNLE_RegMem_B             : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opPUSH_FS_W                   : [some((AdFS, DaW))       , nop                     , nop                     , nop                     , ]
    of opPOP_FS_W                    : [some((AdFS, DaW))       , nop                     , nop                     , nop                     , ]
    of opBT_RegMem_V_Reg_V           : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opSHLD_RegMem_V_Reg_V_Imm_B   : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , some((AdImm, DaB))      , nop                     , ]
    of opSHLD_RegMem_V_Reg_V_CL_B    : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , some((AdCL, DaB))       , nop                     , ]
    of opPUSH_GS_B                   : [some((AdGS, DaB))       , nop                     , nop                     , nop                     , ]
    of opPOP_GS_B                    : [some((AdGS, DaB))       , nop                     , nop                     , nop                     , ]
    of opBTS_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opSHRD_RegMem_V_Reg_V_Imm_B   : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , some((AdImm, DaB))      , nop                     , ]
    of opSHRD_RegMem_V_Reg_V_CL_B    : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , some((AdCL, DaB))       , nop                     , ]
    of opIMUL_Reg_V_RegMem_V         : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opLSS_SS_B_Reg_V_Mem_P        : [some((AdSS, DaB))       , some((AdReg, DaV))      , some((AdMem, DaP))      , nop                     , ]
    of opBTR_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opLFS_FS_W_Reg_V_Mem_P        : [some((AdFS, DaW))       , some((AdReg, DaV))      , some((AdMem, DaP))      , nop                     , ]
    of opLGS_GS_B_Reg_V_Mem_P        : [some((AdGS, DaB))       , some((AdReg, DaV))      , some((AdMem, DaP))      , nop                     , ]
    of opMOVZX_Reg_V_RegMem_B        : [some((AdReg, DaV))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opMOVZX_Reg_V_RegMem_W        : [some((AdReg, DaV))      , some((AdRegMem, DaW))   , nop                     , nop                     , ]
    of opBT_RegMem_V_Imm_B           : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opBTS_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opBTR_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opBTC_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opBTC_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opBSF_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opBSR_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opMOVSX_Reg_V_RegMem_B        : [some((AdReg, DaV))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opMOVSX_Reg_V_RegMem_W        : [some((AdReg, DaV))      , some((AdRegMem, DaW))   , nop                     , nop                     , ]
    of opADC_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opADC_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opADC_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opADC_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opADC_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opADC_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opPUSH_SS_B                   : [some((AdSS, DaB))       , nop                     , nop                     , nop                     , ]
    of opPOP_SS_B                    : [some((AdSS, DaB))       , nop                     , nop                     , nop                     , ]
    of opSBB_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opSBB_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opSBB_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opSBB_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opSBB_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSBB_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opPUSH_DS_W                   : [some((AdDS, DaW))       , nop                     , nop                     , nop                     , ]
    of opPOP_DS_W                    : [some((AdDS, DaW))       , nop                     , nop                     , nop                     , ]
    of opAND_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opAND_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opAND_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opAND_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opAND_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opAND_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opES_ES_W                     : [some((AdES, DaW))       , nop                     , nop                     , nop                     , ]
    of opDAA_AL_B                    : [some((AdAL, DaB))       , nop                     , nop                     , nop                     , ]
    of opSUB_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opSUB_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opSUB_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opSUB_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opSUB_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSUB_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opCS_CS_W                     : [some((AdCS, DaW))       , nop                     , nop                     , nop                     , ]
    of opDAS_AL_B                    : [some((AdAL, DaB))       , nop                     , nop                     , nop                     , ]
    of opXOR_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opXOR_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opXOR_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opXOR_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opXOR_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opXOR_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opSS_SS_B                     : [some((AdSS, DaB))       , nop                     , nop                     , nop                     , ]
    of opAAA_AL_B_AH_B               : [some((AdAL, DaB))       , some((AdAH, DaB))       , nop                     , nop                     , ]
    of opCMP_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opCMP_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opCMP_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opCMP_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opCMP_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opCMP_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opDS_DS_W                     : [some((AdDS, DaW))       , nop                     , nop                     , nop                     , ]
    of opAAS_AL_B_AH_B               : [some((AdAL, DaB))       , some((AdAH, DaB))       , nop                     , nop                     , ]
    of opINC_EAX_D                   : [some((AdEAX, DaD))      , nop                     , nop                     , nop                     , ]
    of opINC_ECX_D                   : [some((AdECX, DaD))      , nop                     , nop                     , nop                     , ]
    of opINC_EDX_D                   : [some((AdEDX, DaD))      , nop                     , nop                     , nop                     , ]
    of opINC_EBX_D                   : [some((AdEBX, DaD))      , nop                     , nop                     , nop                     , ]
    of opINC_ESP_D                   : [some((AdESP, DaD))      , nop                     , nop                     , nop                     , ]
    of opINC_EBP_D                   : [some((AdEBP, DaD))      , nop                     , nop                     , nop                     , ]
    of opINC_ESI_D                   : [some((AdESI, DaD))      , nop                     , nop                     , nop                     , ]
    of opINC_EDI_D                   : [some((AdEDI, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_EAX_D                   : [some((AdEAX, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_ECX_D                   : [some((AdECX, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_EDX_D                   : [some((AdEDX, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_EBX_D                   : [some((AdEBX, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_ESP_D                   : [some((AdESP, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_EBP_D                   : [some((AdEBP, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_ESI_D                   : [some((AdESI, DaD))      , nop                     , nop                     , nop                     , ]
    of opDEC_EDI_D                   : [some((AdEDI, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_EAX_D                  : [some((AdEAX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_ECX_D                  : [some((AdECX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_EDX_D                  : [some((AdEDX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_EBX_D                  : [some((AdEBX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_ESP_D                  : [some((AdESP, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_EBP_D                  : [some((AdEBP, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_ESI_D                  : [some((AdESI, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSH_EDI_D                  : [some((AdEDI, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_EAX_D                   : [some((AdEAX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_ECX_D                   : [some((AdECX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_EDX_D                   : [some((AdEDX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_EBX_D                   : [some((AdEBX, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_ESP_D                   : [some((AdESP, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_EBP_D                   : [some((AdEBP, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_ESI_D                   : [some((AdESI, DaD))      , nop                     , nop                     , nop                     , ]
    of opPOP_EDI_D                   : [some((AdEDI, DaD))      , nop                     , nop                     , nop                     , ]
    of opPUSHA_AX_W_CX_W_DX_W_STACK_V: [some((AdAX, DaW))       , some((AdCX, DaW))       , some((AdDX, DaW))       , some((AdSTACK, DaV))    , ]
    of opPOPA_DI_W_SI_W_BP_W_STACK_V : [some((AdDI, DaW))       , some((AdSI, DaW))       , some((AdBP, DaW))       , some((AdSTACK, DaV))    , ]
    of opBOUND_Reg_V_Mem_A_EFLAGS_D  : [some((AdReg, DaV))      , some((AdMem, DaA))      , some((AdEFLAGS, DaD))   , nop                     , ]
    of opARPL_RegMem_W_Reg_W         : [some((AdRegMem, DaW))   , some((AdReg, DaW))      , nop                     , nop                     , ]
    of opFS_FS_W                     : [some((AdFS, DaW))       , nop                     , nop                     , nop                     , ]
    of opGS_GS_B                     : [some((AdGS, DaB))       , nop                     , nop                     , nop                     , ]
    of opPUSH_Imm_V                  : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opIMUL_Reg_V_RegMem_V_Imm_V   : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , ]
    of opPUSH_Imm_B                  : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opIMUL_Reg_V_RegMem_V_Imm_B   : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , ]
    of opINS_Mem_B_DX_W              : [some((AdMem, DaB))      , some((AdDX, DaW))       , nop                     , nop                     , ]
    of opINS_Mem_V_DX_W              : [some((AdMem, DaV))      , some((AdDX, DaW))       , nop                     , nop                     , ]
    of opOUTS_DX_W_Mem_B             : [some((AdDX, DaW))       , some((AdMem, DaB))      , nop                     , nop                     , ]
    of opOUTS_DX_W_Mem_V             : [some((AdDX, DaW))       , some((AdMem, DaV))      , nop                     , nop                     , ]
    of opJO_Imm_B                    : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJNO_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJC_Imm_B                    : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJNC_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJZ_Imm_B                    : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJNZ_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJBE_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJNBE_Imm_B                  : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJS_Imm_B                    : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJNS_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJP_Imm_B                    : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJNP_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJL_Imm_B                    : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJNL_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJLE_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opJG_Imm_B                    : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opADD_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opOR_RegMem_B_Imm_B           : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opADC_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSBB_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opAND_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSUB_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opXOR_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opCMP_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opADD_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opOR_RegMem_V_Imm_V           : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opADC_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opSBB_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opAND_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opSUB_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opXOR_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opCMP_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opTEST_RegMem_B_Reg_B         : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opTEST_RegMem_V_Reg_V         : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opXCHG_Reg_B_RegMem_B         : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opXCHG_Reg_V_RegMem_V         : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opMOV_RegMem_B_Reg_B          : [some((AdRegMem, DaB))   , some((AdReg, DaB))      , nop                     , nop                     , ]
    of opMOV_RegMem_V_Reg_V          : [some((AdRegMem, DaV))   , some((AdReg, DaV))      , nop                     , nop                     , ]
    of opMOV_Reg_B_RegMem_B          : [some((AdReg, DaB))      , some((AdRegMem, DaB))   , nop                     , nop                     , ]
    of opMOV_Reg_V_RegMem_V          : [some((AdReg, DaV))      , some((AdRegMem, DaV))   , nop                     , nop                     , ]
    of opMOV_Mem_W_SREG_W            : [some((AdMem, DaW))      , some((AdSREG, DaW))     , nop                     , nop                     , ]
    of opLEA_Reg_V_Mem_V             : [some((AdReg, DaV))      , some((AdMem, DaV))      , nop                     , nop                     , ]
    of opMOV_SREG_W_RegMem_W         : [some((AdSREG, DaW))     , some((AdRegMem, DaW))   , nop                     , nop                     , ]
    of opPOP_RegMem_V                : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
    of opXCHG_EAX_D_EAX_D            : [some((AdEAX, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opXCHG_ECX_D_EAX_D            : [some((AdECX, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opXCHG_EDX_D_EAX_D            : [some((AdEDX, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opXCHG_EBX_D_EAX_D            : [some((AdEBX, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opXCHG_ESP_D_EAX_D            : [some((AdESP, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opXCHG_EBP_D_EAX_D            : [some((AdEBP, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opXCHG_ESI_D_EAX_D            : [some((AdESI, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opXCHG_EDI_D_EAX_D            : [some((AdEDI, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opCWDE_EAX_D_AX_W             : [some((AdEAX, DaD))      , some((AdAX, DaW))       , nop                     , nop                     , ]
    of opCDQ_EDX_D_EAX_D             : [some((AdEDX, DaD))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opCALLF_A_P                   : [some((AdA, DaP))        , nop                     , nop                     , nop                     , ]
    of opPUSHFD_EFLAGS_D             : [some((AdEFLAGS, DaD))   , nop                     , nop                     , nop                     , ]
    of opPOPFD_EFLAGS_D              : [some((AdEFLAGS, DaD))   , nop                     , nop                     , nop                     , ]
    of opSAHF_AH_B                   : [some((AdAH, DaB))       , nop                     , nop                     , nop                     , ]
    of opLAHF_AH_B                   : [some((AdAH, DaB))       , nop                     , nop                     , nop                     , ]
    of opMOV_AL_B_Imm_B              : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opMOV_EAX_D_Imm_V             : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opMOV_Imm_B_AL_B              : [some((AdImm, DaB))      , some((AdAL, DaB))       , nop                     , nop                     , ]
    of opMOV_Imm_V_EAX_D             : [some((AdImm, DaV))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opMOVS_Mem_B_Mem_B            : [some((AdMem, DaB))      , some((AdMem, DaB))      , nop                     , nop                     , ]
    of opMOVS_Mem_V_Mem_V            : [some((AdMem, DaV))      , some((AdMem, DaV))      , nop                     , nop                     , ]
    of opCMPS_Mem_B_Mem_B            : [some((AdMem, DaB))      , some((AdMem, DaB))      , nop                     , nop                     , ]
    of opCMPS_Mem_V_Mem_V            : [some((AdMem, DaV))      , some((AdMem, DaV))      , nop                     , nop                     , ]
    of opTEST_AL_B_Imm_B             : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opTEST_EAX_D_Imm_V            : [some((AdEAX, DaD))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opSTOS_Mem_B_AL_B             : [some((AdMem, DaB))      , some((AdAL, DaB))       , nop                     , nop                     , ]
    of opSTOS_Mem_V_EAX_D            : [some((AdMem, DaV))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opLODS_AL_B_Mem_B             : [some((AdAL, DaB))       , some((AdMem, DaB))      , nop                     , nop                     , ]
    of opLODS_EAX_D_Mem_V            : [some((AdEAX, DaD))      , some((AdMem, DaV))      , nop                     , nop                     , ]
    of opSCAS_Mem_B_AL_B             : [some((AdMem, DaB))      , some((AdAL, DaB))       , nop                     , nop                     , ]
    of opSCAS_Mem_V_EAX_D            : [some((AdMem, DaV))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opMOV_Reg_B_Imm_B             : [some((AdReg, DaB))      , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opMOV_Reg_V_Imm_V             : [some((AdReg, DaV))      , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opROL_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opROR_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opRCL_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opRCR_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSHL_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSHR_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSAL_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSAR_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opROL_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opROR_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opRCL_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opRCR_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSHL_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSHR_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSAL_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opSAR_RegMem_V_Imm_B          : [some((AdRegMem, DaV))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opRETN_Imm_W                  : [some((AdImm, DaW))      , nop                     , nop                     , nop                     , ]
    of opRETN                        : [nop                     , nop                     , nop                     , nop                     , ]
    of opLES_ES_W_Reg_V_Mem_P        : [some((AdES, DaW))       , some((AdReg, DaV))      , some((AdMem, DaP))      , nop                     , ]
    of opLDS_DS_W_Reg_V_Mem_P        : [some((AdDS, DaW))       , some((AdReg, DaV))      , some((AdMem, DaP))      , nop                     , ]
    of opMOV_RegMem_B_Imm_B          : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opMOV_RegMem_V_Imm_V          : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opENTER_EBP_D_Imm_W_Imm_B     : [some((AdEBP, DaD))      , some((AdImm, DaW))      , some((AdImm, DaB))      , nop                     , ]
    of opLEAVE_EBP_D                 : [some((AdEBP, DaD))      , nop                     , nop                     , nop                     , ]
    of opRETF_Imm_W                  : [some((AdImm, DaW))      , nop                     , nop                     , nop                     , ]
    of opRETF                        : [nop                     , nop                     , nop                     , nop                     , ]
    of opINT_Three_B_EFLAGS_D        : [some((AdThree, DaB))    , some((AdEFLAGS, DaD))   , nop                     , nop                     , ]
    of opINT_Imm_B_EFLAGS_D          : [some((AdImm, DaB))      , some((AdEFLAGS, DaD))   , nop                     , nop                     , ]
    of opINTO_EFLAGS_D               : [some((AdEFLAGS, DaD))   , nop                     , nop                     , nop                     , ]
    of opIRET_EFLAGS_D               : [some((AdEFLAGS, DaD))   , nop                     , nop                     , nop                     , ]
    of opROL_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opROR_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opRCL_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opRCR_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSHL_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSHR_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSAL_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSAR_RegMem_B_One_B          : [some((AdRegMem, DaB))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opROL_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opROR_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opRCL_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opRCR_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSHL_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSHR_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSAL_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opSAR_RegMem_V_One_B          : [some((AdRegMem, DaV))   , some((AdOne, DaB))      , nop                     , nop                     , ]
    of opROL_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opROR_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opRCL_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opRCR_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSHL_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSHR_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSAL_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSAR_RegMem_B_CL_B           : [some((AdRegMem, DaB))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opROL_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opROR_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opRCL_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opRCR_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSHL_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSHR_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSAL_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opSAR_RegMem_V_CL_B           : [some((AdRegMem, DaV))   , some((AdCL, DaB))       , nop                     , nop                     , ]
    of opAMX_AL_B_AH_B_Imm_B         : [some((AdAL, DaB))       , some((AdAH, DaB))       , some((AdImm, DaB))      , nop                     , ]
    of opAAM_AL_B_AH_B               : [some((AdAL, DaB))       , some((AdAH, DaB))       , nop                     , nop                     , ]
    of opADX_AL_B_AH_B_Imm_B         : [some((AdAL, DaB))       , some((AdAH, DaB))       , some((AdImm, DaB))      , nop                     , ]
    of opAAD_AL_B_AH_B               : [some((AdAL, DaB))       , some((AdAH, DaB))       , nop                     , nop                     , ]
    of opSALC_AL_B                   : [some((AdAL, DaB))       , nop                     , nop                     , nop                     , ]
    of opXLAT_AL_B_Mem_B             : [some((AdAL, DaB))       , some((AdMem, DaB))      , nop                     , nop                     , ]
    of opLOOPNZ_ECX_D_Imm_B          : [some((AdECX, DaD))      , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opLOOPZ_ECX_D_Imm_B           : [some((AdECX, DaD))      , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opLOOP_ECX_D_Imm_B            : [some((AdECX, DaD))      , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opJCXZ_Imm_B_CX_W             : [some((AdImm, DaB))      , some((AdCX, DaW))       , nop                     , nop                     , ]
    of opIN_AL_B_Imm_B               : [some((AdAL, DaB))       , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opIN_EAX_D_Imm_B              : [some((AdEAX, DaD))      , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opOUT_Imm_B_AL_B              : [some((AdImm, DaB))      , some((AdAL, DaB))       , nop                     , nop                     , ]
    of opOUT_Imm_B_EAX_D             : [some((AdImm, DaB))      , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opCALL_Imm_V                  : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJMP_Imm_V                   : [some((AdImm, DaV))      , nop                     , nop                     , nop                     , ]
    of opJMPF_A_P                    : [some((AdA, DaP))        , nop                     , nop                     , nop                     , ]
    of opJMP_Imm_B                   : [some((AdImm, DaB))      , nop                     , nop                     , nop                     , ]
    of opIN_AL_B_DX_W                : [some((AdAL, DaB))       , some((AdDX, DaW))       , nop                     , nop                     , ]
    of opIN_EAX_D_DX_W               : [some((AdEAX, DaD))      , some((AdDX, DaW))       , nop                     , nop                     , ]
    of opOUT_DX_W_AL_B               : [some((AdDX, DaW))       , some((AdAL, DaB))       , nop                     , nop                     , ]
    of opOUT_DX_W_EAX_D              : [some((AdDX, DaW))       , some((AdEAX, DaD))      , nop                     , nop                     , ]
    of opLOCK                        : [nop                     , nop                     , nop                     , nop                     , ]
    of opINT1_EFLAGS_D               : [some((AdEFLAGS, DaD))   , nop                     , nop                     , nop                     , ]
    of opREPNZ_ECX_D                 : [some((AdECX, DaD))      , nop                     , nop                     , nop                     , ]
    of opREPZ_ECX_D                  : [some((AdECX, DaD))      , nop                     , nop                     , nop                     , ]
    of opHLT                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opCMC                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opTEST_RegMem_B_Imm_B         : [some((AdRegMem, DaB))   , some((AdImm, DaB))      , nop                     , nop                     , ]
    of opNOT_RegMem_B                : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opNEG_RegMem_B                : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opMUL_AX_W_AL_B_RegMem_B      : [some((AdAX, DaW))       , some((AdAL, DaB))       , some((AdRegMem, DaB))   , nop                     , ]
    of opIMUL_AX_W_AL_B_RegMem_B     : [some((AdAX, DaW))       , some((AdAL, DaB))       , some((AdRegMem, DaB))   , nop                     , ]
    of opDIV_AL_B_AH_B_AX_W_RegMem_B : [some((AdAL, DaB))       , some((AdAH, DaB))       , some((AdAX, DaW))       , some((AdRegMem, DaB))   , ]
    of opIDIV_AL_B_AH_B_AX_W_RegMem_B: [some((AdAL, DaB))       , some((AdAH, DaB))       , some((AdAX, DaW))       , some((AdRegMem, DaB))   , ]
    of opTEST_RegMem_V_Imm_V         : [some((AdRegMem, DaV))   , some((AdImm, DaV))      , nop                     , nop                     , ]
    of opNOT_RegMem_V                : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
    of opNEG_RegMem_V                : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
    of opMUL_EDX_D_EAX_D_RegMem_V    : [some((AdEDX, DaD))      , some((AdEAX, DaD))      , some((AdRegMem, DaV))   , nop                     , ]
    of opIMUL_EDX_D_EAX_D_RegMem_V   : [some((AdEDX, DaD))      , some((AdEAX, DaD))      , some((AdRegMem, DaV))   , nop                     , ]
    of opDIV_EDX_D_EAX_D_RegMem_V    : [some((AdEDX, DaD))      , some((AdEAX, DaD))      , some((AdRegMem, DaV))   , nop                     , ]
    of opIDIV_EDX_D_EAX_D_RegMem_V   : [some((AdEDX, DaD))      , some((AdEAX, DaD))      , some((AdRegMem, DaV))   , nop                     , ]
    of opCLC                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opSTC                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opCLI                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opSTI                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opCLD                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opSTD                         : [nop                     , nop                     , nop                     , nop                     , ]
    of opINC_RegMem_B                : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opDEC_RegMem_B                : [some((AdRegMem, DaB))   , nop                     , nop                     , nop                     , ]
    of opINC_RegMem_V                : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
    of opDEC_RegMem_V                : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
    of opCALL_RegMem_V               : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
    of opCALLF_Mem_P                 : [some((AdMem, DaP))      , nop                     , nop                     , nop                     , ]
    of opJMP_RegMem_V                : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
    of opJMPF_Mem_P                  : [some((AdMem, DaP))      , nop                     , nop                     , nop                     , ]
    of opPUSH_RegMem_V               : [some((AdRegMem, DaV))   , nop                     , nop                     , nop                     , ]
