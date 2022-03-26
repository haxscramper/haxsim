import ./syntaxes, std/options

type
  ICode* = enum
    opADD_RegMem_W_Reg_W           = (0x00_00_00, "ADD r/m8 r8")
    opADD_RegMem_Vs_Reg_Vs         = (0x01_00_00, "ADD r/m16/32 r16/32")
    opADD_Reg_W_RegMem_W           = (0x02_00_00, "ADD r8 r/m8")
    opADD_Reg_Vs_RegMem_Vs         = (0x03_00_00, "ADD r16/32 r/m16/32")
    opADD_AL_W_Imm_W               = (0x04_00_00, "ADD AL imm8")
    opADD_EAX_D_Imm_Vs             = (0x05_00_00, "ADD EAX imm16/32")
    opPUSH_Imm_Vs                  = (0x06_00_00, "PUSH ES")
    opPOP_Imm_Vs                   = (0x07_00_00, "POP ES")
    opOR_RegMem_W_Reg_W            = (0x08_00_00, "OR r/m8 r8")
    opOR_RegMem_Vs_Reg_Vs          = (0x09_00_00, "OR r/m16/32 r16/32")
    opOR_Reg_W_RegMem_W            = (0x0A_00_00, "OR r8 r/m8")
    opOR_Reg_Vs_RegMem_Vs          = (0x0B_00_00, "OR r16/32 r/m16/32")
    opOR_AL_W_Imm_W                = (0x0C_00_00, "OR AL imm8")
    opOR_EAX_D_Imm_Vs              = (0x0D_00_00, "OR eAX imm16/32")
    opPUSH_Imm_Vs                  = (0x0E_00_00, "PUSH CS")
    opSLDT_Mem_W_Imm_Vs            = (0x0F_00_00, "SLDT m16 LDTR")
    opSTR_Mem_W_Imm_Vs             = (0x0F_00_01, "STR m16 TR")
    opLLDT_Imm_Vs_Imm_W            = (0x0F_00_02, "LLDT LDTR r/m16")
    opLTR_Imm_Vs_Imm_W             = (0x0F_00_03, "LTR TR r/m16")
    opVERR_Imm_W                   = (0x0F_00_04, "VERR r/m16")
    opVERW_Imm_W                   = (0x0F_00_05, "VERW r/m16")
    opSGDT_Imm_Vs_Imm_Vs           = (0x0F_00_10, "SGDT m GDTR")
    opSIDT_Imm_Vs_Imm_Vs           = (0x0F_00_11, "SIDT m IDTR")
    opLGDT_Imm_Vs_Imm_Vs           = (0x0F_00_12, "LGDT GDTR m")
    opLIDT_Imm_Vs_Imm_Vs           = (0x0F_00_13, "LIDT IDTR m")
    opSMSW_Mem_W_Imm_Vs            = (0x0F_00_14, "SMSW m16 MSW")
    opLMSW_Imm_Vs_Imm_W            = (0x0F_00_16, "LMSW MSW r/m16")
    opINVLPG_Imm_Vs                = (0x0F_00_17, "INVLPG m")
    opLAR_Reg_Vs_Mem_W             = (0x0F_00_20, "LAR r16/32 m16")
    opLSL_Reg_Vs_Mem_W             = (0x0F_00_30, "LSL r16/32 m16")
    opCLTS_Imm_Vs                  = (0x0F_00_60, "CLTS CR0")
    opUD2                          = (0x0F_00_B0, "UD2")
    opMOV_Reg_D_Imm_Vs             = (0x0F_02_00, "MOV r32 CRn")
    opMOV_Reg_D_Imm_Vs             = (0x0F_02_10, "MOV r32 DRn")
    opMOV_Imm_Vs_Reg_D             = (0x0F_02_20, "MOV CRn r32")
    opMOV_Imm_Vs_Reg_D             = (0x0F_02_30, "MOV DRn r32")
    opJO_Imm_Vs                    = (0x0F_08_00, "JO rel16/32")
    opJNO_Imm_Vs                   = (0x0F_08_10, "JNO rel16/32")
    opJB_Imm_Vs                    = (0x0F_08_20, "JB rel16/32")
    opJNB_Imm_Vs                   = (0x0F_08_30, "JNB rel16/32")
    opJZ_Imm_Vs                    = (0x0F_08_40, "JZ rel16/32")
    opJNZ_Imm_Vs                   = (0x0F_08_50, "JNZ rel16/32")
    opJBE_Imm_Vs                   = (0x0F_08_60, "JBE rel16/32")
    opJNBE_Imm_Vs                  = (0x0F_08_70, "JNBE rel16/32")
    opJS_Imm_Vs                    = (0x0F_08_80, "JS rel16/32")
    opJNS_Imm_Vs                   = (0x0F_08_90, "JNS rel16/32")
    opJP_Imm_Vs                    = (0x0F_08_A0, "JP rel16/32")
    opJNP_Imm_Vs                   = (0x0F_08_B0, "JNP rel16/32")
    opJL_Imm_Vs                    = (0x0F_08_C0, "JL rel16/32")
    opJNL_Imm_Vs                   = (0x0F_08_D0, "JNL rel16/32")
    opJLE_Imm_Vs                   = (0x0F_08_E0, "JLE rel16/32")
    opJNLE_Imm_Vs                  = (0x0F_08_F0, "JNLE rel16/32")
    opSETO_RegMem_W                = (0x0F_09_00, "SETO r/m8")
    opSETNO_RegMem_W               = (0x0F_09_10, "SETNO r/m8")
    opSETB_RegMem_W                = (0x0F_09_20, "SETB r/m8")
    opSETNB_RegMem_W               = (0x0F_09_30, "SETNB r/m8")
    opSETZ_RegMem_W                = (0x0F_09_40, "SETZ r/m8")
    opSETNZ_RegMem_W               = (0x0F_09_50, "SETNZ r/m8")
    opSETBE_RegMem_W               = (0x0F_09_60, "SETBE r/m8")
    opSETNBE_RegMem_W              = (0x0F_09_70, "SETNBE r/m8")
    opSETS_RegMem_W                = (0x0F_09_80, "SETS r/m8")
    opSETNS_RegMem_W               = (0x0F_09_90, "SETNS r/m8")
    opSETP_RegMem_W                = (0x0F_09_A0, "SETP r/m8")
    opSETNP_RegMem_W               = (0x0F_09_B0, "SETNP r/m8")
    opSETL_RegMem_W                = (0x0F_09_C0, "SETL r/m8")
    opSETNL_RegMem_W               = (0x0F_09_D0, "SETNL r/m8")
    opSETLE_RegMem_W               = (0x0F_09_E0, "SETLE r/m8")
    opSETNLE_RegMem_W              = (0x0F_09_F0, "SETNLE r/m8")
    opPUSH_Imm_Vs                  = (0x0F_0A_00, "PUSH FS")
    opPOP_Imm_Vs                   = (0x0F_0A_10, "POP FS")
    opBT_RegMem_Vs_Reg_Vs          = (0x0F_0A_30, "BT r/m16/32 r16/32")
    opSHLD_RegMem_Vs_Reg_Vs_Imm_W  = (0x0F_0A_40, "SHLD r/m16/32 r16/32 imm8")
    opSHLD_RegMem_Vs_Reg_Vs_Imm_Vs = (0x0F_0A_50, "SHLD r/m16/32 r16/32 CL")
    opPUSH_Imm_Vs                  = (0x0F_0A_80, "PUSH GS")
    opPOP_Imm_Vs                   = (0x0F_0A_90, "POP GS")
    opBTS_RegMem_Vs_Reg_Vs         = (0x0F_0A_B0, "BTS r/m16/32 r16/32")
    opSHRD_RegMem_Vs_Reg_Vs_Imm_W  = (0x0F_0A_C0, "SHRD r/m16/32 r16/32 imm8")
    opSHRD_RegMem_Vs_Reg_Vs_Imm_Vs = (0x0F_0A_D0, "SHRD r/m16/32 r16/32 CL")
    opIMUL_Reg_Vs_RegMem_Vs        = (0x0F_0A_F0, "IMUL r16/32 r/m16/32")
    opLSS_Imm_Vs_Reg_Vs_Imm_Vs     = (0x0F_0B_20, "LSS SS r16/32 m16:16/32")
    opBTR_RegMem_Vs_Reg_Vs         = (0x0F_0B_30, "BTR r/m16/32 r16/32")
    opLFS_Imm_Vs_Reg_Vs_Imm_Vs     = (0x0F_0B_40, "LFS FS r16/32 m16:16/32")
    opLGS_Imm_Vs_Reg_Vs_Imm_Vs     = (0x0F_0B_50, "LGS GS r16/32 m16:16/32")
    opMOVZX_Reg_Vs_RegMem_W        = (0x0F_0B_60, "MOVZX r16/32 r/m8")
    opMOVZX_Reg_Vs_Imm_W           = (0x0F_0B_70, "MOVZX r16/32 r/m16")
    opBT_RegMem_Vs_Imm_W           = (0x0F_0B_A4, "BT r/m16/32 imm8")
    opBTS_RegMem_Vs_Imm_W          = (0x0F_0B_A5, "BTS r/m16/32 imm8")
    opBTR_RegMem_Vs_Imm_W          = (0x0F_0B_A6, "BTR r/m16/32 imm8")
    opBTC_RegMem_Vs_Imm_W          = (0x0F_0B_A7, "BTC r/m16/32 imm8")
    opBTC_RegMem_Vs_Reg_Vs         = (0x0F_0B_B0, "BTC r/m16/32 r16/32")
    opBSF_Reg_Vs_RegMem_Vs         = (0x0F_0B_C0, "BSF r16/32 r/m16/32")
    opBSR_Reg_Vs_RegMem_Vs         = (0x0F_0B_D0, "BSR r16/32 r/m16/32")
    opMOVSX_Reg_Vs_RegMem_W        = (0x0F_0B_E0, "MOVSX r16/32 r/m8")
    opMOVSX_Reg_Vs_Imm_W           = (0x0F_0B_F0, "MOVSX r16/32 r/m16")
    opADC_RegMem_W_Reg_W           = (0x10_00_00, "ADC r/m8 r8")
    opADC_RegMem_Vs_Reg_Vs         = (0x11_00_00, "ADC r/m16/32 r16/32")
    opADC_Reg_W_RegMem_W           = (0x12_00_00, "ADC r8 r/m8")
    opADC_Reg_Vs_RegMem_Vs         = (0x13_00_00, "ADC r16/32 r/m16/32")
    opADC_AL_W_Imm_W               = (0x14_00_00, "ADC AL imm8")
    opADC_EAX_D_Imm_Vs             = (0x15_00_00, "ADC eAX imm16/32")
    opPUSH_Imm_Vs                  = (0x16_00_00, "PUSH SS")
    opPOP_Imm_Vs                   = (0x17_00_00, "POP SS")
    opSBB_RegMem_W_Reg_W           = (0x18_00_00, "SBB r/m8 r8")
    opSBB_RegMem_Vs_Reg_Vs         = (0x19_00_00, "SBB r/m16/32 r16/32")
    opSBB_Reg_W_RegMem_W           = (0x1A_00_00, "SBB r8 r/m8")
    opSBB_Reg_Vs_RegMem_Vs         = (0x1B_00_00, "SBB r16/32 r/m16/32")
    opSBB_AL_W_Imm_W               = (0x1C_00_00, "SBB AL imm8")
    opSBB_EAX_D_Imm_Vs             = (0x1D_00_00, "SBB eAX imm16/32")
    opPUSH_Imm_Vs                  = (0x1E_00_00, "PUSH DS")
    opPOP_Imm_Vs                   = (0x1F_00_00, "POP DS")
    opAND_RegMem_W_Reg_W           = (0x20_00_00, "AND r/m8 r8")
    opAND_RegMem_Vs_Reg_Vs         = (0x21_00_00, "AND r/m16/32 r16/32")
    opAND_Reg_W_RegMem_W           = (0x22_00_00, "AND r8 r/m8")
    opAND_Reg_Vs_RegMem_Vs         = (0x23_00_00, "AND r16/32 r/m16/32")
    opAND_AL_W_Imm_W               = (0x24_00_00, "AND AL imm8")
    opAND_EAX_D_Imm_Vs             = (0x25_00_00, "AND eAX imm16/32")
    opES_Imm_Vs                    = (0x26_00_00, "ES ES")
    opDAA_AL_W                     = (0x27_00_00, "DAA AL")
    opSUB_RegMem_W_Reg_W           = (0x28_00_00, "SUB r/m8 r8")
    opSUB_RegMem_Vs_Reg_Vs         = (0x29_00_00, "SUB r/m16/32 r16/32")
    opSUB_Reg_W_RegMem_W           = (0x2A_00_00, "SUB r8 r/m8")
    opSUB_Reg_Vs_RegMem_Vs         = (0x2B_00_00, "SUB r16/32 r/m16/32")
    opSUB_AL_W_Imm_W               = (0x2C_00_00, "SUB AL imm8")
    opSUB_EAX_D_Imm_Vs             = (0x2D_00_00, "SUB eAX imm16/32")
    opCS_Imm_Vs                    = (0x2E_00_00, "CS CS")
    opDAS_AL_W                     = (0x2F_00_00, "DAS AL")
    opXOR_RegMem_W_Reg_W           = (0x30_00_00, "XOR r/m8 r8")
    opXOR_RegMem_Vs_Reg_Vs         = (0x31_00_00, "XOR r/m16/32 r16/32")
    opXOR_Reg_W_RegMem_W           = (0x32_00_00, "XOR r8 r/m8")
    opXOR_Reg_Vs_RegMem_Vs         = (0x33_00_00, "XOR r16/32 r/m16/32")
    opXOR_AL_W_Imm_W               = (0x34_00_00, "XOR AL imm8")
    opXOR_EAX_D_Imm_Vs             = (0x35_00_00, "XOR eAX imm16/32")
    opSS_Imm_Vs                    = (0x36_00_00, "SS SS")
    opAAA_AL_W_AH_W                = (0x37_00_00, "AAA AL AH")
    opCMP_RegMem_W_Reg_W           = (0x38_00_00, "CMP r/m8 r8")
    opCMP_RegMem_Vs_Reg_Vs         = (0x39_00_00, "CMP r/m16/32 r16/32")
    opCMP_Reg_W_RegMem_W           = (0x3A_00_00, "CMP r8 r/m8")
    opCMP_Reg_Vs_RegMem_Vs         = (0x3B_00_00, "CMP r16/32 r/m16/32")
    opCMP_AL_W_Imm_W               = (0x3C_00_00, "CMP AL imm8")
    opCMP_EAX_D_Imm_Vs             = (0x3D_00_00, "CMP eAX imm16/32")
    opDS_Imm_Vs                    = (0x3E_00_00, "DS DS")
    opAAS_AL_W_AH_W                = (0x3F_00_00, "AAS AL AH")
    opINC_Reg_Vs                   = (0x40_00_00, "INC r16/32")
    opDEC_Reg_Vs                   = (0x48_00_00, "DEC r16/32")
    opPUSH_Reg_Vs                  = (0x50_00_00, "PUSH r16/32")
    opPOP_Reg_Vs                   = (0x58_00_00, "POP r16/32")
    opPUSHA_AX_W_Imm_Vs_Imm_Vs_Imm_Vs = (0x60_00_00, "PUSHA AX CX DX ...")
    opPOPA_Imm_Vs_Imm_Vs_Imm_Vs_Imm_Vs = (0x61_00_00, "POPA DI SI BP ...")
    opBOUND_Reg_Vs_Imm_Vs_Imm_Vs   = (0x62_00_00, "BOUND r16/32 m16/32&16/32 eFlags")
    opARPL_Imm_W_Reg_W             = (0x63_00_00, "ARPL r/m16 r16")
    opFS_Imm_Vs                    = (0x64_00_00, "FS FS")
    opGS_Imm_Vs                    = (0x65_00_00, "GS GS")
    opPUSH_Imm_Vs                  = (0x68_00_00, "PUSH imm16/32")
    opIMUL_Reg_Vs_RegMem_Vs_Imm_Vs = (0x69_00_00, "IMUL r16/32 r/m16/32 imm16/32")
    opPUSH_Imm_W                   = (0x6A_00_00, "PUSH imm8")
    opIMUL_Reg_Vs_RegMem_Vs_Imm_W  = (0x6B_00_00, "IMUL r16/32 r/m16/32 imm8")
    opINS_Mem_W_Imm_Vs             = (0x6C_00_00, "INS m8 DX")
    opINS_Mem_Vs_Imm_Vs            = (0x6D_00_00, "INS m16/32 DX")
    opOUTS_Imm_Vs_Mem_W            = (0x6E_00_00, "OUTS DX m8")
    opOUTS_Imm_Vs_Mem_Vs           = (0x6F_00_00, "OUTS DX m16/32")
    opJO_Imm_Vs                    = (0x70_00_00, "JO rel8")
    opJNO_Imm_Vs                   = (0x71_00_00, "JNO rel8")
    opJC_Imm_Vs                    = (0x72_00_00, "JC rel8")
    opJNC_Imm_Vs                   = (0x73_00_00, "JNC rel8")
    opJZ_Imm_Vs                    = (0x74_00_00, "JZ rel8")
    opJNZ_Imm_Vs                   = (0x75_00_00, "JNZ rel8")
    opJBE_Imm_Vs                   = (0x76_00_00, "JBE rel8")
    opJNBE_Imm_Vs                  = (0x77_00_00, "JNBE rel8")
    opJS_Imm_Vs                    = (0x78_00_00, "JS rel8")
    opJNS_Imm_Vs                   = (0x79_00_00, "JNS rel8")
    opJP_Imm_Vs                    = (0x7A_00_00, "JP rel8")
    opJNP_Imm_Vs                   = (0x7B_00_00, "JNP rel8")
    opJL_Imm_Vs                    = (0x7C_00_00, "JL rel8")
    opJNL_Imm_Vs                   = (0x7D_00_00, "JNL rel8")
    opJLE_Imm_Vs                   = (0x7E_00_00, "JLE rel8")
    opJG_Imm_Vs                    = (0x7F_00_00, "JG rel8")
    opADD_RegMem_W_Imm_W           = (0x80_00_00, "ADD r/m8 imm8")
    opOR_RegMem_W_Imm_W            = (0x80_00_01, "OR r/m8 imm8")
    opADC_RegMem_W_Imm_W           = (0x80_00_02, "ADC r/m8 imm8")
    opSBB_RegMem_W_Imm_W           = (0x80_00_03, "SBB r/m8 imm8")
    opAND_RegMem_W_Imm_W           = (0x80_00_04, "AND r/m8 imm8")
    opSUB_RegMem_W_Imm_W           = (0x80_00_05, "SUB r/m8 imm8")
    opXOR_RegMem_W_Imm_W           = (0x80_00_06, "XOR r/m8 imm8")
    opCMP_RegMem_W_Imm_W           = (0x80_00_07, "CMP r/m8 imm8")
    opADD_RegMem_Vs_Imm_Vs         = (0x81_00_00, "ADD r/m16/32 imm16/32")
    opOR_RegMem_Vs_Imm_Vs          = (0x81_00_01, "OR r/m16/32 imm16/32")
    opADC_RegMem_Vs_Imm_Vs         = (0x81_00_02, "ADC r/m16/32 imm16/32")
    opSBB_RegMem_Vs_Imm_Vs         = (0x81_00_03, "SBB r/m16/32 imm16/32")
    opAND_RegMem_Vs_Imm_Vs         = (0x81_00_04, "AND r/m16/32 imm16/32")
    opSUB_RegMem_Vs_Imm_Vs         = (0x81_00_05, "SUB r/m16/32 imm16/32")
    opXOR_RegMem_Vs_Imm_Vs         = (0x81_00_06, "XOR r/m16/32 imm16/32")
    opCMP_RegMem_Vs_Imm_Vs         = (0x81_00_07, "CMP r/m16/32 imm16/32")
    opTEST_RegMem_W_Reg_W          = (0x84_00_00, "TEST r/m8 r8")
    opTEST_RegMem_Vs_Reg_Vs        = (0x85_00_00, "TEST r/m16/32 r16/32")
    opXCHG_Reg_W_RegMem_W          = (0x86_00_00, "XCHG r8 r/m8")
    opXCHG_Reg_Vs_RegMem_Vs        = (0x87_00_00, "XCHG r16/32 r/m16/32")
    opMOV_RegMem_W_Reg_W           = (0x88_00_00, "MOV r/m8 r8")
    opMOV_RegMem_Vs_Reg_Vs         = (0x89_00_00, "MOV r/m16/32 r16/32")
    opMOV_Reg_W_RegMem_W           = (0x8A_00_00, "MOV r8 r/m8")
    opMOV_Reg_Vs_RegMem_Vs         = (0x8B_00_00, "MOV r16/32 r/m16/32")
    opMOV_Mem_W_Imm_Vs             = (0x8C_00_00, "MOV m16 Sreg")
    opLEA_Reg_Vs_Imm_Vs            = (0x8D_00_00, "LEA r16/32 m")
    opMOV_Imm_Vs_Imm_W             = (0x8E_00_00, "MOV Sreg r/m16")
    opPOP_RegMem_Vs                = (0x8F_00_00, "POP r/m16/32")
    opXCHG_Reg_Vs_EAX_D            = (0x90_00_00, "XCHG r16/32 eAX")
    opCWDE_EAX_D_AX_W              = (0x98_00_00, "CWDE EAX AX")
    opCDQ_Imm_Vs_EAX_D             = (0x99_00_00, "CDQ EDX EAX")
    opCALLF_Imm_Vs                 = (0x9A_00_00, "CALLF ptr16:16/32")
    opPUSHFD_Imm_Vs                = (0x9C_00_00, "PUSHFD EFlags")
    opPOPFD_Imm_Vs                 = (0x9D_00_00, "POPFD EFlags")
    opSAHF_AH_W                    = (0x9E_00_00, "SAHF AH")
    opLAHF_AH_W                    = (0x9F_00_00, "LAHF AH")
    opMOV_AL_W_Imm_Vs              = (0xA0_00_00, "MOV AL moffs8")
    opMOV_EAX_D_Imm_Vs             = (0xA1_00_00, "MOV eAX moffs16/32")
    opMOV_Imm_Vs_AL_W              = (0xA2_00_00, "MOV moffs8 AL")
    opMOV_Imm_Vs_EAX_D             = (0xA3_00_00, "MOV moffs16/32 eAX")
    opMOVS_Mem_W_Mem_W             = (0xA4_00_00, "MOVS m8 m8")
    opMOVS_Mem_Vs_Mem_Vs           = (0xA5_00_00, "MOVS m16/32 m16/32")
    opCMPS_Mem_W_Mem_W             = (0xA6_00_00, "CMPS m8 m8")
    opCMPS_Mem_Vs_Mem_Vs           = (0xA7_00_00, "CMPS m16/32 m16/32")
    opTEST_AL_W_Imm_W              = (0xA8_00_00, "TEST AL imm8")
    opTEST_EAX_D_Imm_Vs            = (0xA9_00_00, "TEST eAX imm16/32")
    opSTOS_Mem_W_AL_W              = (0xAA_00_00, "STOS m8 AL")
    opSTOS_Mem_Vs_EAX_D            = (0xAB_00_00, "STOS m16/32 eAX")
    opLODS_AL_W_Mem_W              = (0xAC_00_00, "LODS AL m8")
    opLODS_EAX_D_Mem_Vs            = (0xAD_00_00, "LODS eAX m16/32")
    opSCAS_Mem_W_AL_W              = (0xAE_00_00, "SCAS m8 AL")
    opSCAS_Mem_Vs_EAX_D            = (0xAF_00_00, "SCAS m16/32 eAX")
    opMOV_Reg_W_Imm_W              = (0xB0_00_00, "MOV r8 imm8")
    opMOV_Reg_Vs_Imm_Vs            = (0xB8_00_00, "MOV r16/32 imm16/32")
    opROL_RegMem_W_Imm_W           = (0xC0_00_00, "ROL r/m8 imm8")
    opROR_RegMem_W_Imm_W           = (0xC0_00_01, "ROR r/m8 imm8")
    opRCL_RegMem_W_Imm_W           = (0xC0_00_02, "RCL r/m8 imm8")
    opRCR_RegMem_W_Imm_W           = (0xC0_00_03, "RCR r/m8 imm8")
    opSHL_RegMem_W_Imm_W           = (0xC0_00_04, "SHL r/m8 imm8")
    opSHR_RegMem_W_Imm_W           = (0xC0_00_05, "SHR r/m8 imm8")
    opSAL_RegMem_W_Imm_W           = (0xC0_00_06, "SAL r/m8 imm8")
    opSAR_RegMem_W_Imm_W           = (0xC0_00_07, "SAR r/m8 imm8")
    opROL_RegMem_Vs_Imm_W          = (0xC1_00_00, "ROL r/m16/32 imm8")
    opROR_RegMem_Vs_Imm_W          = (0xC1_00_01, "ROR r/m16/32 imm8")
    opRCL_RegMem_Vs_Imm_W          = (0xC1_00_02, "RCL r/m16/32 imm8")
    opRCR_RegMem_Vs_Imm_W          = (0xC1_00_03, "RCR r/m16/32 imm8")
    opSHL_RegMem_Vs_Imm_W          = (0xC1_00_04, "SHL r/m16/32 imm8")
    opSHR_RegMem_Vs_Imm_W          = (0xC1_00_05, "SHR r/m16/32 imm8")
    opSAL_RegMem_Vs_Imm_W          = (0xC1_00_06, "SAL r/m16/32 imm8")
    opSAR_RegMem_Vs_Imm_W          = (0xC1_00_07, "SAR r/m16/32 imm8")
    opRETN_Imm_W                   = (0xC2_00_00, "RETN imm16")
    opRETN                         = (0xC3_00_00, "RETN")
    opLES_Imm_Vs_Reg_Vs_Imm_Vs     = (0xC4_00_00, "LES ES r16/32 m16:16/32")
    opLDS_Imm_Vs_Reg_Vs_Imm_Vs     = (0xC5_00_00, "LDS DS r16/32 m16:16/32")
    opMOV_RegMem_W_Imm_W           = (0xC6_00_00, "MOV r/m8 imm8")
    opMOV_RegMem_Vs_Imm_Vs         = (0xC7_00_00, "MOV r/m16/32 imm16/32")
    opENTER_Imm_Vs_Imm_W_Imm_W     = (0xC8_00_00, "ENTER eBP imm16 imm8")
    opLEAVE_Imm_Vs                 = (0xC9_00_00, "LEAVE eBP")
    opRETF_Imm_W                   = (0xCA_00_00, "RETF imm16")
    opRETF                         = (0xCB_00_00, "RETF")
    opINT_Imm_Vs_Imm_Vs            = (0xCC_00_00, "INT 3 eFlags")
    opINT_Imm_W_Imm_Vs             = (0xCD_00_00, "INT imm8 eFlags")
    opINTO_Imm_Vs                  = (0xCE_00_00, "INTO eFlags")
    opIRET_Imm_Vs                  = (0xCF_00_00, "IRET eFlags")
    opROL_RegMem_W_Imm_Vs          = (0xD0_00_00, "ROL r/m8 1")
    opROR_RegMem_W_Imm_Vs          = (0xD0_00_01, "ROR r/m8 1")
    opRCL_RegMem_W_Imm_Vs          = (0xD0_00_02, "RCL r/m8 1")
    opRCR_RegMem_W_Imm_Vs          = (0xD0_00_03, "RCR r/m8 1")
    opSHL_RegMem_W_Imm_Vs          = (0xD0_00_04, "SHL r/m8 1")
    opSHR_RegMem_W_Imm_Vs          = (0xD0_00_05, "SHR r/m8 1")
    opSAL_RegMem_W_Imm_Vs          = (0xD0_00_06, "SAL r/m8 1")
    opSAR_RegMem_W_Imm_Vs          = (0xD0_00_07, "SAR r/m8 1")
    opROL_RegMem_Vs_Imm_Vs         = (0xD1_00_00, "ROL r/m16/32 1")
    opROR_RegMem_Vs_Imm_Vs         = (0xD1_00_01, "ROR r/m16/32 1")
    opRCL_RegMem_Vs_Imm_Vs         = (0xD1_00_02, "RCL r/m16/32 1")
    opRCR_RegMem_Vs_Imm_Vs         = (0xD1_00_03, "RCR r/m16/32 1")
    opSHL_RegMem_Vs_Imm_Vs         = (0xD1_00_04, "SHL r/m16/32 1")
    opSHR_RegMem_Vs_Imm_Vs         = (0xD1_00_05, "SHR r/m16/32 1")
    opSAL_RegMem_Vs_Imm_Vs         = (0xD1_00_06, "SAL r/m16/32 1")
    opSAR_RegMem_Vs_Imm_Vs         = (0xD1_00_07, "SAR r/m16/32 1")
    opROL_RegMem_W_Imm_Vs          = (0xD2_00_00, "ROL r/m8 CL")
    opROR_RegMem_W_Imm_Vs          = (0xD2_00_01, "ROR r/m8 CL")
    opRCL_RegMem_W_Imm_Vs          = (0xD2_00_02, "RCL r/m8 CL")
    opRCR_RegMem_W_Imm_Vs          = (0xD2_00_03, "RCR r/m8 CL")
    opSHL_RegMem_W_Imm_Vs          = (0xD2_00_04, "SHL r/m8 CL")
    opSHR_RegMem_W_Imm_Vs          = (0xD2_00_05, "SHR r/m8 CL")
    opSAL_RegMem_W_Imm_Vs          = (0xD2_00_06, "SAL r/m8 CL")
    opSAR_RegMem_W_Imm_Vs          = (0xD2_00_07, "SAR r/m8 CL")
    opROL_RegMem_Vs_Imm_Vs         = (0xD3_00_00, "ROL r/m16/32 CL")
    opROR_RegMem_Vs_Imm_Vs         = (0xD3_00_01, "ROR r/m16/32 CL")
    opRCL_RegMem_Vs_Imm_Vs         = (0xD3_00_02, "RCL r/m16/32 CL")
    opRCR_RegMem_Vs_Imm_Vs         = (0xD3_00_03, "RCR r/m16/32 CL")
    opSHL_RegMem_Vs_Imm_Vs         = (0xD3_00_04, "SHL r/m16/32 CL")
    opSHR_RegMem_Vs_Imm_Vs         = (0xD3_00_05, "SHR r/m16/32 CL")
    opSAL_RegMem_Vs_Imm_Vs         = (0xD3_00_06, "SAL r/m16/32 CL")
    opSAR_RegMem_Vs_Imm_Vs         = (0xD3_00_07, "SAR r/m16/32 CL")
    opAMX_AL_W_AH_W_Imm_W          = (0xD4_00_00, "AMX AL AH imm8")
    opAAM_AL_W_AH_W                = (0xD4_00_A0, "AAM AL AH")
    opADX_AL_W_AH_W_Imm_W          = (0xD5_00_00, "ADX AL AH imm8")
    opAAD_AL_W_AH_W                = (0xD5_00_A0, "AAD AL AH")
    opSALC_AL_W                    = (0xD6_00_00, "SALC AL")
    opXLAT_AL_W_Mem_W              = (0xD7_00_00, "XLAT AL m8")
    opLOOPNZ_Imm_Vs_Imm_Vs         = (0xE0_00_00, "LOOPNZ eCX rel8")
    opLOOPZ_Imm_Vs_Imm_Vs          = (0xE1_00_00, "LOOPZ eCX rel8")
    opLOOP_Imm_Vs_Imm_Vs           = (0xE2_00_00, "LOOP eCX rel8")
    opJCXZ_Imm_Vs_Imm_Vs           = (0xE3_00_00, "JCXZ rel8 CX")
    opIN_AL_W_Imm_W                = (0xE4_00_00, "IN AL imm8")
    opIN_EAX_D_Imm_W               = (0xE5_00_00, "IN eAX imm8")
    opOUT_Imm_W_AL_W               = (0xE6_00_00, "OUT imm8 AL")
    opOUT_Imm_W_EAX_D              = (0xE7_00_00, "OUT imm8 eAX")
    opCALL_Imm_Vs                  = (0xE8_00_00, "CALL rel16/32")
    opJMP_Imm_Vs                   = (0xE9_00_00, "JMP rel16/32")
    opJMPF_Imm_Vs                  = (0xEA_00_00, "JMPF ptr16:16/32")
    opJMP_Imm_Vs                   = (0xEB_00_00, "JMP rel8")
    opIN_AL_W_Imm_Vs               = (0xEC_00_00, "IN AL DX")
    opIN_EAX_D_Imm_Vs              = (0xED_00_00, "IN eAX DX")
    opOUT_Imm_Vs_AL_W              = (0xEE_00_00, "OUT DX AL")
    opOUT_Imm_Vs_EAX_D             = (0xEF_00_00, "OUT DX eAX")
    opLOCK                         = (0xF0_00_00, "LOCK")
    opINT1_Imm_Vs                  = (0xF1_00_00, "INT1 eFlags")
    opREPNZ_Imm_Vs                 = (0xF2_00_00, "REPNZ eCX")
    opREPZ_Imm_Vs                  = (0xF3_00_00, "REPZ eCX")
    opHLT                          = (0xF4_00_00, "HLT")
    opCMC                          = (0xF5_00_00, "CMC")
    opTEST_RegMem_W_Imm_W          = (0xF6_00_00, "TEST r/m8 imm8")
    opNOT_RegMem_W                 = (0xF6_00_02, "NOT r/m8")
    opNEG_RegMem_W                 = (0xF6_00_03, "NEG r/m8")
    opMUL_AX_W_AL_W_RegMem_W       = (0xF6_00_04, "MUL AX AL r/m8")
    opIMUL_AX_W_AL_W_RegMem_W      = (0xF6_00_05, "IMUL AX AL r/m8")
    opDIV_AL_W_AH_W_AX_W_RegMem_W  = (0xF6_00_06, "DIV AL AH AX r/m8")
    opIDIV_AL_W_AH_W_AX_W_RegMem_W = (0xF6_00_07, "IDIV AL AH AX r/m8")
    opTEST_RegMem_Vs_Imm_Vs        = (0xF7_00_00, "TEST r/m16/32 imm16/32")
    opNOT_RegMem_Vs                = (0xF7_00_02, "NOT r/m16/32")
    opNEG_RegMem_Vs                = (0xF7_00_03, "NEG r/m16/32")
    opMUL_Imm_Vs_EAX_D_RegMem_Vs   = (0xF7_00_04, "MUL eDX eAX r/m16/32")
    opIMUL_Imm_Vs_EAX_D_RegMem_Vs  = (0xF7_00_05, "IMUL eDX eAX r/m16/32")
    opDIV_Imm_Vs_EAX_D_RegMem_Vs   = (0xF7_00_06, "DIV eDX eAX r/m16/32")
    opIDIV_Imm_Vs_EAX_D_RegMem_Vs  = (0xF7_00_07, "IDIV eDX eAX r/m16/32")
    opCLC                          = (0xF8_00_00, "CLC")
    opSTC                          = (0xF9_00_00, "STC")
    opCLI                          = (0xFA_00_00, "CLI")
    opSTI                          = (0xFB_00_00, "STI")
    opCLD                          = (0xFC_00_00, "CLD")
    opSTD                          = (0xFD_00_00, "STD")
    opINC_RegMem_W                 = (0xFE_00_00, "INC r/m8")
    opDEC_RegMem_W                 = (0xFE_00_01, "DEC r/m8")
    opINC_RegMem_Vs                = (0xFF_00_00, "INC r/m16/32")
    opDEC_RegMem_Vs                = (0xFF_00_01, "DEC r/m16/32")
    opCALL_RegMem_Vs               = (0xFF_00_02, "CALL r/m16/32")
    opCALLF_Imm_Vs                 = (0xFF_00_03, "CALLF m16:16/32")
    opJMP_RegMem_Vs                = (0xFF_00_04, "JMP r/m16/32")
    opJMPF_Imm_Vs                  = (0xFF_00_05, "JMPF m16:16/32")
    opPUSH_RegMem_Vs               = (0xFF_00_06, "PUSH r/m16/32")

