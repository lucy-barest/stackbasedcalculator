library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculator is 
  
  port( clock: in std_logic; -- clock signal
        b0:    in std_logic; -- button 0, capture input
        b1:    in std_logic; -- button 1, enter
        b2:    in std_logic; -- button 2, action
		  op:		in std_logic_vector(1 downto 0); -- action switches (2)
		  data:  in std_logic_vector(7 downto 0); -- input data switches (8)
		  digit0:out std_logic_vector(6 downto 0); -- output values for 7-segment display
		  digit1:out std_logic_vector(6 downto 0) -- output values for 7-segment display
        );
end entity;	  

architecture rtl of calculator is

	component memram
		port 
		(
			address		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	end component;
	
	component hexdisplay
		port 
		(
			a	   : in unsigned  (3 downto 0);
			result : out unsigned (6 downto 0)
		);
	end component;
	
	--internal signals
	signal RAM_input : std_logic_vector(7 downto 0);
	signal RAM_output : std_logic_vector(7 downto 0);
	signal RAM_we : std_logic;
	signal stack_ptr : UNSIGNED(3 downto 0);
	signal mbr : std_logic_vector(7 downto 0);
	signal state : std_logic_vector(2 downto 0);
	
	
begin
	process (clock, b1, b2)
	begin
		if B1='0' and B2='0' then
			stack_ptr <= (others => '0');
			mbr <= (others => '0');
			RAM_input <= (others => '0');
			RAM_we <= '0';
			state <= (others => '0');
		elsif (rising_edge(clock)) then
			case state is
				when "000" =>
				if (b0 = '0') then
					mbr <= data;
					state <= "111";
				end if;
				if (b1 = '0') then
					RAM_input <= mbr;
					RAM_we <= '1';
					state <= "001";
				end if;
				if (b2 = '0') then
					if (stack_ptr /= "0000") then
						stack_ptr <= stack_ptr - 1;
						state <= "100";
					end if;
				end if;
				when "001" =>
					RAM_we <= '0';
					stack_ptr <= stack_ptr + 1;
					state <= "111";
				when "100" =>
					state <= "101";
				when "101" =>
					state <= "110";
				when "110" =>
					case op is
						when "00" =>
							mbr <= std_logic_vector(unsigned(ram_output) + unsigned(mbr));
						when "01" =>
							mbr <= std_logic_vector(unsigned(ram_output) - unsigned(mbr));
						when "10" =>
							mbr <= std_logic_vector(unsigned(ram_output(3 downto 0)) * unsigned(mbr(3 downto 0)));
						when others =>
							mbr <= std_logic_vector(unsigned(ram_output) / unsigned(mbr));
					end case;
					state <= "111";
				when "111" =>
					if b0 ='1' and b1 = '1' and b2 = '1' then
						state <= "000";
					else
						null;
					end if;
				when others =>
					state <= "000";
			end case;
		end if;
	end process;

	memram1 : memram
		port map(address => std_logic_vector(stack_ptr), clock => clock, data => RAM_input, wren => RAM_we, q => RAM_output);
	hexdisplay1 : hexdisplay
		port map(a => unsigned(mbr(3 downto 0)), std_LOGIC_VECTOR(result) => digit0);
	hexdisplay2 : hexdisplay
		port map(a => unsigned(mbr(7 downto 4)), std_LOGIC_VECTOR(result) => digit1);

end rtl;

	