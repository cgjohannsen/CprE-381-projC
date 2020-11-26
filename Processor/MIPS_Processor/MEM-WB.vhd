library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_WB is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, RegWrite, RegDst, JumpAndLink : in std_logic;
          rt, rd : in std_logic_vector(4 downto 0);
          MemData, ALUOut, pcPlus4, register2, instr  : in std_logic_vector(31 downto 0);
          MemToReg_o, RegWrite_o, RegDst_o, JumpAndLink_o : out std_logic;
          rt_o, rd_o : out std_logic_vector(4 downto 0);
          MemData_o, ALUOut_o, pcPlus4_o, reg2_o, instr_o : out std_logic_vector(31 downto 0));
end MEM_WB;

architecture struct of MEM_WB is

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
    port map(i_CLK, flush, notStall, MemToReg, MemToReg_o);

    reg1: ndff_1bit 
    port map(i_CLK, flush, notStall, RegWrite, RegWrite_o);

    reg2: ndff_1bit 
    port map(i_CLK, flush, notStall, RegDst, RegDst_o);

    reg3: ndff_1bit 
    port map(i_CLK, flush, notStall, JumpAndLink, JumpAndLink_o);
    
    reg4: ndff
    port map(i_CLK, flush, notStall, MemData, MemData_o);

    reg5: ndff
    port map(i_CLK, flush, notStall, ALUOut, ALUOut_o);

    reg6: ndff
    port map(i_CLK, flush, notStall, pcPlus4, pcPlus4_o);

    reg7: ndff
    port map(i_CLK, flush, notStall, register2, reg2_o);

    reg8: ndff
    port map(i_CLK, flush, notStall, instr, instr_o);

    reg9: ndff
    generic map(N => 5)
    port map(i_CLK, flush, notStall, rt, rt_o);

    reg10: ndff
    generic map(N => 5)
    port map(i_CLK, flush, notStall, rd, rd_o);

end struct;