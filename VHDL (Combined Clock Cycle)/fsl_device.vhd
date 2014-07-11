------------------------------------------------------------------------------
-- fsl_device - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          fsl_device
-- Version:           1.00.a
-- Description:       Example FSL core (VHDL).
-- Date:              Thu Apr 03 21:37:58 2014 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.aes_package.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- FSL_Clk             : Synchronous clock
-- FSL_Rst           : System reset, should always come from FSL bus
-- FSL_S_Clk       : Slave asynchronous clock
-- FSL_S_Read      : Read signal, requiring next available input to be read
-- FSL_S_Data      : Input data
-- FSL_S_CONTROL   : Control Bit, indicating the input data are control word
-- FSL_S_Exists    : Data Exist Bit, indicating data exist in the input FSL bus
-- FSL_M_Clk       : Master asynchronous clock
-- FSL_M_Write     : Write signal, enabling writing to output FSL bus
-- FSL_M_Data      : Output data
-- FSL_M_Control   : Control Bit, indicating the output data are contol word
-- FSL_M_Full      : Full Bit, indicating output FSL bus is full
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity fsl_device is
	port 
	(
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete. 
		FSL_Clk	: in	std_logic;
		FSL_Rst	: in	std_logic;
		FSL_S_Clk	: in	std_logic;
		FSL_S_Read	: out	std_logic;
		FSL_S_Data	: in	std_logic_vector(0 to 31);
		FSL_S_Control	: in	std_logic;
		FSL_S_Exists	: in	std_logic;
		FSL_M_Clk	: in	std_logic;
		FSL_M_Write	: out	std_logic;
		FSL_M_Data	: out	std_logic_vector(0 to 31);
		FSL_M_Control	: out	std_logic;
		FSL_M_Full	: in	std_logic
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	);

attribute SIGIS : string; 
attribute SIGIS of FSL_Clk : signal is "Clk"; 
attribute SIGIS of FSL_S_Clk : signal is "Clk"; 
attribute SIGIS of FSL_M_Clk : signal is "Clk"; 

end fsl_device;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

-- In this section, we povide an example implementation of ENTITY fsl_device
-- that does the following:
--
-- 1. Read all inputs
-- 2. Add each input to the contents of register 'sum' which
--    acts as an accumulator
-- 3. After all the inputs have been read, write out the
--    content of 'sum' into the output FSL bus NUMBER_OF_OUTPUT_WORDS times
--
-- You will need to modify this example or implement a new architecture for
-- ENTITY fsl_device to implement your coprocessor

architecture EXAMPLE of fsl_device is

   -- Total number of input data.
   constant NUMBER_OF_INPUT_WORDS  : natural := 8;

   -- Total number of output data
   constant NUMBER_OF_OUTPUT_WORDS : natural := 4;

   type STATE_TYPE is (Idle, Read_Data, Read_Key, Read_Buffer, KeyExpansion, Conversion, Write_Buffer, Write_Outputs);
   type INNER_STATE_TYPE is (ISB, ISR, IMC, ARK);
   
   signal state        : STATE_TYPE;

   -- Accumulator to hold sum of inputs read at any point in time
   signal output          : std_logic_vector(0 to 31);
	signal data128		  : std_logic_vector(0 to 127);
	signal key128 		  : std_logic_vector(0 to 127);
	signal KeyArray	  : std_logic_vector(0 to 1408) := (others => '1');
	signal round		  : natural range 1 to 11;
	signal inner_state	: INNER_STATE_TYPE;

   -- Counters to store the number inputs read & outputs written
   signal nr_of_reads  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;
   signal nr_of_writes : natural range 0 to NUMBER_OF_OUTPUT_WORDS - 1;

begin
   -- CAUTION:
   -- The sequence in which data are read in and written out should be
   -- consistent with the sequence they are written and read in the
   -- driver's fsl_device.c file

   FSL_S_Read  <= FSL_S_Exists   when state = Read_Key or state = Read_Data  else '0';
   FSL_M_Write <= not FSL_M_Full when state = Write_Outputs else '0';