func getTestedFlags*(code: ICode): set[OpFlagIO] =
  case code:
    of opADD_RegMem_W_Reg_W          : set[OpFlagIO]({})
    of opADD_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opADD_Reg_W_RegMem_W          : set[OpFlagIO]({})
    of opADD_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opADD_AL_W_Imm_W              : set[OpFlagIO]({})
    of opADD_EAX_D_Imm_Vs            : set[OpFlagIO]({})
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opOR_RegMem_W_Reg_W           : set[OpFlagIO]({})
    of opOR_RegMem_Vs_Reg_Vs         : set[OpFlagIO]({})
    of opOR_Reg_W_RegMem_W           : set[OpFlagIO]({})
    of opOR_Reg_Vs_RegMem_Vs         : set[OpFlagIO]({})
    of opOR_AL_W_Imm_W               : set[OpFlagIO]({})
    of opOR_EAX_D_Imm_Vs             : set[OpFlagIO]({})
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opSLDT_Mem_W_Imm_Vs           : set[OpFlagIO]({})
    of opSTR_Mem_W_Imm_Vs            : set[OpFlagIO]({})
    of opLLDT_Imm_Vs_Imm_W           : set[OpFlagIO]({})
    of opLTR_Imm_Vs_Imm_W            : set[OpFlagIO]({})
    of opVERR_Imm_W                  : set[OpFlagIO]({})
    of opVERW_Imm_W                  : set[OpFlagIO]({})
    of opSGDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opSIDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opLGDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opLIDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opSMSW_Mem_W_Imm_Vs           : set[OpFlagIO]({})
    of opLMSW_Imm_Vs_Imm_W           : set[OpFlagIO]({})
    of opINVLPG_Imm_Vs               : set[OpFlagIO]({})
    of opLAR_Reg_Vs_Mem_W            : set[OpFlagIO]({})
    of opLSL_Reg_Vs_Mem_W            : set[OpFlagIO]({})
    of opCLTS_Imm_Vs                 : set[OpFlagIO]({})
    of opUD2                         : set[OpFlagIO]({})
    of opMOV_Reg_D_Imm_Vs            : set[OpFlagIO]({})
    of opMOV_Reg_D_Imm_Vs            : set[OpFlagIO]({})
    of opMOV_Imm_Vs_Reg_D            : set[OpFlagIO]({})
    of opMOV_Imm_Vs_Reg_D            : set[OpFlagIO]({})
    of opJO_Imm_Vs                   : set[OpFlagIO]({opfOverflow, })
    of opJNO_Imm_Vs                  : set[OpFlagIO]({opfOverflow, })
    of opJB_Imm_Vs                   : set[OpFlagIO]({opfCarry, })
    of opJNB_Imm_Vs                  : set[OpFlagIO]({opfCarry, })
    of opJZ_Imm_Vs                   : set[OpFlagIO]({opfZero, })
    of opJNZ_Imm_Vs                  : set[OpFlagIO]({opfZero, })
    of opJBE_Imm_Vs                  : set[OpFlagIO]({opfZero, opfCarry, })
    of opJNBE_Imm_Vs                 : set[OpFlagIO]({opfZero, opfCarry, })
    of opJS_Imm_Vs                   : set[OpFlagIO]({opfSigned, })
    of opJNS_Imm_Vs                  : set[OpFlagIO]({opfSigned, })
    of opJP_Imm_Vs                   : set[OpFlagIO]({opfParity, })
    of opJNP_Imm_Vs                  : set[OpFlagIO]({opfParity, })
    of opJL_Imm_Vs                   : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJNL_Imm_Vs                  : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJLE_Imm_Vs                  : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opJNLE_Imm_Vs                 : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opSETO_RegMem_W               : set[OpFlagIO]({opfOverflow, })
    of opSETNO_RegMem_W              : set[OpFlagIO]({opfOverflow, })
    of opSETB_RegMem_W               : set[OpFlagIO]({opfCarry, })
    of opSETNB_RegMem_W              : set[OpFlagIO]({opfCarry, })
    of opSETZ_RegMem_W               : set[OpFlagIO]({opfZero, })
    of opSETNZ_RegMem_W              : set[OpFlagIO]({opfZero, })
    of opSETBE_RegMem_W              : set[OpFlagIO]({opfZero, opfCarry, })
    of opSETNBE_RegMem_W             : set[OpFlagIO]({opfZero, opfCarry, })
    of opSETS_RegMem_W               : set[OpFlagIO]({opfSigned, })
    of opSETNS_RegMem_W              : set[OpFlagIO]({opfSigned, })
    of opSETP_RegMem_W               : set[OpFlagIO]({opfParity, })
    of opSETNP_RegMem_W              : set[OpFlagIO]({opfParity, })
    of opSETL_RegMem_W               : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opSETNL_RegMem_W              : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opSETLE_RegMem_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opSETNLE_RegMem_W             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opBT_RegMem_Vs_Reg_Vs         : set[OpFlagIO]({})
    of opSHLD_RegMem_Vs_Reg_Vs_Imm_W : set[OpFlagIO]({})
    of opSHLD_RegMem_Vs_Reg_Vs_Imm_Vs: set[OpFlagIO]({})
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opBTS_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opSHRD_RegMem_Vs_Reg_Vs_Imm_W : set[OpFlagIO]({})
    of opSHRD_RegMem_Vs_Reg_Vs_Imm_Vs: set[OpFlagIO]({})
    of opIMUL_Reg_Vs_RegMem_Vs       : set[OpFlagIO]({})
    of opLSS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opBTR_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opLFS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opLGS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opMOVZX_Reg_Vs_RegMem_W       : set[OpFlagIO]({})
    of opMOVZX_Reg_Vs_Imm_W          : set[OpFlagIO]({})
    of opBT_RegMem_Vs_Imm_W          : set[OpFlagIO]({})
    of opBTS_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opBTR_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opBTC_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opBTC_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opBSF_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opBSR_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opMOVSX_Reg_Vs_RegMem_W       : set[OpFlagIO]({})
    of opMOVSX_Reg_Vs_Imm_W          : set[OpFlagIO]({})
    of opADC_RegMem_W_Reg_W          : set[OpFlagIO]({opfCarry, })
    of opADC_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfCarry, })
    of opADC_Reg_W_RegMem_W          : set[OpFlagIO]({opfCarry, })
    of opADC_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfCarry, })
    of opADC_AL_W_Imm_W              : set[OpFlagIO]({opfCarry, })
    of opADC_EAX_D_Imm_Vs            : set[OpFlagIO]({opfCarry, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opSBB_RegMem_W_Reg_W          : set[OpFlagIO]({opfCarry, })
    of opSBB_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfCarry, })
    of opSBB_Reg_W_RegMem_W          : set[OpFlagIO]({opfCarry, })
    of opSBB_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfCarry, })
    of opSBB_AL_W_Imm_W              : set[OpFlagIO]({opfCarry, })
    of opSBB_EAX_D_Imm_Vs            : set[OpFlagIO]({opfCarry, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opAND_RegMem_W_Reg_W          : set[OpFlagIO]({})
    of opAND_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opAND_Reg_W_RegMem_W          : set[OpFlagIO]({})
    of opAND_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opAND_AL_W_Imm_W              : set[OpFlagIO]({})
    of opAND_EAX_D_Imm_Vs            : set[OpFlagIO]({})
    of opES_Imm_Vs                   : set[OpFlagIO]({})
    of opDAA_AL_W                    : set[OpFlagIO]({opfAbove, opfCarry, })
    of opSUB_RegMem_W_Reg_W          : set[OpFlagIO]({})
    of opSUB_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opSUB_Reg_W_RegMem_W          : set[OpFlagIO]({})
    of opSUB_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opSUB_AL_W_Imm_W              : set[OpFlagIO]({})
    of opSUB_EAX_D_Imm_Vs            : set[OpFlagIO]({})
    of opCS_Imm_Vs                   : set[OpFlagIO]({})
    of opDAS_AL_W                    : set[OpFlagIO]({opfAbove, opfCarry, })
    of opXOR_RegMem_W_Reg_W          : set[OpFlagIO]({})
    of opXOR_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opXOR_Reg_W_RegMem_W          : set[OpFlagIO]({})
    of opXOR_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opXOR_AL_W_Imm_W              : set[OpFlagIO]({})
    of opXOR_EAX_D_Imm_Vs            : set[OpFlagIO]({})
    of opSS_Imm_Vs                   : set[OpFlagIO]({})
    of opAAA_AL_W_AH_W               : set[OpFlagIO]({opfAbove, })
    of opCMP_RegMem_W_Reg_W          : set[OpFlagIO]({})
    of opCMP_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opCMP_Reg_W_RegMem_W          : set[OpFlagIO]({})
    of opCMP_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opCMP_AL_W_Imm_W              : set[OpFlagIO]({})
    of opCMP_EAX_D_Imm_Vs            : set[OpFlagIO]({})
    of opDS_Imm_Vs                   : set[OpFlagIO]({})
    of opAAS_AL_W_AH_W               : set[OpFlagIO]({opfAbove, })
    of opINC_Reg_Vs                  : set[OpFlagIO]({})
    of opDEC_Reg_Vs                  : set[OpFlagIO]({})
    of opPUSH_Reg_Vs                 : set[OpFlagIO]({})
    of opPOP_Reg_Vs                  : set[OpFlagIO]({})
    of opPUSHA_AX_W_Imm_Vs_Imm_Vs_Imm_Vs: set[OpFlagIO]({})
    of opPOPA_Imm_Vs_Imm_Vs_Imm_Vs_Imm_Vs: set[OpFlagIO]({})
    of opBOUND_Reg_Vs_Imm_Vs_Imm_Vs  : set[OpFlagIO]({})
    of opARPL_Imm_W_Reg_W            : set[OpFlagIO]({})
    of opFS_Imm_Vs                   : set[OpFlagIO]({})
    of opGS_Imm_Vs                   : set[OpFlagIO]({})
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opIMUL_Reg_Vs_RegMem_Vs_Imm_Vs: set[OpFlagIO]({})
    of opPUSH_Imm_W                  : set[OpFlagIO]({})
    of opIMUL_Reg_Vs_RegMem_Vs_Imm_W : set[OpFlagIO]({})
    of opINS_Mem_W_Imm_Vs            : set[OpFlagIO]({opfDirection, })
    of opINS_Mem_Vs_Imm_Vs           : set[OpFlagIO]({opfDirection, })
    of opOUTS_Imm_Vs_Mem_W           : set[OpFlagIO]({opfDirection, })
    of opOUTS_Imm_Vs_Mem_Vs          : set[OpFlagIO]({opfDirection, })
    of opJO_Imm_Vs                   : set[OpFlagIO]({opfOverflow, })
    of opJNO_Imm_Vs                  : set[OpFlagIO]({opfOverflow, })
    of opJC_Imm_Vs                   : set[OpFlagIO]({opfCarry, })
    of opJNC_Imm_Vs                  : set[OpFlagIO]({opfCarry, })
    of opJZ_Imm_Vs                   : set[OpFlagIO]({opfZero, })
    of opJNZ_Imm_Vs                  : set[OpFlagIO]({opfZero, })
    of opJBE_Imm_Vs                  : set[OpFlagIO]({opfZero, opfCarry, })
    of opJNBE_Imm_Vs                 : set[OpFlagIO]({opfZero, opfCarry, })
    of opJS_Imm_Vs                   : set[OpFlagIO]({opfSigned, })
    of opJNS_Imm_Vs                  : set[OpFlagIO]({opfSigned, })
    of opJP_Imm_Vs                   : set[OpFlagIO]({opfParity, })
    of opJNP_Imm_Vs                  : set[OpFlagIO]({opfParity, })
    of opJL_Imm_Vs                   : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJNL_Imm_Vs                  : set[OpFlagIO]({opfOverflow, opfSigned, })
    of opJLE_Imm_Vs                  : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opJG_Imm_Vs                   : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, })
    of opADD_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opOR_RegMem_W_Imm_W           : set[OpFlagIO]({})
    of opADC_RegMem_W_Imm_W          : set[OpFlagIO]({opfCarry, })
    of opSBB_RegMem_W_Imm_W          : set[OpFlagIO]({opfCarry, })
    of opAND_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opSUB_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opXOR_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opCMP_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opADD_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opOR_RegMem_Vs_Imm_Vs         : set[OpFlagIO]({})
    of opADC_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfCarry, })
    of opSBB_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfCarry, })
    of opAND_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opSUB_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opXOR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opCMP_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opTEST_RegMem_W_Reg_W         : set[OpFlagIO]({})
    of opTEST_RegMem_Vs_Reg_Vs       : set[OpFlagIO]({})
    of opXCHG_Reg_W_RegMem_W         : set[OpFlagIO]({})
    of opXCHG_Reg_Vs_RegMem_Vs       : set[OpFlagIO]({})
    of opMOV_RegMem_W_Reg_W          : set[OpFlagIO]({})
    of opMOV_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opMOV_Reg_W_RegMem_W          : set[OpFlagIO]({})
    of opMOV_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opMOV_Mem_W_Imm_Vs            : set[OpFlagIO]({})
    of opLEA_Reg_Vs_Imm_Vs           : set[OpFlagIO]({})
    of opMOV_Imm_Vs_Imm_W            : set[OpFlagIO]({})
    of opPOP_RegMem_Vs               : set[OpFlagIO]({})
    of opXCHG_Reg_Vs_EAX_D           : set[OpFlagIO]({})
    of opCWDE_EAX_D_AX_W             : set[OpFlagIO]({})
    of opCDQ_Imm_Vs_EAX_D            : set[OpFlagIO]({})
    of opCALLF_Imm_Vs                : set[OpFlagIO]({})
    of opPUSHFD_Imm_Vs               : set[OpFlagIO]({})
    of opPOPFD_Imm_Vs                : set[OpFlagIO]({})
    of opSAHF_AH_W                   : set[OpFlagIO]({})
    of opLAHF_AH_W                   : set[OpFlagIO]({opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_AL_W_Imm_Vs             : set[OpFlagIO]({})
    of opMOV_EAX_D_Imm_Vs            : set[OpFlagIO]({})
    of opMOV_Imm_Vs_AL_W             : set[OpFlagIO]({})
    of opMOV_Imm_Vs_EAX_D            : set[OpFlagIO]({})
    of opMOVS_Mem_W_Mem_W            : set[OpFlagIO]({opfDirection, })
    of opMOVS_Mem_Vs_Mem_Vs          : set[OpFlagIO]({opfDirection, })
    of opCMPS_Mem_W_Mem_W            : set[OpFlagIO]({opfDirection, })
    of opCMPS_Mem_Vs_Mem_Vs          : set[OpFlagIO]({opfDirection, })
    of opTEST_AL_W_Imm_W             : set[OpFlagIO]({})
    of opTEST_EAX_D_Imm_Vs           : set[OpFlagIO]({})
    of opSTOS_Mem_W_AL_W             : set[OpFlagIO]({opfDirection, })
    of opSTOS_Mem_Vs_EAX_D           : set[OpFlagIO]({opfDirection, })
    of opLODS_AL_W_Mem_W             : set[OpFlagIO]({opfDirection, })
    of opLODS_EAX_D_Mem_Vs           : set[OpFlagIO]({opfDirection, })
    of opSCAS_Mem_W_AL_W             : set[OpFlagIO]({opfDirection, })
    of opSCAS_Mem_Vs_EAX_D           : set[OpFlagIO]({opfDirection, })
    of opMOV_Reg_W_Imm_W             : set[OpFlagIO]({})
    of opMOV_Reg_Vs_Imm_Vs           : set[OpFlagIO]({})
    of opROL_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opROR_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opRCL_RegMem_W_Imm_W          : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_W_Imm_W          : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opSHR_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opSAL_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opSAR_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opROL_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opROR_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opRCL_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opSHR_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opSAL_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opSAR_RegMem_Vs_Imm_W         : set[OpFlagIO]({})
    of opRETN_Imm_W                  : set[OpFlagIO]({})
    of opRETN                        : set[OpFlagIO]({})
    of opLES_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opLDS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opMOV_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opMOV_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opENTER_Imm_Vs_Imm_W_Imm_W    : set[OpFlagIO]({})
    of opLEAVE_Imm_Vs                : set[OpFlagIO]({})
    of opRETF_Imm_W                  : set[OpFlagIO]({})
    of opRETF                        : set[OpFlagIO]({})
    of opINT_Imm_Vs_Imm_Vs           : set[OpFlagIO]({})
    of opINT_Imm_W_Imm_Vs            : set[OpFlagIO]({})
    of opINTO_Imm_Vs                 : set[OpFlagIO]({opfOverflow, })
    of opIRET_Imm_Vs                 : set[OpFlagIO]({})
    of opROL_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opROR_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opRCL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opSHR_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opSAL_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opSAR_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opROL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opROR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opRCL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opSHR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opSAL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opSAR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opROL_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opROR_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opRCL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opSHR_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opSAL_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opSAR_RegMem_W_Imm_Vs         : set[OpFlagIO]({})
    of opROL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opROR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opRCL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfCarry, })
    of opRCR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfCarry, })
    of opSHL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opSHR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opSAL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opSAR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opAMX_AL_W_AH_W_Imm_W         : set[OpFlagIO]({})
    of opAAM_AL_W_AH_W               : set[OpFlagIO]({})
    of opADX_AL_W_AH_W_Imm_W         : set[OpFlagIO]({})
    of opAAD_AL_W_AH_W               : set[OpFlagIO]({})
    of opSALC_AL_W                   : set[OpFlagIO]({opfCarry, })
    of opXLAT_AL_W_Mem_W             : set[OpFlagIO]({})
    of opLOOPNZ_Imm_Vs_Imm_Vs        : set[OpFlagIO]({opfZero, })
    of opLOOPZ_Imm_Vs_Imm_Vs         : set[OpFlagIO]({opfZero, })
    of opLOOP_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opJCXZ_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opIN_AL_W_Imm_W               : set[OpFlagIO]({})
    of opIN_EAX_D_Imm_W              : set[OpFlagIO]({})
    of opOUT_Imm_W_AL_W              : set[OpFlagIO]({})
    of opOUT_Imm_W_EAX_D             : set[OpFlagIO]({})
    of opCALL_Imm_Vs                 : set[OpFlagIO]({})
    of opJMP_Imm_Vs                  : set[OpFlagIO]({})
    of opJMPF_Imm_Vs                 : set[OpFlagIO]({})
    of opJMP_Imm_Vs                  : set[OpFlagIO]({})
    of opIN_AL_W_Imm_Vs              : set[OpFlagIO]({})
    of opIN_EAX_D_Imm_Vs             : set[OpFlagIO]({})
    of opOUT_Imm_Vs_AL_W             : set[OpFlagIO]({})
    of opOUT_Imm_Vs_EAX_D            : set[OpFlagIO]({})
    of opLOCK                        : set[OpFlagIO]({})
    of opINT1_Imm_Vs                 : set[OpFlagIO]({})
    of opREPNZ_Imm_Vs                : set[OpFlagIO]({opfZero, })
    of opREPZ_Imm_Vs                 : set[OpFlagIO]({opfZero, })
    of opHLT                         : set[OpFlagIO]({})
    of opCMC                         : set[OpFlagIO]({opfCarry, })
    of opTEST_RegMem_W_Imm_W         : set[OpFlagIO]({})
    of opNOT_RegMem_W                : set[OpFlagIO]({})
    of opNEG_RegMem_W                : set[OpFlagIO]({})
    of opMUL_AX_W_AL_W_RegMem_W      : set[OpFlagIO]({})
    of opIMUL_AX_W_AL_W_RegMem_W     : set[OpFlagIO]({})
    of opDIV_AL_W_AH_W_AX_W_RegMem_W : set[OpFlagIO]({})
    of opIDIV_AL_W_AH_W_AX_W_RegMem_W: set[OpFlagIO]({})
    of opTEST_RegMem_Vs_Imm_Vs       : set[OpFlagIO]({})
    of opNOT_RegMem_Vs               : set[OpFlagIO]({})
    of opNEG_RegMem_Vs               : set[OpFlagIO]({})
    of opMUL_Imm_Vs_EAX_D_RegMem_Vs  : set[OpFlagIO]({})
    of opIMUL_Imm_Vs_EAX_D_RegMem_Vs : set[OpFlagIO]({})
    of opDIV_Imm_Vs_EAX_D_RegMem_Vs  : set[OpFlagIO]({})
    of opIDIV_Imm_Vs_EAX_D_RegMem_Vs : set[OpFlagIO]({})
    of opCLC                         : set[OpFlagIO]({})
    of opSTC                         : set[OpFlagIO]({})
    of opCLI                         : set[OpFlagIO]({})
    of opSTI                         : set[OpFlagIO]({})
    of opCLD                         : set[OpFlagIO]({})
    of opSTD                         : set[OpFlagIO]({})
    of opINC_RegMem_W                : set[OpFlagIO]({})
    of opDEC_RegMem_W                : set[OpFlagIO]({})
    of opINC_RegMem_Vs               : set[OpFlagIO]({})
    of opDEC_RegMem_Vs               : set[OpFlagIO]({})
    of opCALL_RegMem_Vs              : set[OpFlagIO]({})
    of opCALLF_Imm_Vs                : set[OpFlagIO]({})
    of opJMP_RegMem_Vs               : set[OpFlagIO]({})
    of opJMPF_Imm_Vs                 : set[OpFlagIO]({})
    of opPUSH_RegMem_Vs              : set[OpFlagIO]({})

