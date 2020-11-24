library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_WB is 
    port (i_CLK, stall, flush : in std_logic;
          MemToReg, RegWrite : in std_logic;
          RegWrData, NextInstrAddr : in std_logic_vector(31 downto 0);
          MemToReg_o, RegWrite_o : out std_logic;
          RegWrData_o, NextInstrAddr_o : out std_logic_vector(31 downto 0));
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
    
    reg2: ndff
    port map(i_CLK, flush, notStall, RegWrData, RegWrData_o);

    reg3: ndff
    port map(i_CLK, flush, notStall, NextInstrAddr, NextInstrAddr_o);

end struct;