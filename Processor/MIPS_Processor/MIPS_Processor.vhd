-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Processor is
  generic(N : integer := 32);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- use this signal as the data memory output
  signal s_DMemOutWB    : std_logic_vector(N-1 downto 0); -- use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- use this signal as the instruction signal 
  signal s_InstID       : std_logic_vector(N-1 downto 0);
  signal s_InstEX       : std_logic_vector(N-1 downto 0);
  signal s_InstMEM      : std_logic_vector(N-1 downto 0);
  signal s_InstWB       : std_logic_vector(N-1 downto 0);

  -- Required halt signal -- for simulation
  signal v0             : std_logic_vector(N-1 downto 0); -- TODO: should be assigned to the output of register 2, used to implement the halt SYSCALL
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. This case happens when the syscall instruction is observed and the V0 register is at 0x0000000A. This signal is active high and should only be asserted after the last register and memory writes before the syscall are guaranteed to be completed.

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(clk          : in std_logic;
         addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
         data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
         we           : in std_logic := '1';
         q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
  end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  signal s_NextNextInstAddr     : std_logic_vector(N-1 downto 0); -- Input to PC
  signal s_NextNextInstAddrWRst : std_logic_vector(N-1 downto 0); -- Input to PC taking into account iRst
  signal s_NextNextInstAddrWCtl : std_logic_vector(N-1 downto 0);
  signal s_PCPlus4IF            : std_logic_vector(N-1 downto 0);
  signal s_PCPlus4ID            : std_logic_vector(N-1 downto 0);
  signal s_PCPlus4EX            : std_logic_vector(N-1 downto 0);
  signal s_PCPlus4MEM           : std_logic_vector(N-1 downto 0);
  signal s_PCPlus4WB            : std_logic_vector(N-1 downto 0);
  
  signal s_ReadData1ID      : std_logic_vector(N-1 downto 0);  -- Register file ReadData1 output
  signal s_ReadData1EX      : std_logic_vector(N-1 downto 0);  -- Register file ReadData1 output
  signal s_ReadData2ID      : std_logic_vector(N-1 downto 0);  -- Register file ReadData2 output
  signal s_ReadData2EX      : std_logic_vector(N-1 downto 0);  -- Register file ReadData2 output
  signal s_ReadData2MEM     : std_logic_vector(N-1 downto 0);  -- Register file ReadData2 output
  signal s_ImmID            : std_logic_vector(N-1 downto 0);  -- Sign extended immediate
  signal s_ImmEX            : std_logic_vector(N-1 downto 0);  -- Sign extended immediate

  signal s_ALUOutEX         : std_logic_vector(N-1 downto 0);  -- ALU output
  signal s_ALUOutMEM        : std_logic_vector(N-1 downto 0);  -- ALU output
  signal s_ALUOutWB         : std_logic_vector(N-1 downto 0);  -- ALU output
  signal s_ALUIn1           : std_logic_vector(N-1 downto 0);  -- ALU input 1
  signal s_ALUIn2           : std_logic_vector(N-1 downto 0);  -- ALU input 2
  signal s_ShiftAmtID       : std_logic_vector(N-1 downto 0);  -- 32 bit extended shift amount
  signal s_ShiftAmtEX       : std_logic_vector(N-1 downto 0);  -- 32 bit extended shift amount
  signal s_ALUIn1Temp       : std_logic_vector(N-1 downto 0);  -- Temp data for ALUIn1 muxes

  signal s_MemRegData       : std_logic_vector(N-1 downto 0);  -- Data from memory or ALUOut
  signal s_RegWrRdRt        : std_logic_vector(4 downto 0);    -- Output of mux for Rd/Rt

  signal s_RtID  : std_logic_vector(4 downto 0);    
  signal s_RtEX  : std_logic_vector(4 downto 0); 
  signal s_RtMEM : std_logic_vector(4 downto 0); 
  signal s_RtWB  : std_logic_vector(4 downto 0); 
  signal s_RdID  : std_logic_vector(4 downto 0);   
  signal s_RdEX  : std_logic_vector(4 downto 0);   
  signal s_RdMEM : std_logic_vector(4 downto 0); 
  signal s_RdWB  : std_logic_vector(4 downto 0); 

  signal s_Reg2ID  : std_logic_vector(N-1 downto 0); 
  signal s_Reg2EX  : std_logic_vector(N-1 downto 0);
  signal s_Reg2MEM : std_logic_vector(N-1 downto 0);
  signal s_Reg2WB  : std_logic_vector(N-1 downto 0);

  -- Control signals
  signal s_RegDstID    : std_logic;
  signal s_RegDstEX    : std_logic;
  signal s_RegDstMEM   : std_logic;
  signal s_RegDstWB    : std_logic;
  signal s_RegWrID     : std_logic;
  signal s_RegWrEX     : std_logic;
  signal s_RegWrMEM    : std_logic;
  signal s_RegWrWB     : std_logic;
  signal s_DMemWrID    : std_logic;
  signal s_DMemWrEX    : std_logic;
  signal s_DMemWrMEM   : std_logic;
  signal s_MemToRegID  : std_logic;
  signal s_MemToRegEX  : std_logic;
  signal s_MemToRegMEM : std_logic;
  signal s_MemToRegWB  : std_logic;
  signal s_ALUSrcID    : std_logic;
  signal s_ALUSrcEX    : std_logic;
  signal s_ALUOpID     : std_logic_vector(3 downto 0);
  signal s_ALUOpEX     : std_logic_vector(3 downto 0);
  signal s_LoadUpperID : std_logic;
  signal s_LoadUpperEX : std_logic;
  signal s_ShiftID     : std_logic;
  signal s_ShiftEX     : std_logic;
  signal s_SignExt     : std_logic;
  signal s_BranchEq    : std_logic;
  signal s_BranchNeq   : std_logic;
  signal s_Jump        : std_logic;
  signal s_JumpReg     : std_logic;
  signal s_JumpAndLinkID  : std_logic;
  signal s_JumpAndLinkEX  : std_logic;
  signal s_JumpAndLinkMEM : std_logic;
  signal s_JumpAndLinkWB  : std_logic;

  signal s_ReadDataEq : std_logic;

  -- Intermediate control signals
  signal s_BranchAddr     : std_logic_vector(N-1 downto 0); -- Immediate << 2
  signal s_BranchOrPC     : std_logic_vector(N-1 downto 0); -- BranchAddr + PC+4
  signal s_BranchNextAddr : std_logic_vector(N-1 downto 0);
  signal s_JumpOrBranch   : std_logic_vector(N-1 downto 0);
  signal s_JumpAddr       : std_logic_vector(N-1 downto 0);
  signal s_NextCtlAddr    : std_logic_vector(N-1 downto 0);

  signal s_Branch     : std_logic; -- Input to mux for branches
  signal s_ALUZero    : std_logic;
  signal s_Ctl        : std_logic;

  component register_file is
    port(i_Clk, i_WriteEnable , i_Reset     : in std_logic;
         i_ReadReg1, i_ReadReg2, i_WriteReg : in std_logic_vector(4 downto 0);
         i_WriteData                        : in std_logic_vector(31 downto 0);
         o_ReadData1, o_ReadData2, o_Reg2   : out std_logic_vector(31 downto 0));
  end component;

  component fullALU_shifter is
    port(i_a         : in std_logic_vector(31 downto 0);
         i_b         : in std_logic_vector(31 downto 0);
         i_s         : in std_logic_vector(3 downto 0);
         o_F         : out std_logic_vector(31 downto 0);
         o_cOut      : out std_logic;
         o_Overflow  : out std_logic;
         o_Zero      : out std_logic);
  end component;

  component extN_32 is
    -- i_Ctl: 0 = zero extend, 1 = sign extend
    generic(N : integer := 16);
    port(i_Ctl  : in std_logic;
         i_in   : in std_logic_vector(N-1 downto 0);
         o_32  : out std_logic_vector(31 downto 0));
  end component;

  component n_mux2_1 is
    generic(N : integer);
    port(i_A  : in std_logic_vector(N-1 downto 0);
         i_B  : in std_logic_vector(N-1 downto 0);
         i_S  : in std_logic;
         o_F  : out std_logic_vector(N-1 downto 0));
  end component;

  component ndff is
    generic(N : integer := 32);
    port(i_CLK        : in std_logic; 
         i_RST        : in std_logic;
         i_WE         : in std_logic; 
         i_D          : in std_logic_vector(N-1 downto 0); 
         o_Q          : out std_logic_vector(N-1 downto 0)); 
  end component;

  component ControlLogic is
    port(i_Opcode      : in std_logic_vector(5 downto 0);
         i_FunctCode   : in std_logic_vector(5 downto 0);
         o_RegDest     : out std_logic;
         o_MemToReg    : out std_logic;
         o_ALUOp       : out std_logic_vector(3 downto 0);
         o_MemWrite    : out std_logic;
         o_ALUSrc      : out std_logic;
         o_RegWrite    : out std_logic;
         o_Shift       : out std_logic;
         o_LoadUpper   : out std_logic;
         o_SignExt     : out std_logic;
         o_BranchEq    : out std_logic;
         o_BranchNeq   : out std_logic;
         o_Jump        : out std_logic;
         o_JumpReg     : out std_logic;
         o_JumpAndLink : out std_logic);
  end component;

  -- Pipeline Registers

  component IF_ID is 
    port (i_CLK, stall, flush : in std_logic;
          instr, pcPlus4      : in std_logic_vector(31 downto 0);
          instr_o, pcPlus4_o  : out std_logic_vector(31 downto 0));
  end component;

  component ID_EX is 
    port (i_CLK, stall, flush : in std_logic;
          ALUSrc, MemToReg, MemWrite, RegWrite, RegDst, Shift, LoadUpper, JAL : in std_logic;
          ALUOp : in std_logic_vector(3 downto 0);
          rt, rd : in std_logic_vector(4 downto 0);
          rData1, rData2, imm, shiftAmt, register2, pcPlus4, instr : in std_logic_vector(31 downto 0);
          ALUSrc_o, MemToReg_o, MemWrite_o, RegWrite_o, RegDst_o, Shift_o, LoadUpper_o, JAL_o : out std_logic;
          ALUOp_o : out std_logic_vector(3 downto 0);
          rt_o, rd_o : out std_logic_vector(4 downto 0);
          rData1_o, rData2_o, imm_o, shiftAmt_o, reg2_o, pcPlus4_o, instr_o : out std_logic_vector(31 downto 0));
  end component;

  component EX_MEM is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, MemWrite, RegWrite, RegDst, JumpAndLink : in std_logic;
          rt, rd : in std_logic_vector(4 downto 0);
          ALUOut, rData2, register2, pcPlus4, instr : in std_logic_vector(31 downto 0);
          MemToReg_o, MemWrite_o, RegWrite_o, RegDst_o, JumpAndLink_o : out std_logic;
          rt_o, rd_o : out std_logic_vector(4 downto 0);
          ALUOut_o, rData2_o, reg2_o, pcPlus4_o, instr_o : out std_logic_vector(31 downto 0));
  end component;

  component MEM_WB is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, RegWrite, RegDst, JumpAndLink : in std_logic;
          rt, rd : in std_logic_vector(4 downto 0);
          MemData, ALUOut, pcPlus4, register2, instr  : in std_logic_vector(31 downto 0);
          MemToReg_o, RegWrite_o, RegDst_o, JumpAndLink_o : out std_logic;
          rt_o, rd_o : out std_logic_vector(4 downto 0);
          MemData_o, ALUOut_o, pcPlus4_o, reg2_o, instr_o : out std_logic_vector(31 downto 0));
  end component;

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  s_Halt <='1' when (s_InstWB(31 downto 26) = "000000") and (s_InstWB(5 downto 0) = "001100") and (v0 = "00000000000000000000000000001010") else '0';

  -- TODO: Implement the rest of your processor below this comment! 

  oALUOut    <= s_ALUOutEX;
  s_DMemAddr <= s_ALUOutMEM;
  s_DMemData <= s_ReadData2MEM;
  s_DMemWr   <= s_DMemWrMEM;
  s_RegWr    <= s_RegWrWB;

  v0 <= s_Reg2WB;

  s_Ctl <= s_Branch or s_Jump or s_JumpReg;
  s_NextNextInstAddrWCtl <= s_NextCtlAddr when s_Ctl = '1' else s_PCPlus4IF;
  s_NextNextInstAddrWRst <=  x"00400000" when iRst = '1' else s_NextNextInstAddrWCtl;

  PC: ndff
    port map(i_CLK => iCLK,
             i_RST => '0',
             i_WE  => '1',
             i_D   => s_NextNextInstAddrWRst,
             o_Q   => s_NextInstAddr); 

  PCALU: fullALU_shifter
    port map(i_a        => s_NextInstAddr,
             i_b        => x"00000004",
             i_s        => "0101",
             o_F        => s_PCPlus4IF,
             o_cOut     => open,
             o_Overflow => open,
             o_Zero     => open);

  RegFile: register_file
    port map(i_Clk         => iCLK, 
             i_WriteEnable => s_RegWrWB,
             i_ReadReg1    => s_InstID(25 downto 21), 
             i_ReadReg2    => s_InstID(20 downto 16), 
             i_WriteReg    => s_RegWrAddr,
             i_WriteData   => s_RegWrData,
             i_Reset       => iRST,
             o_ReadData1   => s_ReadData1ID,
             o_ReadData2   => s_ReadData2ID,
             o_Reg2        => s_Reg2ID);

  DataALU: fullALU_shifter
    port map(i_a        => s_ALUIn1,
             i_b        => s_ALUIn2,
             i_s        => s_ALUOpEX,
             o_F        => s_ALUOutEX,
             o_cOut     => open,
             o_Overflow => open,
             o_Zero     => open);

  SignExtend: extN_32
    port map(i_Ctl => s_SignExt,
             i_in  => s_InstID(15 downto 0),
             o_32  => s_ImmID);

  ZeroExtend: extN_32
    generic map(N => 5)
    port map(i_Ctl => '0',
             i_in  => s_InstID(10 downto 6),
             o_32  => s_ShiftAmtID);

  -- Basic Logic

  WriteReg: n_mux2_1
    generic map(N => 5)
    port map(i_A => s_RtWB,
             i_B => s_RdWB,
             i_S => s_RegDstWB,
             o_F => s_RegWrRdRt);

  WriteRegJump: n_mux2_1
    generic map(N => 5)
    port map(i_A => s_RegWrRdRt,
             i_B => "11111", -- 31
             i_S => s_JumpAndLinkWB,
             o_F => s_RegWrAddr);

  WriteRegData: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_MemRegData,
             i_B => s_PCPlus4WB,
             i_S => s_JumpAndLinkWB,
             o_F => s_RegWrData);

  ALUImm: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_ReadData2EX,
             i_B => s_ImmEX,
             i_S => s_ALUSrcEX,
             o_F => s_ALUIn2);

  Shift: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_ReadData1EX,
             i_B => s_ShiftAmtEX,
             i_S => s_ShiftEX,
             o_F => s_ALUIn1Temp);

  LoadUpper: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_ALUIn1Temp,
             i_B => x"00000010",
             i_S => s_LoadUpperEX,
             o_F => s_ALUIn1);

  MemToReg: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_DMemOutWB,
             i_B => s_ALUOutWB,
             i_S => s_MemToRegWB,
             o_F => s_MemRegData);

  -- Control Flow Components

  s_BranchAddr <= s_ImmID(29 downto 0) & "00";

  BranchALU: fullALU_shifter
    port map(i_a        => s_PCPlus4ID,
             i_b        => s_BranchAddr,
             i_s        => "0101", -- add
             o_F        => s_BranchNextAddr,
             o_cOut     => open,
             o_Overflow => open,
             o_Zero     => open);

  s_JumpAddr <= s_PCPlus4ID(31 downto 28) & s_InstID(25 downto 0) & "00";

  -- Control Flow Logic

  s_ReadDataEq <= '1' when s_ReadData1ID = s_ReadData2ID else '0';
  s_Branch <= (s_BranchEq and s_ReadDataEq) or (s_BranchNeq and (not s_ReadDataEq));

  Branch: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_PCPlus4ID,
             i_B => s_BranchNextAddr,
             i_S => s_Branch,
             o_F => s_BranchOrPC);

  Jump: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_BranchOrPC,
             i_B => s_JumpAddr,
             i_S => s_Jump,
             o_F => s_JumpOrBranch);

  JumpReg: n_mux2_1
    generic map(N => 32)
    port map(i_A => s_JumpOrBranch,
             i_B => s_ReadData1ID,
             i_S => s_JumpReg,
             o_F => s_NextCtlAddr);

  CtlLogic: ControlLogic
    port map(i_Opcode      => s_InstID(31 downto 26),
             i_FunctCode   => s_InstID(5 downto 0),
             o_RegDest     => s_RegDstID,
             o_MemToReg    => s_MemToRegID,
             o_ALUOp       => s_ALUOpID,
             o_MemWrite    => s_DMemWrID,
             o_ALUSrc      => s_ALUSrcID,
             o_RegWrite    => s_RegWrID,
             o_Shift       => s_ShiftID,
             o_LoadUpper   => s_LoadUpperID,
             o_SignExt     => s_SignExt,
             o_BranchEq    => s_BranchEq,
             o_BranchNeq   => s_BranchNeq,
             o_Jump        => s_Jump,
             o_JumpReg     => s_JumpReg,
             o_JumpAndLink => s_JumpAndLinkID);

  -- Pipeline Registers

  IFID: IF_ID 
    port map(i_CLK     => iClk,
             stall     => iRst,
             flush     => '0',
             instr     => s_Inst,
             pcPlus4   => s_PCPlus4IF,
             instr_o   => s_InstID, 
             pcPlus4_o => s_PCPlus4ID);

  IDEX: ID_EX 
    port map(i_CLK       => iClk, 
             stall       => '0', 
             flush       => '0',
             ALUSrc      => s_ALUSrcID, 
             ALUOp       => s_ALUOpID, 
             MemToReg    => s_MemToRegID, 
             MemWrite    => s_DMemWrID, 
             RegWrite    => s_RegWrID, 
             RegDst      => s_RegDstID, 
             Shift       => s_ShiftID, 
             LoadUpper   => s_LoadUpperID,
             JAL         => s_JumpAndLinkID, 
             rt          => s_InstID(20 downto 16), 
             rd          => s_InstID(15 downto 11),
             rData1      => s_ReadData1ID,
             rData2      => s_ReadData2ID, 
             imm         => s_ImmID, 
             shiftAmt    => s_shiftAmtID, 
             register2   => s_Reg2ID, 
             pcPlus4     => s_PCPlus4ID,
             instr       => s_InstID,
             ALUSrc_o    => s_ALUSrcEX, 
             ALUOp_o     => s_ALUOpEX, 
             MemToReg_o  => s_MemToRegEX, 
             MemWrite_o  => s_DMemWrEX, 
             RegWrite_o  => s_RegWrEX, 
             RegDst_o    => s_RegDstEX, 
             Shift_o     => s_ShiftEX, 
             LoadUpper_o => s_LoadUpperEX,
             JAL_o       => s_JumpAndLinkEX,
             rt_o        => s_RtEX, 
             rd_o        => s_RdEX,
             rData1_o    => s_ReadData1EX, 
             rData2_o    => s_ReadData2EX, 
             imm_o       => s_ImmEX, 
             shiftAmt_o  => s_ShiftAmtEX, 
             reg2_o      => s_Reg2EX, 
             pcPlus4_o   => s_PCPlus4EX,
             instr_o     => s_InstEX);

  EXMEM: EX_MEM
    port map(i_CLK         => iClk, 
             stall         => '0', 
             flush         => '0', 
             MemToReg      => s_MemToRegEX, 
             MemWrite      => s_DMemWrEX, 
             RegWrite      => s_RegWrEX, 
             RegDst        => s_RegDstEX, 
             JumpAndLink   => s_JumpAndLinkEX,
             rt            => s_RtEX, 
             rd            => s_RdEX,
             ALUOut        => s_ALUOutEX, 
             rData2        => s_ReadData2EX, 
             register2     => s_Reg2EX, 
             pcPlus4       => s_PCPlus4EX,
             instr         => s_InstEX,
             MemToReg_o    => s_MemToRegMEM, 
             MemWrite_o    => s_DMemWrMEM, 
             RegWrite_o    => s_RegWrMEM,  
             RegDst_o      => s_RegDstMEM, 
             JumpAndLink_o => s_JumpAndLinkMEM,
             rt_o          => s_RtMEM, 
             rd_o          => s_RdMEM, 
             ALUOut_o      => s_ALUOutMEM, 
             rData2_o      => s_ReadData2MEM, 
             reg2_o        => s_Reg2MEM, 
             pcPlus4_o     => s_PCPlus4MEM,
             instr_o       => s_InstMEM);

  MEMWB: MEM_WB
    port map(i_CLK         => iClk, 
             stall         => '0', 
             flush         => '0',  
             MemToReg      => s_MemToRegMEM, 
             RegWrite      => s_RegWrMEM,
             RegDst        => s_RegDstMEM, 
             JumpAndLink   => s_JumpAndLinkMEM,
             rt            => s_RtMEM, 
             rd            => s_RdMEM,
             MemData       => s_DMemOut, 
             ALUOut        => s_ALUOutMEM, 
             pcPlus4       => s_PCPlus4MEM, 
             register2     => s_Reg2MEM,
             instr         => s_InstMEM,
             MemToReg_o    => s_MemToRegWB, 
             RegWrite_o    => s_RegWrWB, 
             RegDst_o      => s_RegDstWB,
             JumpAndLink_o => s_JumpAndLinkWB,
             rt_o          => s_RtWB, 
             rd_o          => s_RdWB, 
             MemData_o     => s_DMemOutWB, 
             ALUOut_o      => s_ALUOutWB, 
             pcPlus4_o     => s_PCPlus4WB, 
             reg2_o        => s_Reg2WB,
             instr_o       => s_InstWB);

end structure;