func getModifiedFlags*(code: ICode): set[OpFlagIO] =
  case code:
    of opADD_RegMem_W_Reg_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_Reg_W_RegMem_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_AL_W_Imm_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_EAX_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opOR_RegMem_W_Reg_W           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_RegMem_Vs_Reg_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_Reg_W_RegMem_W           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_Reg_Vs_RegMem_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_AL_W_Imm_W               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_EAX_D_Imm_Vs             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opSLDT_Mem_W_Imm_Vs           : set[OpFlagIO]({})
    of opSTR_Mem_W_Imm_Vs            : set[OpFlagIO]({})
    of opLLDT_Imm_Vs_Imm_W           : set[OpFlagIO]({})
    of opLTR_Imm_Vs_Imm_W            : set[OpFlagIO]({})
    of opVERR_Imm_W                  : set[OpFlagIO]({opfZero, })
    of opVERW_Imm_W                  : set[OpFlagIO]({opfZero, })
    of opSGDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opSIDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opLGDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opLIDT_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opSMSW_Mem_W_Imm_Vs           : set[OpFlagIO]({})
    of opLMSW_Imm_Vs_Imm_W           : set[OpFlagIO]({})
    of opINVLPG_Imm_Vs               : set[OpFlagIO]({})
    of opLAR_Reg_Vs_Mem_W            : set[OpFlagIO]({opfZero, })
    of opLSL_Reg_Vs_Mem_W            : set[OpFlagIO]({opfZero, })
    of opCLTS_Imm_Vs                 : set[OpFlagIO]({})
    of opUD2                         : set[OpFlagIO]({})
    of opMOV_Reg_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_Reg_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_Imm_Vs_Reg_D            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_Imm_Vs_Reg_D            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opJO_Imm_Vs                   : set[OpFlagIO]({})
    of opJNO_Imm_Vs                  : set[OpFlagIO]({})
    of opJB_Imm_Vs                   : set[OpFlagIO]({})
    of opJNB_Imm_Vs                  : set[OpFlagIO]({})
    of opJZ_Imm_Vs                   : set[OpFlagIO]({})
    of opJNZ_Imm_Vs                  : set[OpFlagIO]({})
    of opJBE_Imm_Vs                  : set[OpFlagIO]({})
    of opJNBE_Imm_Vs                 : set[OpFlagIO]({})
    of opJS_Imm_Vs                   : set[OpFlagIO]({})
    of opJNS_Imm_Vs                  : set[OpFlagIO]({})
    of opJP_Imm_Vs                   : set[OpFlagIO]({})
    of opJNP_Imm_Vs                  : set[OpFlagIO]({})
    of opJL_Imm_Vs                   : set[OpFlagIO]({})
    of opJNL_Imm_Vs                  : set[OpFlagIO]({})
    of opJLE_Imm_Vs                  : set[OpFlagIO]({})
    of opJNLE_Imm_Vs                 : set[OpFlagIO]({})
    of opSETO_RegMem_W               : set[OpFlagIO]({})
    of opSETNO_RegMem_W              : set[OpFlagIO]({})
    of opSETB_RegMem_W               : set[OpFlagIO]({})
    of opSETNB_RegMem_W              : set[OpFlagIO]({})
    of opSETZ_RegMem_W               : set[OpFlagIO]({})
    of opSETNZ_RegMem_W              : set[OpFlagIO]({})
    of opSETBE_RegMem_W              : set[OpFlagIO]({})
    of opSETNBE_RegMem_W             : set[OpFlagIO]({})
    of opSETS_RegMem_W               : set[OpFlagIO]({})
    of opSETNS_RegMem_W              : set[OpFlagIO]({})
    of opSETP_RegMem_W               : set[OpFlagIO]({})
    of opSETNP_RegMem_W              : set[OpFlagIO]({})
    of opSETL_RegMem_W               : set[OpFlagIO]({})
    of opSETNL_RegMem_W              : set[OpFlagIO]({})
    of opSETLE_RegMem_W              : set[OpFlagIO]({})
    of opSETNLE_RegMem_W             : set[OpFlagIO]({})
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opBT_RegMem_Vs_Reg_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHLD_RegMem_Vs_Reg_Vs_Imm_W : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHLD_RegMem_Vs_Reg_Vs_Imm_Vs: set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opBTS_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHRD_RegMem_Vs_Reg_Vs_Imm_W : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHRD_RegMem_Vs_Reg_Vs_Imm_Vs: set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIMUL_Reg_Vs_RegMem_Vs       : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opLSS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opBTR_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opLFS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opLGS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opMOVZX_Reg_Vs_RegMem_W       : set[OpFlagIO]({})
    of opMOVZX_Reg_Vs_Imm_W          : set[OpFlagIO]({})
    of opBT_RegMem_Vs_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTS_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTR_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTC_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBTC_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBSF_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opBSR_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOVSX_Reg_Vs_RegMem_W       : set[OpFlagIO]({})
    of opMOVSX_Reg_Vs_Imm_W          : set[OpFlagIO]({})
    of opADC_RegMem_W_Reg_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_Reg_W_RegMem_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_AL_W_Imm_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_EAX_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opSBB_RegMem_W_Reg_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_Reg_W_RegMem_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_AL_W_Imm_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_EAX_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opPOP_Imm_Vs                  : set[OpFlagIO]({})
    of opAND_RegMem_W_Reg_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_Reg_W_RegMem_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_AL_W_Imm_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_EAX_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opES_Imm_Vs                   : set[OpFlagIO]({})
    of opDAA_AL_W                    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_W_Reg_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_Reg_W_RegMem_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_AL_W_Imm_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_EAX_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCS_Imm_Vs                   : set[OpFlagIO]({})
    of opDAS_AL_W                    : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_W_Reg_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_Reg_W_RegMem_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_AL_W_Imm_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_EAX_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSS_Imm_Vs                   : set[OpFlagIO]({})
    of opAAA_AL_W_AH_W               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_W_Reg_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_Reg_W_RegMem_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_AL_W_Imm_W              : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_EAX_D_Imm_Vs            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opDS_Imm_Vs                   : set[OpFlagIO]({})
    of opAAS_AL_W_AH_W               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opINC_Reg_Vs                  : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opDEC_Reg_Vs                  : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opPUSH_Reg_Vs                 : set[OpFlagIO]({})
    of opPOP_Reg_Vs                  : set[OpFlagIO]({})
    of opPUSHA_AX_W_Imm_Vs_Imm_Vs_Imm_Vs: set[OpFlagIO]({})
    of opPOPA_Imm_Vs_Imm_Vs_Imm_Vs_Imm_Vs: set[OpFlagIO]({})
    of opBOUND_Reg_Vs_Imm_Vs_Imm_Vs  : set[OpFlagIO]({opfInterrupt, })
    of opARPL_Imm_W_Reg_W            : set[OpFlagIO]({opfZero, })
    of opFS_Imm_Vs                   : set[OpFlagIO]({})
    of opGS_Imm_Vs                   : set[OpFlagIO]({})
    of opPUSH_Imm_Vs                 : set[OpFlagIO]({})
    of opIMUL_Reg_Vs_RegMem_Vs_Imm_Vs: set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opPUSH_Imm_W                  : set[OpFlagIO]({})
    of opIMUL_Reg_Vs_RegMem_Vs_Imm_W : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opINS_Mem_W_Imm_Vs            : set[OpFlagIO]({})
    of opINS_Mem_Vs_Imm_Vs           : set[OpFlagIO]({})
    of opOUTS_Imm_Vs_Mem_W           : set[OpFlagIO]({})
    of opOUTS_Imm_Vs_Mem_Vs          : set[OpFlagIO]({})
    of opJO_Imm_Vs                   : set[OpFlagIO]({})
    of opJNO_Imm_Vs                  : set[OpFlagIO]({})
    of opJC_Imm_Vs                   : set[OpFlagIO]({})
    of opJNC_Imm_Vs                  : set[OpFlagIO]({})
    of opJZ_Imm_Vs                   : set[OpFlagIO]({})
    of opJNZ_Imm_Vs                  : set[OpFlagIO]({})
    of opJBE_Imm_Vs                  : set[OpFlagIO]({})
    of opJNBE_Imm_Vs                 : set[OpFlagIO]({})
    of opJS_Imm_Vs                   : set[OpFlagIO]({})
    of opJNS_Imm_Vs                  : set[OpFlagIO]({})
    of opJP_Imm_Vs                   : set[OpFlagIO]({})
    of opJNP_Imm_Vs                  : set[OpFlagIO]({})
    of opJL_Imm_Vs                   : set[OpFlagIO]({})
    of opJNL_Imm_Vs                  : set[OpFlagIO]({})
    of opJLE_Imm_Vs                  : set[OpFlagIO]({})
    of opJG_Imm_Vs                   : set[OpFlagIO]({})
    of opADD_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_RegMem_W_Imm_W           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADD_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opOR_RegMem_Vs_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADC_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSBB_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAND_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSUB_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXOR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMP_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_RegMem_W_Reg_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_RegMem_Vs_Reg_Vs       : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opXCHG_Reg_W_RegMem_W         : set[OpFlagIO]({})
    of opXCHG_Reg_Vs_RegMem_Vs       : set[OpFlagIO]({})
    of opMOV_RegMem_W_Reg_W          : set[OpFlagIO]({})
    of opMOV_RegMem_Vs_Reg_Vs        : set[OpFlagIO]({})
    of opMOV_Reg_W_RegMem_W          : set[OpFlagIO]({})
    of opMOV_Reg_Vs_RegMem_Vs        : set[OpFlagIO]({})
    of opMOV_Mem_W_Imm_Vs            : set[OpFlagIO]({})
    of opLEA_Reg_Vs_Imm_Vs           : set[OpFlagIO]({})
    of opMOV_Imm_Vs_Imm_W            : set[OpFlagIO]({})
    of opPOP_RegMem_Vs               : set[OpFlagIO]({})
    of opXCHG_Reg_Vs_EAX_D           : set[OpFlagIO]({})
    of opCWDE_EAX_D_AX_W             : set[OpFlagIO]({})
    of opCDQ_Imm_Vs_EAX_D            : set[OpFlagIO]({})
    of opCALLF_Imm_Vs                : set[OpFlagIO]({})
    of opPUSHFD_Imm_Vs               : set[OpFlagIO]({})
    of opPOPFD_Imm_Vs                : set[OpFlagIO]({})
    of opSAHF_AH_W                   : set[OpFlagIO]({opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opLAHF_AH_W                   : set[OpFlagIO]({})
    of opMOV_AL_W_Imm_Vs             : set[OpFlagIO]({})
    of opMOV_EAX_D_Imm_Vs            : set[OpFlagIO]({})
    of opMOV_Imm_Vs_AL_W             : set[OpFlagIO]({})
    of opMOV_Imm_Vs_EAX_D            : set[OpFlagIO]({})
    of opMOVS_Mem_W_Mem_W            : set[OpFlagIO]({})
    of opMOVS_Mem_Vs_Mem_Vs          : set[OpFlagIO]({})
    of opCMPS_Mem_W_Mem_W            : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCMPS_Mem_Vs_Mem_Vs          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_AL_W_Imm_W             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_EAX_D_Imm_Vs           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSTOS_Mem_W_AL_W             : set[OpFlagIO]({})
    of opSTOS_Mem_Vs_EAX_D           : set[OpFlagIO]({})
    of opLODS_AL_W_Mem_W             : set[OpFlagIO]({})
    of opLODS_EAX_D_Mem_Vs           : set[OpFlagIO]({})
    of opSCAS_Mem_W_AL_W             : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSCAS_Mem_Vs_EAX_D           : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMOV_Reg_W_Imm_W             : set[OpFlagIO]({})
    of opMOV_Reg_Vs_Imm_Vs           : set[OpFlagIO]({})
    of opROL_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_W_Imm_W          : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_Vs_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRETN_Imm_W                  : set[OpFlagIO]({})
    of opRETN                        : set[OpFlagIO]({})
    of opLES_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opLDS_Imm_Vs_Reg_Vs_Imm_Vs    : set[OpFlagIO]({})
    of opMOV_RegMem_W_Imm_W          : set[OpFlagIO]({})
    of opMOV_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opENTER_Imm_Vs_Imm_W_Imm_W    : set[OpFlagIO]({})
    of opLEAVE_Imm_Vs                : set[OpFlagIO]({})
    of opRETF_Imm_W                  : set[OpFlagIO]({})
    of opRETF                        : set[OpFlagIO]({})
    of opINT_Imm_Vs_Imm_Vs           : set[OpFlagIO]({opfInterrupt, })
    of opINT_Imm_W_Imm_Vs            : set[OpFlagIO]({opfInterrupt, })
    of opINTO_Imm_Vs                 : set[OpFlagIO]({opfInterrupt, })
    of opIRET_Imm_Vs                 : set[OpFlagIO]({})
    of opROL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_W_Imm_Vs         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opROR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opRCR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSHR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAL_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSAR_RegMem_Vs_Imm_Vs        : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAMX_AL_W_AH_W_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAAM_AL_W_AH_W               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opADX_AL_W_AH_W_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opAAD_AL_W_AH_W               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opSALC_AL_W                   : set[OpFlagIO]({})
    of opXLAT_AL_W_Mem_W             : set[OpFlagIO]({})
    of opLOOPNZ_Imm_Vs_Imm_Vs        : set[OpFlagIO]({})
    of opLOOPZ_Imm_Vs_Imm_Vs         : set[OpFlagIO]({})
    of opLOOP_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opJCXZ_Imm_Vs_Imm_Vs          : set[OpFlagIO]({})
    of opIN_AL_W_Imm_W               : set[OpFlagIO]({})
    of opIN_EAX_D_Imm_W              : set[OpFlagIO]({})
    of opOUT_Imm_W_AL_W              : set[OpFlagIO]({})
    of opOUT_Imm_W_EAX_D             : set[OpFlagIO]({})
    of opCALL_Imm_Vs                 : set[OpFlagIO]({})
    of opJMP_Imm_Vs                  : set[OpFlagIO]({})
    of opJMPF_Imm_Vs                 : set[OpFlagIO]({})
    of opJMP_Imm_Vs                  : set[OpFlagIO]({})
    of opIN_AL_W_Imm_Vs              : set[OpFlagIO]({})
    of opIN_EAX_D_Imm_Vs             : set[OpFlagIO]({})
    of opOUT_Imm_Vs_AL_W             : set[OpFlagIO]({})
    of opOUT_Imm_Vs_EAX_D            : set[OpFlagIO]({})
    of opLOCK                        : set[OpFlagIO]({})
    of opINT1_Imm_Vs                 : set[OpFlagIO]({opfInterrupt, })
    of opREPNZ_Imm_Vs                : set[OpFlagIO]({})
    of opREPZ_Imm_Vs                 : set[OpFlagIO]({})
    of opHLT                         : set[OpFlagIO]({})
    of opCMC                         : set[OpFlagIO]({opfCarry, })
    of opTEST_RegMem_W_Imm_W         : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opNOT_RegMem_W                : set[OpFlagIO]({})
    of opNEG_RegMem_W                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMUL_AX_W_AL_W_RegMem_W      : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIMUL_AX_W_AL_W_RegMem_W     : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opDIV_AL_W_AH_W_AX_W_RegMem_W : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIDIV_AL_W_AH_W_AX_W_RegMem_W: set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opTEST_RegMem_Vs_Imm_Vs       : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opNOT_RegMem_Vs               : set[OpFlagIO]({})
    of opNEG_RegMem_Vs               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opMUL_Imm_Vs_EAX_D_RegMem_Vs  : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIMUL_Imm_Vs_EAX_D_RegMem_Vs : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opDIV_Imm_Vs_EAX_D_RegMem_Vs  : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opIDIV_Imm_Vs_EAX_D_RegMem_Vs : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, opfCarry, })
    of opCLC                         : set[OpFlagIO]({opfCarry, })
    of opSTC                         : set[OpFlagIO]({opfCarry, })
    of opCLI                         : set[OpFlagIO]({opfInterrupt, })
    of opSTI                         : set[OpFlagIO]({opfInterrupt, })
    of opCLD                         : set[OpFlagIO]({opfDirection, })
    of opSTD                         : set[OpFlagIO]({opfDirection, })
    of opINC_RegMem_W                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opDEC_RegMem_W                : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opINC_RegMem_Vs               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opDEC_RegMem_Vs               : set[OpFlagIO]({opfOverflow, opfSigned, opfZero, opfAbove, opfParity, })
    of opCALL_RegMem_Vs              : set[OpFlagIO]({})
    of opCALLF_Imm_Vs                : set[OpFlagIO]({})
    of opJMP_RegMem_Vs               : set[OpFlagIO]({})
    of opJMPF_Imm_Vs                 : set[OpFlagIO]({})
    of opPUSH_RegMem_Vs              : set[OpFlagIO]({})

