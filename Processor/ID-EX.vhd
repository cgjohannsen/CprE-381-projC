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

signal sALUSrc, sALUOp, sMemToReg, sMemWrite, sRegWrite, sRegDst, sShift, sLoadUpper, sSignExt, sBranchEq, sBranchNeq, sJump, sJumpReg, sJAL : std_logic;
signal s_rData1, s_rData2, s_imm, s_pcPlus4 : std_logic_vector(31 downto 0);
signal notStall : std_logic;

begin

    notStall <= not stall;

    reg0: ndff_1bit
    generic map(N => 1)
    port map(i_CLK, flush, notStall, ALUSrc, sALUSrc);

ALUSrc_o <= sALUSrc;

end struct;