--   FSL_M_Data <= output;

   The_SW_accelerator : process (FSL_Clk) is
	
	variable temp		  : std_logic_vector(0 to 127);
   
	begin  -- process The_SW_accelerator
    if FSL_Clk'event and FSL_Clk = '1' then     -- Rising clock edge
      if FSL_Rst = '1' then               -- Synchronous reset (active high)
        -- CAUTION: make sure your reset polarity is consistent with the
        -- system reset polarity
        state        <= Idle;
		  inner_state <= ARK;
        nr_of_reads  <= 0;
        nr_of_writes <= 0;
        --sum          <= (others => '0');
      else
        case state is
          when Idle =>
            if (FSL_S_Exists = '1') then
              state       <= Read_Key;
              nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;
              --sum         <= (others => '0');
            end if;
				
			 when Read_Key =>
				if (FSL_S_Exists = '1') then
					if(nr_of_reads = 0) then
						state <= Read_Data;
						KeyArray(96 to 127) <= FSL_S_Data;
					elsif(nr_of_reads = 7) then
						KeyArray(0 to 31) <= FSL_S_Data;
						state <= Read_Data;
					elsif(nr_of_reads = 5) then
						KeyArray(32 to 63) <= FSL_S_Data;
						state <= Read_Data;
					elsif(nr_of_reads = 3) then
						KeyArray(64 to 95) <= FSL_S_Data;
						state <= Read_Data;
					elsif(nr_of_reads = 1) then
						KeyArray(96 to 127) <= FSL_S_Data;
						state <= Read_Data; 
					end if;
					nr_of_reads <= nr_of_reads - 1;
				end if;
				
			 when Read_Data =>
				if (FSL_S_Exists = '1') then
					if(nr_of_reads = 0) then
						data128(96 to 127) <= FSL_S_Data;
						state <= Read_Buffer;
					elsif(nr_of_reads = 6) then
						data128(0 to 31) <= FSL_S_Data;
						state <= Read_Key;
					elsif(nr_of_reads = 4) then
						data128(32 to 63) <= FSL_S_Data;
						state <= Read_Key;
					elsif(nr_of_reads = 2) then
						data128(64 to 95) <= FSL_S_Data;
						state <= Read_Key;
					end if;
					nr_of_reads <= nr_of_reads - 1;
				end if;
			
			 when Read_Buffer =>
				data128(96 to 127) <= FSL_S_Data;
				round <= 1;
				state <= KeyExpansion;
				nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
				
			 when KeyExpansion =>
				if(round = 10) then
					round <= 1;
					state <= Conversion;
				else
					round <= round + 1;
				end if;
				KeyArray((round*128) to (round*128)+127) <= KeyExpansion(KeyArray(((round-1)*128) to ((round-1)*128)+127), round);
			 when Conversion =>
				temp := data128;
				if(round = 1) then
					temp:= AddRoundKey(KeyArray(((11-round)*128) to ((11-round)*128)+127), temp);
					round <= round + 1;
				elsif(round = 11) then
					temp := InverseShiftRows(temp);
					temp := InverseSubBytes(temp);
					temp := AddRoundKey(KeyArray(((11-round)*128) to ((11-round)*128)+127), temp);					
					state <= Write_Buffer;
					round <= 1;
				else
					temp := InverseShiftRows(temp);
					temp := InverseSubBytes(temp);
					temp := AddRoundKey(KeyArray(((11-round)*128) to ((11-round)*128)+127), temp);
					temp := InverseMixColumns(temp);
					round <= round + 1;
				end if;
				data128 <= temp;
			
			 when Write_Buffer =>
				FSL_M_Data <= data128 (0 to 31);
--				FSL_M_Data <= KeyArray(1280 to 1311);

				state <= Write_Outputs;
          when Write_Outputs =>
            if (nr_of_writes = 0) then
              state <= Idle;
				  round <= 1;
				  FSL_M_Data <= data128(96 to 127);
--   			  FSL_M_Data <= KeyArray(1376 to 1407);
            else
              if (FSL_M_Full = '0') then
                nr_of_writes <= nr_of_writes - 1;
					 if(nr_of_writes = 3) then
						FSL_M_Data <= data128 (32 to 63);
--						FSL_M_Data <= KeyArray(1312 to 1343);
					 elsif(nr_of_writes = 2) then
						FSL_M_Data <= data128(64 to 95);
--						FSL_M_Data <= KeyArray(1344 to 1375);
					 elsif(nr_of_writes = 1) then
						FSL_M_Data <= data128(96 to 127);
--						FSL_M_Data <= KeyArray(1376 to 1407);
					 else
						FSL_M_Data <= data128(96 to 127);
--						FSL_M_Data <= KeyArray(1376 to 1407);
						state <= Idle;
					 end if;
              end if;
            end if;
        end case;
      end if;
    end if;
   end process The_SW_accelerator;
end architecture EXAMPLE;