func getUsedOperands*(code: ICode): array[4, Option[(OpAddrKind, OpDataKind)]] =
  const nop = none((OpAddrKind, OpDataKind))
  const W = opData8
  const D = opData32
  const W = opData16
  const Vs = opData16_32
  const Imm = opAddrImm
  const Reg = opAddrReg
  const Mem = opAddrMem
  const RegMem = opAddrRegMem
  const AL = opAddrGRegAL
  const AH = opAddrGRegAH
  const AX = opAddrGRegAX
  const EAX = opADdrGRegEAX
  case code:
    of opADD_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opADD_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opADD_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opADD_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opADD_AL_W_Imm_W              : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opADD_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opPUSH_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPOP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opOR_RegMem_W_Reg_W           : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opOR_RegMem_Vs_Reg_Vs         : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opOR_Reg_W_RegMem_W           : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opOR_Reg_Vs_RegMem_Vs         : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opOR_AL_W_Imm_W               : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opOR_EAX_D_Imm_Vs             : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opPUSH_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opSLDT_Mem_W_Imm_Vs           : [some((Mem, W))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSTR_Mem_W_Imm_Vs            : [some((Mem, W))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opLLDT_Imm_Vs_Imm_W           : [some((Imm, Vs))     , some((Imm, W))      , nop                 , nop                 , ]
    of opLTR_Imm_Vs_Imm_W            : [some((Imm, Vs))     , some((Imm, W))      , nop                 , nop                 , ]
    of opVERR_Imm_W                  : [some((Imm, W))      , nop                 , nop                 , nop                 , ]
    of opVERW_Imm_W                  : [some((Imm, W))      , nop                 , nop                 , nop                 , ]
    of opSGDT_Imm_Vs_Imm_Vs          : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSIDT_Imm_Vs_Imm_Vs          : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opLGDT_Imm_Vs_Imm_Vs          : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opLIDT_Imm_Vs_Imm_Vs          : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSMSW_Mem_W_Imm_Vs           : [some((Mem, W))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opLMSW_Imm_Vs_Imm_W           : [some((Imm, Vs))     , some((Imm, W))      , nop                 , nop                 , ]
    of opINVLPG_Imm_Vs               : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opLAR_Reg_Vs_Mem_W            : [some((Reg, Vs))     , some((Mem, W))      , nop                 , nop                 , ]
    of opLSL_Reg_Vs_Mem_W            : [some((Reg, Vs))     , some((Mem, W))      , nop                 , nop                 , ]
    of opCLTS_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opUD2                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opMOV_Reg_D_Imm_Vs            : [some((Reg, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opMOV_Reg_D_Imm_Vs            : [some((Reg, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opMOV_Imm_Vs_Reg_D            : [some((Imm, Vs))     , some((Reg, D))      , nop                 , nop                 , ]
    of opMOV_Imm_Vs_Reg_D            : [some((Imm, Vs))     , some((Reg, D))      , nop                 , nop                 , ]
    of opJO_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNO_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJB_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNB_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJZ_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNZ_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJBE_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNBE_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJS_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNS_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJP_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJL_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNL_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJLE_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNLE_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opSETO_RegMem_W               : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNO_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETB_RegMem_W               : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNB_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETZ_RegMem_W               : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNZ_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETBE_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNBE_RegMem_W             : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETS_RegMem_W               : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNS_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETP_RegMem_W               : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNP_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETL_RegMem_W               : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNL_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETLE_RegMem_W              : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opSETNLE_RegMem_W             : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opPUSH_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPOP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opBT_RegMem_Vs_Reg_Vs         : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opSHLD_RegMem_Vs_Reg_Vs_Imm_W : [some((RegMem, Vs))  , some((Reg, Vs))     , some((Imm, W))      , nop                 , ]
    of opSHLD_RegMem_Vs_Reg_Vs_Imm_Vs: [some((RegMem, Vs))  , some((Reg, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opPUSH_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPOP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opBTS_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opSHRD_RegMem_Vs_Reg_Vs_Imm_W : [some((RegMem, Vs))  , some((Reg, Vs))     , some((Imm, W))      , nop                 , ]
    of opSHRD_RegMem_Vs_Reg_Vs_Imm_Vs: [some((RegMem, Vs))  , some((Reg, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opIMUL_Reg_Vs_RegMem_Vs       : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opLSS_Imm_Vs_Reg_Vs_Imm_Vs    : [some((Imm, Vs))     , some((Reg, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opBTR_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opLFS_Imm_Vs_Reg_Vs_Imm_Vs    : [some((Imm, Vs))     , some((Reg, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opLGS_Imm_Vs_Reg_Vs_Imm_Vs    : [some((Imm, Vs))     , some((Reg, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opMOVZX_Reg_Vs_RegMem_W       : [some((Reg, Vs))     , some((RegMem, W))   , nop                 , nop                 , ]
    of opMOVZX_Reg_Vs_Imm_W          : [some((Reg, Vs))     , some((Imm, W))      , nop                 , nop                 , ]
    of opBT_RegMem_Vs_Imm_W          : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opBTS_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opBTR_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opBTC_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opBTC_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opBSF_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opBSR_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opMOVSX_Reg_Vs_RegMem_W       : [some((Reg, Vs))     , some((RegMem, W))   , nop                 , nop                 , ]
    of opMOVSX_Reg_Vs_Imm_W          : [some((Reg, Vs))     , some((Imm, W))      , nop                 , nop                 , ]
    of opADC_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opADC_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opADC_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opADC_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opADC_AL_W_Imm_W              : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opADC_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opPUSH_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPOP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opSBB_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opSBB_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opSBB_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opSBB_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opSBB_AL_W_Imm_W              : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opSBB_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opPUSH_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPOP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opAND_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opAND_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opAND_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opAND_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opAND_AL_W_Imm_W              : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opAND_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opES_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opDAA_AL_W                    : [some((AL, W))       , nop                 , nop                 , nop                 , ]
    of opSUB_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opSUB_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opSUB_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opSUB_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opSUB_AL_W_Imm_W              : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opSUB_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opCS_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opDAS_AL_W                    : [some((AL, W))       , nop                 , nop                 , nop                 , ]
    of opXOR_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opXOR_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opXOR_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opXOR_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opXOR_AL_W_Imm_W              : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opXOR_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSS_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opAAA_AL_W_AH_W               : [some((AL, W))       , some((AH, W))       , nop                 , nop                 , ]
    of opCMP_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opCMP_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opCMP_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opCMP_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opCMP_AL_W_Imm_W              : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opCMP_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opDS_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opAAS_AL_W_AH_W               : [some((AL, W))       , some((AH, W))       , nop                 , nop                 , ]
    of opINC_Reg_Vs                  : [some((Reg, Vs))     , nop                 , nop                 , nop                 , ]
    of opDEC_Reg_Vs                  : [some((Reg, Vs))     , nop                 , nop                 , nop                 , ]
    of opPUSH_Reg_Vs                 : [some((Reg, Vs))     , nop                 , nop                 , nop                 , ]
    of opPOP_Reg_Vs                  : [some((Reg, Vs))     , nop                 , nop                 , nop                 , ]
    of opPUSHA_AX_W_Imm_Vs_Imm_Vs_Imm_Vs: [some((AX, W))       , some((Imm, Vs))     , some((Imm, Vs))     , some((Imm, Vs))     , ]
    of opPOPA_Imm_Vs_Imm_Vs_Imm_Vs_Imm_Vs: [some((Imm, Vs))     , some((Imm, Vs))     , some((Imm, Vs))     , some((Imm, Vs))     , ]
    of opBOUND_Reg_Vs_Imm_Vs_Imm_Vs  : [some((Reg, Vs))     , some((Imm, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opARPL_Imm_W_Reg_W            : [some((Imm, W))      , some((Reg, W))      , nop                 , nop                 , ]
    of opFS_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opGS_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPUSH_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opIMUL_Reg_Vs_RegMem_Vs_Imm_Vs: [some((Reg, Vs))     , some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , ]
    of opPUSH_Imm_W                  : [some((Imm, W))      , nop                 , nop                 , nop                 , ]
    of opIMUL_Reg_Vs_RegMem_Vs_Imm_W : [some((Reg, Vs))     , some((RegMem, Vs))  , some((Imm, W))      , nop                 , ]
    of opINS_Mem_W_Imm_Vs            : [some((Mem, W))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opINS_Mem_Vs_Imm_Vs           : [some((Mem, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opOUTS_Imm_Vs_Mem_W           : [some((Imm, Vs))     , some((Mem, W))      , nop                 , nop                 , ]
    of opOUTS_Imm_Vs_Mem_Vs          : [some((Imm, Vs))     , some((Mem, Vs))     , nop                 , nop                 , ]
    of opJO_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNO_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJC_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNC_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJZ_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNZ_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJBE_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNBE_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJS_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNS_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJP_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJL_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJNL_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJLE_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJG_Imm_Vs                   : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opADD_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opOR_RegMem_W_Imm_W           : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opADC_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opSBB_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opAND_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opSUB_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opXOR_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opCMP_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opADD_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opOR_RegMem_Vs_Imm_Vs         : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opADC_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSBB_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opAND_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSUB_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opXOR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opCMP_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opTEST_RegMem_W_Reg_W         : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opTEST_RegMem_Vs_Reg_Vs       : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opXCHG_Reg_W_RegMem_W         : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opXCHG_Reg_Vs_RegMem_Vs       : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opMOV_RegMem_W_Reg_W          : [some((RegMem, W))   , some((Reg, W))      , nop                 , nop                 , ]
    of opMOV_RegMem_Vs_Reg_Vs        : [some((RegMem, Vs))  , some((Reg, Vs))     , nop                 , nop                 , ]
    of opMOV_Reg_W_RegMem_W          : [some((Reg, W))      , some((RegMem, W))   , nop                 , nop                 , ]
    of opMOV_Reg_Vs_RegMem_Vs        : [some((Reg, Vs))     , some((RegMem, Vs))  , nop                 , nop                 , ]
    of opMOV_Mem_W_Imm_Vs            : [some((Mem, W))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opLEA_Reg_Vs_Imm_Vs           : [some((Reg, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opMOV_Imm_Vs_Imm_W            : [some((Imm, Vs))     , some((Imm, W))      , nop                 , nop                 , ]
    of opPOP_RegMem_Vs               : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
    of opXCHG_Reg_Vs_EAX_D           : [some((Reg, Vs))     , some((EAX, D))      , nop                 , nop                 , ]
    of opCWDE_EAX_D_AX_W             : [some((EAX, D))      , some((AX, W))       , nop                 , nop                 , ]
    of opCDQ_Imm_Vs_EAX_D            : [some((Imm, Vs))     , some((EAX, D))      , nop                 , nop                 , ]
    of opCALLF_Imm_Vs                : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPUSHFD_Imm_Vs               : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPOPFD_Imm_Vs                : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opSAHF_AH_W                   : [some((AH, W))       , nop                 , nop                 , nop                 , ]
    of opLAHF_AH_W                   : [some((AH, W))       , nop                 , nop                 , nop                 , ]
    of opMOV_AL_W_Imm_Vs             : [some((AL, W))       , some((Imm, Vs))     , nop                 , nop                 , ]
    of opMOV_EAX_D_Imm_Vs            : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opMOV_Imm_Vs_AL_W             : [some((Imm, Vs))     , some((AL, W))       , nop                 , nop                 , ]
    of opMOV_Imm_Vs_EAX_D            : [some((Imm, Vs))     , some((EAX, D))      , nop                 , nop                 , ]
    of opMOVS_Mem_W_Mem_W            : [some((Mem, W))      , some((Mem, W))      , nop                 , nop                 , ]
    of opMOVS_Mem_Vs_Mem_Vs          : [some((Mem, Vs))     , some((Mem, Vs))     , nop                 , nop                 , ]
    of opCMPS_Mem_W_Mem_W            : [some((Mem, W))      , some((Mem, W))      , nop                 , nop                 , ]
    of opCMPS_Mem_Vs_Mem_Vs          : [some((Mem, Vs))     , some((Mem, Vs))     , nop                 , nop                 , ]
    of opTEST_AL_W_Imm_W             : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opTEST_EAX_D_Imm_Vs           : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSTOS_Mem_W_AL_W             : [some((Mem, W))      , some((AL, W))       , nop                 , nop                 , ]
    of opSTOS_Mem_Vs_EAX_D           : [some((Mem, Vs))     , some((EAX, D))      , nop                 , nop                 , ]
    of opLODS_AL_W_Mem_W             : [some((AL, W))       , some((Mem, W))      , nop                 , nop                 , ]
    of opLODS_EAX_D_Mem_Vs           : [some((EAX, D))      , some((Mem, Vs))     , nop                 , nop                 , ]
    of opSCAS_Mem_W_AL_W             : [some((Mem, W))      , some((AL, W))       , nop                 , nop                 , ]
    of opSCAS_Mem_Vs_EAX_D           : [some((Mem, Vs))     , some((EAX, D))      , nop                 , nop                 , ]
    of opMOV_Reg_W_Imm_W             : [some((Reg, W))      , some((Imm, W))      , nop                 , nop                 , ]
    of opMOV_Reg_Vs_Imm_Vs           : [some((Reg, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROL_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opROR_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opRCL_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opRCR_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opSHL_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opSHR_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opSAL_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opSAR_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opROL_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opROR_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opRCL_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opRCR_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opSHL_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opSHR_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opSAL_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opSAR_RegMem_Vs_Imm_W         : [some((RegMem, Vs))  , some((Imm, W))      , nop                 , nop                 , ]
    of opRETN_Imm_W                  : [some((Imm, W))      , nop                 , nop                 , nop                 , ]
    of opRETN                        : [nop                 , nop                 , nop                 , nop                 , ]
    of opLES_Imm_Vs_Reg_Vs_Imm_Vs    : [some((Imm, Vs))     , some((Reg, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opLDS_Imm_Vs_Reg_Vs_Imm_Vs    : [some((Imm, Vs))     , some((Reg, Vs))     , some((Imm, Vs))     , nop                 , ]
    of opMOV_RegMem_W_Imm_W          : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opMOV_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opENTER_Imm_Vs_Imm_W_Imm_W    : [some((Imm, Vs))     , some((Imm, W))      , some((Imm, W))      , nop                 , ]
    of opLEAVE_Imm_Vs                : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opRETF_Imm_W                  : [some((Imm, W))      , nop                 , nop                 , nop                 , ]
    of opRETF                        : [nop                 , nop                 , nop                 , nop                 , ]
    of opINT_Imm_Vs_Imm_Vs           : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opINT_Imm_W_Imm_Vs            : [some((Imm, W))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opINTO_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opIRET_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opROL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAL_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAR_RegMem_W_Imm_Vs         : [some((RegMem, W))   , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opROR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opRCR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSHR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAL_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opSAR_RegMem_Vs_Imm_Vs        : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opAMX_AL_W_AH_W_Imm_W         : [some((AL, W))       , some((AH, W))       , some((Imm, W))      , nop                 , ]
    of opAAM_AL_W_AH_W               : [some((AL, W))       , some((AH, W))       , nop                 , nop                 , ]
    of opADX_AL_W_AH_W_Imm_W         : [some((AL, W))       , some((AH, W))       , some((Imm, W))      , nop                 , ]
    of opAAD_AL_W_AH_W               : [some((AL, W))       , some((AH, W))       , nop                 , nop                 , ]
    of opSALC_AL_W                   : [some((AL, W))       , nop                 , nop                 , nop                 , ]
    of opXLAT_AL_W_Mem_W             : [some((AL, W))       , some((Mem, W))      , nop                 , nop                 , ]
    of opLOOPNZ_Imm_Vs_Imm_Vs        : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opLOOPZ_Imm_Vs_Imm_Vs         : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opLOOP_Imm_Vs_Imm_Vs          : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opJCXZ_Imm_Vs_Imm_Vs          : [some((Imm, Vs))     , some((Imm, Vs))     , nop                 , nop                 , ]
    of opIN_AL_W_Imm_W               : [some((AL, W))       , some((Imm, W))      , nop                 , nop                 , ]
    of opIN_EAX_D_Imm_W              : [some((EAX, D))      , some((Imm, W))      , nop                 , nop                 , ]
    of opOUT_Imm_W_AL_W              : [some((Imm, W))      , some((AL, W))       , nop                 , nop                 , ]
    of opOUT_Imm_W_EAX_D             : [some((Imm, W))      , some((EAX, D))      , nop                 , nop                 , ]
    of opCALL_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJMP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJMPF_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJMP_Imm_Vs                  : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opIN_AL_W_Imm_Vs              : [some((AL, W))       , some((Imm, Vs))     , nop                 , nop                 , ]
    of opIN_EAX_D_Imm_Vs             : [some((EAX, D))      , some((Imm, Vs))     , nop                 , nop                 , ]
    of opOUT_Imm_Vs_AL_W             : [some((Imm, Vs))     , some((AL, W))       , nop                 , nop                 , ]
    of opOUT_Imm_Vs_EAX_D            : [some((Imm, Vs))     , some((EAX, D))      , nop                 , nop                 , ]
    of opLOCK                        : [nop                 , nop                 , nop                 , nop                 , ]
    of opINT1_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opREPNZ_Imm_Vs                : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opREPZ_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opHLT                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opCMC                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opTEST_RegMem_W_Imm_W         : [some((RegMem, W))   , some((Imm, W))      , nop                 , nop                 , ]
    of opNOT_RegMem_W                : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opNEG_RegMem_W                : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opMUL_AX_W_AL_W_RegMem_W      : [some((AX, W))       , some((AL, W))       , some((RegMem, W))   , nop                 , ]
    of opIMUL_AX_W_AL_W_RegMem_W     : [some((AX, W))       , some((AL, W))       , some((RegMem, W))   , nop                 , ]
    of opDIV_AL_W_AH_W_AX_W_RegMem_W : [some((AL, W))       , some((AH, W))       , some((AX, W))       , some((RegMem, W))   , ]
    of opIDIV_AL_W_AH_W_AX_W_RegMem_W: [some((AL, W))       , some((AH, W))       , some((AX, W))       , some((RegMem, W))   , ]
    of opTEST_RegMem_Vs_Imm_Vs       : [some((RegMem, Vs))  , some((Imm, Vs))     , nop                 , nop                 , ]
    of opNOT_RegMem_Vs               : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
    of opNEG_RegMem_Vs               : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
    of opMUL_Imm_Vs_EAX_D_RegMem_Vs  : [some((Imm, Vs))     , some((EAX, D))      , some((RegMem, Vs))  , nop                 , ]
    of opIMUL_Imm_Vs_EAX_D_RegMem_Vs : [some((Imm, Vs))     , some((EAX, D))      , some((RegMem, Vs))  , nop                 , ]
    of opDIV_Imm_Vs_EAX_D_RegMem_Vs  : [some((Imm, Vs))     , some((EAX, D))      , some((RegMem, Vs))  , nop                 , ]
    of opIDIV_Imm_Vs_EAX_D_RegMem_Vs : [some((Imm, Vs))     , some((EAX, D))      , some((RegMem, Vs))  , nop                 , ]
    of opCLC                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opSTC                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opCLI                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opSTI                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opCLD                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opSTD                         : [nop                 , nop                 , nop                 , nop                 , ]
    of opINC_RegMem_W                : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opDEC_RegMem_W                : [some((RegMem, W))   , nop                 , nop                 , nop                 , ]
    of opINC_RegMem_Vs               : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
    of opDEC_RegMem_Vs               : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
    of opCALL_RegMem_Vs              : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
    of opCALLF_Imm_Vs                : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opJMP_RegMem_Vs               : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
    of opJMPF_Imm_Vs                 : [some((Imm, Vs))     , nop                 , nop                 , nop                 , ]
    of opPUSH_RegMem_Vs              : [some((RegMem, Vs))  , nop                 , nop                 , nop                 , ]
