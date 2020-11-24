library IEEE;
use IEEE.std_logic_1164.all;

entity EX_MEM is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, MemWrite, RegWrite, BranchEq, BranchNeq, Jump, JumpReg, JAL : in std_logic;
          dALU, bALU, jumpAddr, pcPlus4 : in std_logic_vector(31 downto 0);
          MemToReg_o, MemWrite_o, RegWrite_o, BranchEq_o, BranchNeq_o, Jump_o, JumpReg_o, JAL_o : out std_logic;
          dALU_o, bALU_o, jumpAddr_o, pcPlus4_o : out std_logic_vector(31 downto 0));

end EX_MEM;

architecture struct of EX_MEM is

component ndff
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;    -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);   -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));  -- Data value output
end component;    

component ndff_1bit is
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;    -- Reset input
         i_WE         : in std_logic;    -- Write enable input
         i_D          : in std_logic;   -- Data value input
         o_Q          : out std_logic);  -- Data value output
end component;

signal notStall : std_logic;

begin

    notStall <= not stall;

    reg0: ndff_1bit
    port map(i_CLK, flush, notStall, MemToReg, MemtoReg_o);

    reg1: ndff_1bit
    port map(i_CLK, flush, notStall, MemWrite, MemWrite_o);

    reg2: ndff_1bit
    port map(i_CLK, flush, notStall, RegWrite, RegWrite_o);

    reg3: ndff_1bit
    port map(i_CLK, flush, notStall, BranchEq, BranchEq_o);

    reg4: ndff_1bit
    port map(i_CLK, flush, notStall, BranchNeq, BranchNeq_o);

    reg5: ndff_1bit
    port map(i_CLK, flush, notStall, Jump, Jump_o);

    reg6: ndff_1bit
    port map(i_CLK, flush, notStall, JumpReg, JumpReg_o);

    reg7: ndff_1bit
    port map(i_CLK, flush, notStall, JAL, JAL_o);

    reg8: ndff
    port map(i_CLK, flush, notStall, dALU, dALU_o);

    reg9: ndff
    port map(i_CLK, flush, notStall, bALU, bALU_o);

    reg10: ndff
    port map(i_CLK, flush, notStall, jumpAddr, jumpAddr_o);

    reg11: ndff
    port map(i_CLK, flush, notStall, pcPlus4, pcPlus4_o);

end struct;