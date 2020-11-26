library IEEE;
use IEEE.std_logic_1164.all;

entity IF_ID is 
    port (i_CLK, stall, flush : in std_logic;
          instr, pcPlus4 : in std_logic_vector(31 downto 0);
          instr_o, pcPlus4_o : out std_logic_vector(31 downto 0));
end IF_ID;

architecture struct of IF_ID is

component ndff
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;    -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic_vector(N-1 downto 0);   -- Data value input
         o_Q          : out std_logic_vector(N-1 downto 0));  -- Data value output
end component;    

signal notStall : std_logic;

begin

    notStall <= not stall;

    instReg: ndff
    port map(i_CLK, flush, notStall, instr, instr_o);

    pcReg: ndff
    port map(i_CLK, flush, notStall, pcPlus4, pcPlus4_o);

end struct;