library IEEE;
use IEEE.std_logic_1164.all;

entity tb_pipelineReg is
    generic(gCLK_HPER   : time := 50 ns);
end tb_pipelineReg;

architecture behavioral of tb_pipelineReg is

constant cCLK_PER  : time := gCLK_HPER * 2;

component IF_ID
    port (i_CLK, stall, flush : in std_logic;
          instr, pcPlus4 : in std_logic_vector(31 downto 0);
          instr_o, pcPlus4_o : out std_logic_vector(31 downto 0));
end component;

component ID_EX is 
    port (i_CLK, stall, flush : in std_logic;
          ALUSrc, ALUOp, MemToReg, MemWrite, RegWrite, RegDst, Shift, LoadUpper, SignExt, BranchEq, BranchNeq, Jump, JumpReg, JAL : in std_logic;
          rData1, rData2, imm, pcPlus4 : in std_logic_vector(31 downto 0);
          ALUSrc_o, ALUOp_o, MemToReg_o, MemWrite_o, RegWrite_o, RegDst_o, Shift_o, LoadUpper_o, SignExt_o, BranchEq_o, BranchNeq_o, Jump_o, JumpReg_o, JAL_o : out std_logic;
          rData1_o, rData2_o, imm_o, pcPlus4_o : out std_logic_vector(31 downto 0));
end component;

component EX_MEM is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, MemWrite, RegWrite, BranchEq, BranchNeq, Jump, JumpReg, JAL : in std_logic;
          dALU, bALU, jumpAddr, pcPlus4 : in std_logic_vector(31 downto 0);
          MemToReg_o, MemWrite_o, RegWrite_o, BranchEq_o, BranchNeq_o, Jump_o, JumpReg_o, JAL_o : out std_logic;
          dALU_o, bALU_o, jumpAddr_o, pcPlus4_o : out std_logic_vector(31 downto 0));
end component;

component MEM_WB is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, RegWrite : in std_logic;
          RegWrData, NextInstrAddr : in std_logic_vector(31 downto 0);
          MemToReg_o, RegWrite_o : out std_logic;
          RegWrData_o, NextInstrAddr_o : out std_logic_vector(31 downto 0));
end component;

signal sCLK, sStall, sFlush : std_logic;

-- IF-ID
signal sInstr, s_pcPlus4, sInstr_o, s_pcPlus4_o : std_logic_vector(31 downto 0);

-- ID-EX
signal sALUSrc, sALUOp, sMemToReg, sMemWrite, sRegWrite, sRegDst, sShift, sLoadUpper, sSignExt, sBranchEq, sBranchNeq, sJump, sJumpReg, sJAL : std_logic;
signal s_rData1, s_rData2, s_imm : std_logic_vector(31 downto 0);
signal sALUSrc_o, sALUOp_o, sMemToReg_o, sMemWrite_o, sRegWrite_o, sRegDst_o, sShift_o, sLoadUpper_o, sSignExt_o, sBranchEq_o, sBranchNeq_o, sJump_o, sJumpReg_o, sJAL_o : std_logic;
signal s_rData1_o, s_rData2_o, s_imm_o : std_logic_vector(31 downto 0);

-- EX-MEM
signal s_dALU, s_bALU, s_jumpAddr : std_logic_vector(31 downto 0);
    -- control sigs already declared
signal s_dALU_o, s_bALU_o, s_jumpAddr_o : std_logic_vector(31 downto 0);

-- MEM-WB
signal sRegWrData, sNextInstrAddr : std_logic_vector(31 downto 0);
    -- control sigs already declared
signal sRegWrData_o, sNextInstrAddr_o : std_logic_vector(31 downto 0);

begin

DUT0: IF_ID
port map(sCLK, sStall, sFlush, 
         sInstr, s_pcPlus4, 
         sInstr_o, s_pcPlus4_o);

DUT1: ID_EX
port map(sCLK, sStall, sFlush, 
         sALUSrc, sALUOp, sMemToReg, sMemWrite, sRegWrite, sRegDst, sShift, sLoadUpper, sSignExt, sBranchEq, sBranchNeq, sJump, sJumpReg, sJAL,
         s_rData1, s_rData2, s_imm, s_pcPlus4,
         sALUSrc_o, sALUOp_o, sMemToReg_o, sMemWrite_o, sRegWrite_o, sRegDst_o, sShift_o, sLoadUpper_o, sSignExt_o, sBranchEq_o, sBranchNeq_o, sJump_o, sJumpReg_o, sJAL_o,
         s_rData1_o, s_rData2_o, s_imm_o, s_pcPlus4_o);

DUT2: EX_MEM
port map(sCLK, sStall, sFlush,
         sMemtoReg, sMemWrite, sRegWrite, sBranchEq, sBranchNeq, sJump, sJumpReg, sJAL,
         s_dALU, s_bALU, s_jumpAddr, s_pcPlus4,
         sMemtoReg_o, sMemWrite_o, sRegWrite_o, sBranchEq_o, sBranchNeq_o, sJump_o, sJumpReg_o, sJAL_o,
         s_dALU_o, s_bALU_o, s_jumpAddr_o, s_pcPlus4_o);

DUT3: MEM_WB
port map(sCLK, sStall, sFlush,
         sMemtoReg, sRegWrite,
         sRegWrData, sNextInstrAddr,
         sMemtoReg_o, sRegWrite_o,
         sRegWrData_o, sNextInstrAddr_o);

P_CLK: process
  begin
    sCLK <= '0';
    wait for gCLK_HPER;
    sCLK <= '1';
    wait for gCLK_HPER;
end process;

test: process
    begin

        -- test values
        sStall <= '0';
        sFlush <= '0';

        sInstr <= x"00000000";
        s_pcPlus4 <= x"00000001";

        sALUSrc <= '1';
        sALUOp <= '1'; 
        sMemToReg <= '1';
        sMemWrite <= '1';
        sRegWrite <= '1';
        sRegDst <= '1';
        sShift <= '1';
        sLoadUpper <= '1';
        sSignExt <= '1';
        sBranchEq <= '1';
        sBranchNeq <= '1';
        sJump <= '1';
        sJumpReg <= '1';
        sJAL <= '1';
        s_rData1 <= x"11111111";
        s_rData2 <= x"22222222";
        s_imm <= x"33333333";

        s_dALU <= x"44444444";
        s_bALU <= x"55555555";
        s_jumpAddr <= x"10000000";

        sRegWrData <= x"66666666";
        sNextInstrAddr <= x"00000002";

        wait for cCLK_PER;

        wait;
        
end process;

end behavioral;