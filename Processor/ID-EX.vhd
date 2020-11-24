library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EX is 
    port (i_CLK, stall, flush : in std_logic;
          ALUSrc, ALUOp, MemToReg, MemWrite, RegWrite, RegDst, Shift, LoadUpper, SignExt, BranchEq, BranchNeq, Jump, JumpReg, JAL : in std_logic;
          rData1, rData2, imm, pcPlus4 : in std_logic_vector(31 downto 0);
          ALUSrc_o, ALUOp_o, MemToReg_o, MemWrite_o, RegWrite_o, RegDst_o, Shift_o, LoadUpper_o, SignExt_o, BranchEq_o, BranchNeq_o, Jump_o, JumpReg_o, JAL_o : out std_logic;
          rData1_o, rData2_o, imm_o, pcPlus4_o : out std_logic_vector(31 downto 0));
end ID_EX;

architecture struct of ID_EX is

component ndff
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;    -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);   -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));  -- Data value output
end component;    

component ndff_1bit is
    port(i_CLK        : in std_logic;     		   -- Clock input
         i_RST        : in std_logic;    			   -- Reset input
         i_WE         : in std_logic;     		   -- Write enable input
         i_D          : in std_logic;   -- Data value input
         o_Q          : out std_logic);  -- Data value output
end component;

signal notStall : std_logic;

begin

    notStall <= not stall;

    reg0: ndff_1bit
    port map(i_CLK, flush, notStall, ALUSrc, ALUSrc_o);

    reg1: ndff_1bit
    port map(i_CLK, flush, notStall, ALUOp, ALUOp_o);

    reg2: ndff_1bit
    port map(i_CLK, flush, notStall, MemToReg, MemToReg_o);

    reg3: ndff_1bit
    port map(i_CLK, flush, notStall, MemWrite, MemWrite_o);

    reg4: ndff_1bit
    port map(i_CLK, flush, notStall, RegWrite, RegWrite_o);

    reg5: ndff_1bit
    port map(i_CLK, flush, notStall, RegDst, RegDst_o);

    reg6: ndff_1bit
    port map(i_CLK, flush, notStall, Shift, Shift_o);

    reg7: ndff_1bit
    port map(i_CLK, flush, notStall, LoadUpper, LoadUpper_o);

    reg8: ndff_1bit
    port map(i_CLK, flush, notStall, SignExt, SignExt_o);

    reg9: ndff_1bit
    port map(i_CLK, flush, notStall, BranchEq, BranchEq_o);

    reg10: ndff_1bit
    port map(i_CLK, flush, notStall, BranchNeq, BranchNeq_o);

    reg11: ndff_1bit
    port map(i_CLK, flush, notStall, Jump, Jump_o);

    reg12: ndff_1bit
    port map(i_CLK, flush, notStall, JumpReg, JumpReg_o);

    reg13: ndff_1bit
    port map(i_CLK, flush, notStall, JAL, JAL_o);

    reg14: ndff
    port map(i_CLK, flush, notStall, rData1, rData1_o);

    reg15: ndff
    port map(i_CLK, flush, notStall, rData2, rData2_o);

    reg16: ndff
    port map(i_CLK, flush, notStall, imm, imm_o);

    reg17: ndff
    port map(i_CLK, flush, notStall, pcPlus4, pcPlus4_o);

end struct;