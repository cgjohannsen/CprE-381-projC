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

signal sCLK, sStall, sFlush : std_logic;
signal sInstr, sPC, sInstr_o, sPC_o : std_logic_vector(31 downto 0);

begin 

DUT: IF_ID
port map(sCLK, sStall, sFlush, sInstr, sPC, sInstr_o, sPC_o);

P_CLK: process
  begin
    sCLK <= '1';
    wait for gCLK_HPER;
    sCLK <= '0';
    wait for gCLK_HPER;
end process;

test: process
    begin

        -- test values
        sStall <= '0';
        sFlush <= '0';
        sInstr <= x"FFFFFFFF";
        sPC <= x"11111111";
        wait for cCLK_PER;

        wait;
        
end process;

end behavioral;