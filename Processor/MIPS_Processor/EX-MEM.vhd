library IEEE;
use IEEE.std_logic_1164.all;

entity EX_MEM is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, MemWrite, RegWrite, RegDst, JumpAndLink : in std_logic;
          rt, rd : in std_logic_vector(4 downto 0);
          ALUOut, rData2, register2, pcPlus4, instr : in std_logic_vector(31 downto 0);
          MemToReg_o, MemWrite_o, RegWrite_o, RegDst_o, JumpAndLink_o : out std_logic;
          rt_o, rd_o : out std_logic_vector(4 downto 0);
          ALUOut_o, rData2_o, reg2_o, pcPlus4_o, instr_o : out std_logic_vector(31 downto 0));
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
    port map(i_CLK, flush, notStall, RegDst, RegDst_o);

    reg4: ndff_1bit
    port map(i_CLK, flush, notStall, JumpAndLink, JumpAndLink_o);

    reg8: ndff
    port map(i_CLK, flush, notStall, ALUOut, ALUOut_o);

    reg9: ndff
    port map(i_CLK, flush, notStall, rData2, rData2_o);

    reg10: ndff
    port map(i_CLK, flush, notStall, register2, reg2_o);

    reg11: ndff
    port map(i_CLK, flush, notStall, pcPlus4, pcPlus4_o);

    reg12: ndff
    port map(i_CLK, flush, notStall, instr, instr_o);

    reg13: ndff
    generic map(N => 5)
    port map(i_CLK, flush, notStall, rt, rt_o);

    reg14: ndff
    generic map(N => 5)
    port map(i_CLK, flush, notStall, rd, rd_o);

end struct;