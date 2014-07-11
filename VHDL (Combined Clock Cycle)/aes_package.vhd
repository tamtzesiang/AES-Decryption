--Package declaration for the above program
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

package aes_package is

 --function declaration.
 	FUNCTION KeyExpansion ( RoundKey128 : std_logic_vector(0 to 127); round: natural range 0 to 11) RETURN std_logic_vector;
	function getRCon(round: natural range 0 to 11) return std_logic_vector;
	FUNCTION getSBOXInv (data8: std_logic_vector(0 to 7)) RETURN std_logic_vector;
	FUNCTION getSBOX (data8:std_logic_vector(0 to 7)) RETURN std_logic_vector;
	FUNCTION InverseSubBytes ( data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector;
	FUNCTION InverseShiftRows ( data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector; 
	FUNCTION InverseMixColumns( data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector;
	FUNCTION mult ( a: std_logic_vector(0 to 7); b: std_logic_vector(0 to 7) ) RETURN std_logic_vector;
	
	FUNCTION AddRoundKey ( RoundKey128: std_logic_vector(0 to 127); data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector;
	
end aes_package;


package body aes_package is
	
function KeyExpansion (RoundKey128 : std_logic_vector(0 to 127); round: natural range 0 to 11) return std_logic_vector is
	variable nextRound : std_logic_vector(0 to 127);
	begin
		-- ROTWORD
		nextRound(0 to 23) := RoundKey128(104 to 127);
		nextRound(24 to 31) := RoundKey128(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := getSBOX(nextRound(0 to 7));
		nextRound(8 to 15) := getSBOX(nextRound(8 to 15));
		nextRound(16 to 23) := getSBOX(nextRound(16 to 23));
		nextRound(24 to 31) := getSBOX(nextRound(24 to 31));
		
		-- XOR
		nextRound(0 to 31) := nextRound(0 to 31) xor RoundKey128(0 to 31) xor getRCon(round);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey128(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey128(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey128(96 to 127);
		
		return nextRound;
	end KeyExpansion;

function getRCon(round: natural range 0 to 11) return std_logic_vector is
	variable rcon	: std_logic_vector(0 to 31) := (others => '0');
	begin
		case round is
			when 1 => rcon(0 to 7) := "00000001";
			when 2 => rcon(0 to 7) := "00000010";
			when 3 => rcon(0 to 7) := "00000100";
			when 4 => rcon(0 to 7) := "00001000";
			when 5 => rcon(0 to 7) := "00010000";
			when 6 => rcon(0 to 7) := "00100000";
			when 7 => rcon(0 to 7) := "01000000";
			when 8 => rcon(0 to 7) := "10000000";
			when 9 => rcon(0 to 7) := "00011011";
			when 10 => rcon(0 to 7) := "00110110";
			when others => rcon(0 to 7) := "00000000";
		end case;
		return rcon;
	end getRCon;
	
FUNCTION getSBOXInv (data8: std_logic_vector(0 to 7)) RETURN std_logic_vector is
	variable sboxInvValue	: std_logic_vector(0 to 7) := (others => '0');
	begin
		case data8 is
	WHEN x"00" => sboxInvValue := x"52"; WHEN x"01" => sboxInvValue := x"09"; 
            WHEN x"02" => sboxInvValue := x"6a"; WHEN x"03" => sboxInvValue := x"d5"; 
            WHEN x"04" => sboxInvValue := x"30"; WHEN x"05" => sboxInvValue := x"36"; 
            WHEN x"06" => sboxInvValue := x"a5"; WHEN x"07" => sboxInvValue := x"38"; 
            WHEN x"08" => sboxInvValue := x"bf"; WHEN x"09" => sboxInvValue := x"40"; 
            WHEN x"0a" => sboxInvValue := x"a3"; WHEN x"0b" => sboxInvValue := x"9e"; 
            WHEN x"0c" => sboxInvValue := x"81"; WHEN x"0d" => sboxInvValue := x"f3"; 
            WHEN x"0e" => sboxInvValue := x"d7"; WHEN x"0f" => sboxInvValue := x"fb"; 
            
            WHEN x"10" => sboxInvValue := x"7c"; WHEN x"11" => sboxInvValue := x"e3"; 
            WHEN x"12" => sboxInvValue := x"39"; WHEN x"13" => sboxInvValue := x"82"; 
            WHEN x"14" => sboxInvValue := x"9b"; WHEN x"15" => sboxInvValue := x"2f";
            WHEN x"16" => sboxInvValue := x"ff"; WHEN x"17" => sboxInvValue := x"87"; 
            WHEN x"18" => sboxInvValue := x"34"; WHEN x"19" => sboxInvValue := x"8e"; 
            WHEN x"1a" => sboxInvValue := x"43"; WHEN x"1b" => sboxInvValue := x"44"; 
            WHEN x"1c" => sboxInvValue := x"c4"; WHEN x"1d" => sboxInvValue := x"de"; 
			WHEN x"1e" => sboxInvValue := x"e9"; WHEN x"1f" => sboxInvValue := x"cb";
            
            WHEN x"20" => sboxInvValue := x"54"; WHEN x"21" => sboxInvValue := x"7b"; 
            WHEN x"22" => sboxInvValue := x"94"; WHEN x"23" => sboxInvValue := x"32"; 
            WHEN x"24" => sboxInvValue := x"a6"; WHEN x"25" => sboxInvValue := x"c2"; 
            WHEN x"26" => sboxInvValue := x"23"; WHEN x"27" => sboxInvValue := x"3d"; 
            WHEN x"28" => sboxInvValue := x"ee"; WHEN x"29" => sboxInvValue := x"4c"; 
            WHEN x"2a" => sboxInvValue := x"95"; WHEN x"2b" => sboxInvValue := x"0b"; 
            WHEN x"2c" => sboxInvValue := x"42"; WHEN x"2d" => sboxInvValue := x"fa"; 
            WHEN x"2e" => sboxInvValue := x"c3"; WHEN x"2f" => sboxInvValue := x"4e";
            
            WHEN x"30" => sboxInvValue := x"08"; WHEN x"31" => sboxInvValue := x"2e"; 
            WHEN x"32" => sboxInvValue := x"a1"; WHEN x"33" => sboxInvValue := x"66"; 
            WHEN x"34" => sboxInvValue := x"28"; WHEN x"35" => sboxInvValue := x"d9"; 
            WHEN x"36" => sboxInvValue := x"24"; WHEN x"37" => sboxInvValue := x"b2"; 
            WHEN x"38" => sboxInvValue := x"76"; WHEN x"39" => sboxInvValue := x"5b"; 
            WHEN x"3a" => sboxInvValue := x"a2"; WHEN x"3b" => sboxInvValue := x"49"; 
            WHEN x"3c" => sboxInvValue := x"6d"; WHEN x"3d" => sboxInvValue := x"8b"; 
            WHEN x"3e" => sboxInvValue := x"d1"; WHEN x"3f" => sboxInvValue := x"25";
            
            WHEN x"40" => sboxInvValue := x"72"; WHEN x"41" => sboxInvValue := x"f8"; 
            WHEN x"42" => sboxInvValue := x"f6"; WHEN x"43" => sboxInvValue := x"64"; 
            WHEN x"44" => sboxInvValue := x"86"; WHEN x"45" => sboxInvValue := x"68"; 
            WHEN x"46" => sboxInvValue := x"98"; WHEN x"47" => sboxInvValue := x"16"; 
            WHEN x"48" => sboxInvValue := x"d4"; WHEN x"49" => sboxInvValue := x"a4"; 
            WHEN x"4a" => sboxInvValue := x"5c"; WHEN x"4b" => sboxInvValue := x"cc"; 
            WHEN x"4c" => sboxInvValue := x"5d"; WHEN x"4d" => sboxInvValue := x"65"; 
            WHEN x"4e" => sboxInvValue := x"b6"; WHEN x"4f" => sboxInvValue := x"92"; 
            
            WHEN x"50" => sboxInvValue := x"6c"; WHEN x"51" => sboxInvValue := x"70"; 
            WHEN x"52" => sboxInvValue := x"48"; WHEN x"53" => sboxInvValue := x"50";
            WHEN x"54" => sboxInvValue := x"fd"; WHEN x"55" => sboxInvValue := x"ed"; 
            WHEN x"56" => sboxInvValue := x"b9"; WHEN x"57" => sboxInvValue := x"da"; 
            WHEN x"58" => sboxInvValue := x"5e"; WHEN x"59" => sboxInvValue := x"15"; 
            WHEN x"5a" => sboxInvValue := x"46"; WHEN x"5b" => sboxInvValue := x"57"; 
            WHEN x"5c" => sboxInvValue := x"a7"; WHEN x"5d" => sboxInvValue := x"8d"; 
            WHEN x"5e" => sboxInvValue := x"9d"; WHEN x"5f" => sboxInvValue := x"84";
            
            WHEN x"60" => sboxInvValue := x"90"; WHEN x"61" => sboxInvValue := x"d8"; 
            WHEN x"62" => sboxInvValue := x"ab"; WHEN x"63" => sboxInvValue := x"00"; 
            WHEN x"64" => sboxInvValue := x"8c"; WHEN x"65" => sboxInvValue := x"bc"; 
            WHEN x"66" => sboxInvValue := x"d3"; WHEN x"67" => sboxInvValue := x"0a"; 
            WHEN x"68" => sboxInvValue := x"f7"; WHEN x"69" => sboxInvValue := x"e4"; 
            WHEN x"6a" => sboxInvValue := x"58"; WHEN x"6b" => sboxInvValue := x"05"; 
            WHEN x"6c" => sboxInvValue := x"b8"; WHEN x"6d" => sboxInvValue := x"b3"; 
            WHEN x"6e" => sboxInvValue := x"45"; WHEN x"6f" => sboxInvValue := x"06"; 
            
            WHEN x"70" => sboxInvValue := x"d0"; WHEN x"71" => sboxInvValue := x"2c"; 
            WHEN x"72" => sboxInvValue := x"1e"; WHEN x"73" => sboxInvValue := x"8f"; 
            WHEN x"74" => sboxInvValue := x"ca"; WHEN x"75" => sboxInvValue := x"3f"; 
            WHEN x"76" => sboxInvValue := x"0f"; WHEN x"77" => sboxInvValue := x"02"; 
            WHEN x"78" => sboxInvValue := x"c1"; WHEN x"79" => sboxInvValue := x"af"; 
            WHEN x"7a" => sboxInvValue := x"bd"; WHEN x"7b" => sboxInvValue := x"03"; 
            WHEN x"7c" => sboxInvValue := x"01"; WHEN x"7d" => sboxInvValue := x"13"; 
            WHEN x"7e" => sboxInvValue := x"8a"; WHEN x"7f" => sboxInvValue := x"6b";
            
            WHEN x"80" => sboxInvValue := x"3a"; WHEN x"81" => sboxInvValue := x"91"; 
            WHEN x"82" => sboxInvValue := x"11"; WHEN x"83" => sboxInvValue := x"41"; 
            WHEN x"84" => sboxInvValue := x"4f"; WHEN x"85" => sboxInvValue := x"67"; 
            WHEN x"86" => sboxInvValue := x"dc"; WHEN x"87" => sboxInvValue := x"ea"; 
            WHEN x"88" => sboxInvValue := x"97"; WHEN x"89" => sboxInvValue := x"f2"; 
            WHEN x"8a" => sboxInvValue := x"cf"; WHEN x"8b" => sboxInvValue := x"ce"; 
            WHEN x"8c" => sboxInvValue := x"f0"; WHEN x"8d" => sboxInvValue := x"b4"; 
            WHEN x"8e" => sboxInvValue := x"e6"; WHEN x"8f" => sboxInvValue := x"73"; 
            
            WHEN x"90" => sboxInvValue := x"96"; WHEN x"91" => sboxInvValue := x"ac"; 
            WHEN x"92" => sboxInvValue := x"74"; WHEN x"93" => sboxInvValue := x"22"; 
            WHEN x"94" => sboxInvValue := x"e7"; WHEN x"95" => sboxInvValue := x"ad"; 
            WHEN x"96" => sboxInvValue := x"35"; WHEN x"97" => sboxInvValue := x"85"; 
            WHEN x"98" => sboxInvValue := x"e2"; WHEN x"99" => sboxInvValue := x"f9"; 
            WHEN x"9a" => sboxInvValue := x"37"; WHEN x"9b" => sboxInvValue := x"e8"; 
            WHEN x"9c" => sboxInvValue := x"1c"; WHEN x"9d" => sboxInvValue := x"75"; 
            WHEN x"9e" => sboxInvValue := x"df"; WHEN x"9f" => sboxInvValue := x"6e";
            
            WHEN x"a0" => sboxInvValue := x"47"; WHEN x"a1" => sboxInvValue := x"f1"; 
            WHEN x"a2" => sboxInvValue := x"1a"; WHEN x"a3" => sboxInvValue := x"71"; 
            WHEN x"a4" => sboxInvValue := x"1d"; WHEN x"a5" => sboxInvValue := x"29"; 
            WHEN x"a6" => sboxInvValue := x"c5"; WHEN x"a7" => sboxInvValue := x"89"; 
            WHEN x"a8" => sboxInvValue := x"6f"; WHEN x"a9" => sboxInvValue := x"b7"; 
            WHEN x"aa" => sboxInvValue := x"62"; WHEN x"ab" => sboxInvValue := x"0e"; 
            WHEN x"ac" => sboxInvValue := x"aa"; WHEN x"ad" => sboxInvValue := x"18"; 
            WHEN x"ae" => sboxInvValue := x"be"; WHEN x"af" => sboxInvValue := x"1b"; 
            
            WHEN x"b0" => sboxInvValue := x"fc"; WHEN x"b1" => sboxInvValue := x"56"; 
            WHEN x"b2" => sboxInvValue := x"3e"; WHEN x"b3" => sboxInvValue := x"4b"; 
            WHEN x"b4" => sboxInvValue := x"c6"; WHEN x"b5" => sboxInvValue := x"d2"; 
            WHEN x"b6" => sboxInvValue := x"79"; WHEN x"b7" => sboxInvValue := x"20"; 
            WHEN x"b8" => sboxInvValue := x"9a"; WHEN x"b9" => sboxInvValue := x"db"; 
            WHEN x"ba" => sboxInvValue := x"c0"; WHEN x"bb" => sboxInvValue := x"fe"; 
            WHEN x"bc" => sboxInvValue := x"78"; WHEN x"bd" => sboxInvValue := x"cd"; 
            WHEN x"be" => sboxInvValue := x"5a"; WHEN x"bf" => sboxInvValue := x"f4"; 
            
            WHEN x"c0" => sboxInvValue := x"1f"; WHEN x"c1" => sboxInvValue := x"dd"; 
            WHEN x"c2" => sboxInvValue := x"a8"; WHEN x"c3" => sboxInvValue := x"33"; 
            WHEN x"c4" => sboxInvValue := x"88"; WHEN x"c5" => sboxInvValue := x"07"; 
            WHEN x"c6" => sboxInvValue := x"c7"; WHEN x"c7" => sboxInvValue := x"31"; 
            WHEN x"c8" => sboxInvValue := x"b1"; WHEN x"c9" => sboxInvValue := x"12"; 
            WHEN x"ca" => sboxInvValue := x"10"; WHEN x"cb" => sboxInvValue := x"59"; 
            WHEN x"cc" => sboxInvValue := x"27"; WHEN x"cd" => sboxInvValue := x"80"; 
            WHEN x"ce" => sboxInvValue := x"ec"; WHEN x"cf" => sboxInvValue := x"5f";
            
            WHEN x"d0" => sboxInvValue := x"60"; WHEN x"d1" => sboxInvValue := x"51"; 
            WHEN x"d2" => sboxInvValue := x"7f"; WHEN x"d3" => sboxInvValue := x"a9"; 
            WHEN x"d4" => sboxInvValue := x"19"; WHEN x"d5" => sboxInvValue := x"b5"; 
            WHEN x"d6" => sboxInvValue := x"4a"; WHEN x"d7" => sboxInvValue := x"0d"; 
            WHEN x"d8" => sboxInvValue := x"2d"; WHEN x"d9" => sboxInvValue := x"e5"; 
            WHEN x"da" => sboxInvValue := x"7a"; WHEN x"db" => sboxInvValue := x"9f"; 
            WHEN x"dc" => sboxInvValue := x"93"; WHEN x"dd" => sboxInvValue := x"c9"; 
            WHEN x"de" => sboxInvValue := x"9c"; WHEN x"df" => sboxInvValue := x"ef";
            
            WHEN x"e0" => sboxInvValue := x"a0"; WHEN x"e1" => sboxInvValue := x"e0"; 
            WHEN x"e2" => sboxInvValue := x"3b"; WHEN x"e3" => sboxInvValue := x"4d"; 
            WHEN x"e4" => sboxInvValue := x"ae"; WHEN x"e5" => sboxInvValue := x"2a"; 
            WHEN x"e6" => sboxInvValue := x"f5"; WHEN x"e7" => sboxInvValue := x"b0"; 
            WHEN x"e8" => sboxInvValue := x"c8"; WHEN x"e9" => sboxInvValue := x"eb"; 
            WHEN x"ea" => sboxInvValue := x"bb"; WHEN x"eb" => sboxInvValue := x"3c"; 
            WHEN x"ec" => sboxInvValue := x"83"; WHEN x"ed" => sboxInvValue := x"53"; 
            WHEN x"ee" => sboxInvValue := x"99"; WHEN x"ef" => sboxInvValue := x"61"; 
            
            WHEN x"f0" => sboxInvValue := x"17"; WHEN x"f1" => sboxInvValue := x"2b"; 
            WHEN x"f2" => sboxInvValue := x"04"; WHEN x"f3" => sboxInvValue := x"7e"; 
            WHEN x"f4" => sboxInvValue := x"ba"; WHEN x"f5" => sboxInvValue := x"77"; 
            WHEN x"f6" => sboxInvValue := x"d6"; WHEN x"f7" => sboxInvValue := x"26"; 
            WHEN x"f8" => sboxInvValue := x"e1"; WHEN x"f9" => sboxInvValue := x"69"; 
            WHEN x"fa" => sboxInvValue := x"14"; WHEN x"fb" => sboxInvValue := x"63"; 
            WHEN x"fc" => sboxInvValue := x"55"; WHEN x"fd" => sboxInvValue := x"21"; 
            WHEN x"fe" => sboxInvValue := x"0c"; WHEN x"ff" => sboxInvValue := x"7d"; 
			
			WHEN OTHERS => null;
		end case;
		return sboxInvValue;
	end getSBOXInv;


FUNCTION getSBOX (data8:std_logic_vector(0 to 7)) RETURN std_logic_vector is	
	variable sboxValue	: std_logic_vector(0 to 7) := (others => '0');
	begin
		case data8 is
			WHEN x"00" => sboxValue := x"63"; WHEN x"01" => sboxValue := x"7c"; 
            WHEN x"02" => sboxValue := x"77"; WHEN x"03" => sboxValue := x"7b"; 
            WHEN x"04" => sboxValue := x"f2"; WHEN x"05" => sboxValue := x"6b"; 
            WHEN x"06" => sboxValue := x"6f"; WHEN x"07" => sboxValue := x"c5"; 
            WHEN x"08" => sboxValue := x"30"; WHEN x"09" => sboxValue := x"01"; 
            WHEN x"0a" => sboxValue := x"67"; WHEN x"0b" => sboxValue := x"2b"; 
            WHEN x"0c" => sboxValue := x"fe"; WHEN x"0d" => sboxValue := x"d7"; 
            WHEN x"0e" => sboxValue := x"ab"; WHEN x"0f" => sboxValue := x"76"; 
            
            WHEN x"10" => sboxValue := x"ca"; WHEN x"11" => sboxValue := x"82"; 
            WHEN x"12" => sboxValue := x"c9"; WHEN x"13" => sboxValue := x"7d"; 
            WHEN x"14" => sboxValue := x"fa"; WHEN x"15" => sboxValue := x"59";
            WHEN x"16" => sboxValue := x"47"; WHEN x"17" => sboxValue := x"f0"; 
            WHEN x"18" => sboxValue := x"ad"; WHEN x"19" => sboxValue := x"d4"; 
            WHEN x"1a" => sboxValue := x"a2"; WHEN x"1b" => sboxValue := x"af"; 
            WHEN x"1c" => sboxValue := x"9c"; WHEN x"1d" => sboxValue := x"a4"; 
            WHEN x"1e" => sboxValue := x"72"; WHEN x"1f" => sboxValue := x"c0";
            
            WHEN x"20" => sboxValue := x"b7"; WHEN x"21" => sboxValue := x"fd"; 
            WHEN x"22" => sboxValue := x"93"; WHEN x"23" => sboxValue := x"26"; 
            WHEN x"24" => sboxValue := x"36"; WHEN x"25" => sboxValue := x"3f"; 
            WHEN x"26" => sboxValue := x"f7"; WHEN x"27" => sboxValue := x"cc"; 
            WHEN x"28" => sboxValue := x"34"; WHEN x"29" => sboxValue := x"a5"; 
            WHEN x"2a" => sboxValue := x"e5"; WHEN x"2b" => sboxValue := x"f1"; 
            WHEN x"2c" => sboxValue := x"71"; WHEN x"2d" => sboxValue := x"d8"; 
            WHEN x"2e" => sboxValue := x"31"; WHEN x"2f" => sboxValue := x"15";
            
            WHEN x"30" => sboxValue := x"04"; WHEN x"31" => sboxValue := x"c7"; 
            WHEN x"32" => sboxValue := x"23"; WHEN x"33" => sboxValue := x"c3"; 
            WHEN x"34" => sboxValue := x"18"; WHEN x"35" => sboxValue := x"96"; 
            WHEN x"36" => sboxValue := x"05"; WHEN x"37" => sboxValue := x"9a"; 
            WHEN x"38" => sboxValue := x"07"; WHEN x"39" => sboxValue := x"12"; 
            WHEN x"3a" => sboxValue := x"80"; WHEN x"3b" => sboxValue := x"e2"; 
            WHEN x"3c" => sboxValue := x"eb"; WHEN x"3d" => sboxValue := x"27"; 
            WHEN x"3e" => sboxValue := x"b2"; WHEN x"3f" => sboxValue := x"75";
            
            WHEN x"40" => sboxValue := x"09"; WHEN x"41" => sboxValue := x"83"; 
            WHEN x"42" => sboxValue := x"2c"; WHEN x"43" => sboxValue := x"1a"; 
            WHEN x"44" => sboxValue := x"1b"; WHEN x"45" => sboxValue := x"6e"; 
            WHEN x"46" => sboxValue := x"5a"; WHEN x"47" => sboxValue := x"a0"; 
            WHEN x"48" => sboxValue := x"52"; WHEN x"49" => sboxValue := x"3b"; 
            WHEN x"4a" => sboxValue := x"d6"; WHEN x"4b" => sboxValue := x"b3"; 
            WHEN x"4c" => sboxValue := x"29"; WHEN x"4d" => sboxValue := x"e3"; 
            WHEN x"4e" => sboxValue := x"2f"; WHEN x"4f" => sboxValue := x"84"; 
            
            WHEN x"50" => sboxValue := x"53"; WHEN x"51" => sboxValue := x"d1"; 
            WHEN x"52" => sboxValue := x"00"; WHEN x"53" => sboxValue := x"ed";
            WHEN x"54" => sboxValue := x"20"; WHEN x"55" => sboxValue := x"fc"; 
            WHEN x"56" => sboxValue := x"b1"; WHEN x"57" => sboxValue := x"5b"; 
            WHEN x"58" => sboxValue := x"6a"; WHEN x"59" => sboxValue := x"cb"; 
            WHEN x"5a" => sboxValue := x"be"; WHEN x"5b" => sboxValue := x"39"; 
            WHEN x"5c" => sboxValue := x"4a"; WHEN x"5d" => sboxValue := x"4c"; 
            WHEN x"5e" => sboxValue := x"58"; WHEN x"5f" => sboxValue := x"cf";
            
            WHEN x"60" => sboxValue := x"d0"; WHEN x"61" => sboxValue := x"ef"; 
            WHEN x"62" => sboxValue := x"aa"; WHEN x"63" => sboxValue := x"fb"; 
            WHEN x"64" => sboxValue := x"43"; WHEN x"65" => sboxValue := x"4d"; 
            WHEN x"66" => sboxValue := x"33"; WHEN x"67" => sboxValue := x"85"; 
            WHEN x"68" => sboxValue := x"45"; WHEN x"69" => sboxValue := x"f9"; 
            WHEN x"6a" => sboxValue := x"02"; WHEN x"6b" => sboxValue := x"7f"; 
            WHEN x"6c" => sboxValue := x"50"; WHEN x"6d" => sboxValue := x"3c"; 
            WHEN x"6e" => sboxValue := x"9f"; WHEN x"6f" => sboxValue := x"a8"; 
            
            WHEN x"70" => sboxValue := x"51"; WHEN x"71" => sboxValue := x"a3"; 
            WHEN x"72" => sboxValue := x"40"; WHEN x"73" => sboxValue := x"8f"; 
            WHEN x"74" => sboxValue := x"92"; WHEN x"75" => sboxValue := x"9d"; 
            WHEN x"76" => sboxValue := x"38"; WHEN x"77" => sboxValue := x"f5"; 
            WHEN x"78" => sboxValue := x"bc"; WHEN x"79" => sboxValue := x"b6"; 
            WHEN x"7a" => sboxValue := x"da"; WHEN x"7b" => sboxValue := x"21"; 
            WHEN x"7c" => sboxValue := x"10"; WHEN x"7d" => sboxValue := x"ff"; 
            WHEN x"7e" => sboxValue := x"f3"; WHEN x"7f" => sboxValue := x"d2";
            
            WHEN x"80" => sboxValue := x"cd"; WHEN x"81" => sboxValue := x"0c"; 
            WHEN x"82" => sboxValue := x"13"; WHEN x"83" => sboxValue := x"ec"; 
            WHEN x"84" => sboxValue := x"5f"; WHEN x"85" => sboxValue := x"97"; 
            WHEN x"86" => sboxValue := x"44"; WHEN x"87" => sboxValue := x"17"; 
            WHEN x"88" => sboxValue := x"c4"; WHEN x"89" => sboxValue := x"a7"; 
            WHEN x"8a" => sboxValue := x"7e"; WHEN x"8b" => sboxValue := x"3d"; 
            WHEN x"8c" => sboxValue := x"64"; WHEN x"8d" => sboxValue := x"5d"; 
            WHEN x"8e" => sboxValue := x"19"; WHEN x"8f" => sboxValue := x"73"; 
            
            WHEN x"90" => sboxValue := x"60"; WHEN x"91" => sboxValue := x"81"; 
            WHEN x"92" => sboxValue := x"4f"; WHEN x"93" => sboxValue := x"dc"; 
            WHEN x"94" => sboxValue := x"22"; WHEN x"95" => sboxValue := x"2a"; 
            WHEN x"96" => sboxValue := x"90"; WHEN x"97" => sboxValue := x"88"; 
            WHEN x"98" => sboxValue := x"46"; WHEN x"99" => sboxValue := x"ee"; 
            WHEN x"9a" => sboxValue := x"b8"; WHEN x"9b" => sboxValue := x"14"; 
            WHEN x"9c" => sboxValue := x"de"; WHEN x"9d" => sboxValue := x"5e"; 
            WHEN x"9e" => sboxValue := x"0b"; WHEN x"9f" => sboxValue := x"db";
            
            WHEN x"a0" => sboxValue := x"e0"; WHEN x"a1" => sboxValue := x"32"; 
            WHEN x"a2" => sboxValue := x"3a"; WHEN x"a3" => sboxValue := x"0a"; 
            WHEN x"a4" => sboxValue := x"49"; WHEN x"a5" => sboxValue := x"06"; 
            WHEN x"a6" => sboxValue := x"24"; WHEN x"a7" => sboxValue := x"5c"; 
            WHEN x"a8" => sboxValue := x"c2"; WHEN x"a9" => sboxValue := x"d3"; 
            WHEN x"aa" => sboxValue := x"ac"; WHEN x"ab" => sboxValue := x"62"; 
            WHEN x"ac" => sboxValue := x"91"; WHEN x"ad" => sboxValue := x"95"; 
            WHEN x"ae" => sboxValue := x"e4"; WHEN x"af" => sboxValue := x"79"; 
            
            WHEN x"b0" => sboxValue := x"e7"; WHEN x"b1" => sboxValue := x"c8"; 
            WHEN x"b2" => sboxValue := x"37"; WHEN x"b3" => sboxValue := x"6d"; 
            WHEN x"b4" => sboxValue := x"8d"; WHEN x"b5" => sboxValue := x"d5"; 
            WHEN x"b6" => sboxValue := x"4e"; WHEN x"b7" => sboxValue := x"a9"; 
            WHEN x"b8" => sboxValue := x"6c"; WHEN x"b9" => sboxValue := x"56"; 
            WHEN x"ba" => sboxValue := x"f4"; WHEN x"bb" => sboxValue := x"ea"; 
            WHEN x"bc" => sboxValue := x"65"; WHEN x"bd" => sboxValue := x"7a"; 
            WHEN x"be" => sboxValue := x"ae"; WHEN x"bf" => sboxValue := x"08"; 
            
            WHEN x"c0" => sboxValue := x"ba"; WHEN x"c1" => sboxValue := x"78"; 
            WHEN x"c2" => sboxValue := x"25"; WHEN x"c3" => sboxValue := x"2e"; 
            WHEN x"c4" => sboxValue := x"1c"; WHEN x"c5" => sboxValue := x"a6"; 
            WHEN x"c6" => sboxValue := x"b4"; WHEN x"c7" => sboxValue := x"c6"; 
            WHEN x"c8" => sboxValue := x"e8"; WHEN x"c9" => sboxValue := x"dd"; 
            WHEN x"ca" => sboxValue := x"74"; WHEN x"cb" => sboxValue := x"1f"; 
            WHEN x"cc" => sboxValue := x"4b"; WHEN x"cd" => sboxValue := x"bd"; 
            WHEN x"ce" => sboxValue := x"8b"; WHEN x"cf" => sboxValue := x"8a";
            
            WHEN x"d0" => sboxValue := x"70"; WHEN x"d1" => sboxValue := x"3e"; 
            WHEN x"d2" => sboxValue := x"b5"; WHEN x"d3" => sboxValue := x"66"; 
            WHEN x"d4" => sboxValue := x"48"; WHEN x"d5" => sboxValue := x"03"; 
            WHEN x"d6" => sboxValue := x"f6"; WHEN x"d7" => sboxValue := x"0e"; 
            WHEN x"d8" => sboxValue := x"61"; WHEN x"d9" => sboxValue := x"35"; 
            WHEN x"da" => sboxValue := x"57"; WHEN x"db" => sboxValue := x"b9"; 
            WHEN x"dc" => sboxValue := x"86"; WHEN x"dd" => sboxValue := x"c1"; 
            WHEN x"de" => sboxValue := x"1d"; WHEN x"df" => sboxValue := x"9e";
            
            WHEN x"e0" => sboxValue := x"e1"; WHEN x"e1" => sboxValue := x"f8"; 
            WHEN x"e2" => sboxValue := x"98"; WHEN x"e3" => sboxValue := x"11"; 
            WHEN x"e4" => sboxValue := x"69"; WHEN x"e5" => sboxValue := x"d9"; 
            WHEN x"e6" => sboxValue := x"8e"; WHEN x"e7" => sboxValue := x"94"; 
            WHEN x"e8" => sboxValue := x"9b"; WHEN x"e9" => sboxValue := x"1e"; 
            WHEN x"ea" => sboxValue := x"87"; WHEN x"eb" => sboxValue := x"e9"; 
            WHEN x"ec" => sboxValue := x"ce"; WHEN x"ed" => sboxValue := x"55"; 
            WHEN x"ee" => sboxValue := x"28"; WHEN x"ef" => sboxValue := x"df"; 
            
            WHEN x"f0" => sboxValue := x"8c"; WHEN x"f1" => sboxValue := x"a1"; 
            WHEN x"f2" => sboxValue := x"89"; WHEN x"f3" => sboxValue := x"0d"; 
            WHEN x"f4" => sboxValue := x"bf"; WHEN x"f5" => sboxValue := x"e6"; 
            WHEN x"f6" => sboxValue := x"42"; WHEN x"f7" => sboxValue := x"68"; 
            WHEN x"f8" => sboxValue := x"41"; WHEN x"f9" => sboxValue := x"99"; 
            WHEN x"fa" => sboxValue := x"2d"; WHEN x"fb" => sboxValue := x"0f"; 
            WHEN x"fc" => sboxValue := x"b0"; WHEN x"fd" => sboxValue := x"54"; 
            WHEN x"fe" => sboxValue := x"bb"; WHEN x"ff" => sboxValue := x"16"; 
            
            WHEN others => null;
		end case;
		return sboxValue;
	end getSBOX;

FUNCTION InverseSubBytes ( data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector is
	variable result	: std_logic_vector(0 to 127) := (others => '0');
	begin
		result(0 to 7) := getSBOXInv(data128(0 to 7));
		result(8 to 15) := getSBOXInv(data128(8 to 15));
		result(16 to 23) := getSBOXInv(data128(16 to 23));
		result(24 to 31) := getSBOXInv(data128(24 to 31));
		
		result(32 to 39) := getSBOXInv(data128(32 to 39));
		result(40 to 47) := getSBOXInv(data128(40 to 47));
		result(48 to 55) := getSBOXInv(data128(48 to 55));
		result(56 to 63) := getSBOXInv(data128(56 to 63));
		
		result(64 to 71) := getSBOXInv(data128(64 to 71));
		result(72 to 79) := getSBOXInv(data128(72 to 79));
		result(80 to 87) := getSBOXInv(data128(80 to 87));
		result(88 to 95) := getSBOXInv(data128(88 to 95));
		
		result(96 to 103) := getSBOXInv(data128(96 to 103));
		result(104 to 111) := getSBOXInv(data128(104 to 111));
		result(112 to 119) := getSBOXInv(data128(112 to 119));
		result(120 to 127) := getSBOXInv(data128(120 to 127));
	
		return result;
	end InverseSubBytes;

FUNCTION InverseShiftRows ( data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector is
	variable result	: std_logic_vector(0 to 127) := (others => '0');
	begin
		
		result(0 to 7) := data128(0 to 7);
		result(8 to 15) := data128(104 to 111);
		result(16 to 23) := data128(80 to 87);
		result(24 to 31) := data128(56 to 63);
		
		result(32 to 39) := data128(32 to 39);
		result(40 to 47) := data128(8 to 15);
		result(48 to 55) := data128(112 to 119);
		result(56 to 63) := data128(88 to 95);
		
		result(64 to 71) := data128(64 to 71);
		result(72 to 79) := data128(40 to 47);
		result(80 to 87) := data128(16 to 23);
		result(88 to 95) := data128(120 to 127);
		
		result(96 to 103) := data128(96 to 103);
		result(104 to 111) := data128(72 to 79);
		result(112 to 119) := data128(48 to 55);
		result(120 to 127) := data128(24 to 31);
		
		
		return result;
	end InverseShiftRows;

FUNCTION InverseMixColumns ( data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector is
		variable b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15: std_logic_vector(0 to 7);
		variable temp: std_logic_vector(0 to 127);  
	BEGIN 
		b0 := data128( 0 TO 7 );     b8  := data128( 64 TO 71 ); 
        b1 := data128( 8 TO 15 );    b9  := data128( 72 TO 79 ); 
        b2 := data128( 16 TO 23 );   b10 := data128( 80 TO 87 );
        b3 := data128( 24 TO 31 );   b11 := data128( 88 TO 95 );
        b4 := data128( 32 TO 39 );   b12 := data128( 96 TO 103 ); 
        b5 := data128( 40 TO 47 );   b13 := data128( 104 TO 111 ); 
        b6 := data128( 48 TO 55 );   b14 := data128( 112 TO 119 ); 	
        b7 := data128( 56 TO 63 );   b15 := data128( 120 TO 127 );
		
		--First Column 	 
    	temp( 0 TO 7 )  := mult(x"0E", b0) XOR mult(x"0B", b1) XOR mult(x"0D", b2) XOR mult(x"09", b3);
		temp( 8 TO 15 ) := mult(x"09", b0) XOR mult(x"0E", b1) XOR mult(x"0B", b2) XOR mult(x"0D", b3);
		temp( 16 TO 23 ) := mult(x"0D", b0) XOR mult(x"09", b1) XOR mult(x"0E", b2) XOR mult(x"0B", b3);
		temp( 24 TO 31 ) := mult(x"0B", b0) XOR mult(x"0D", b1) XOR mult(x"09", b2) XOR mult(x"0E", b3);
		
		--Second Column
		temp( 32 TO 39 ) := mult(x"0E", b4) XOR mult(x"0B", b5) XOR mult(x"0D", b6) XOR mult(x"09", b7);
		temp( 40 TO 47 ) := mult(x"09", b4) XOR mult(x"0E", b5) XOR mult(x"0B", b6) XOR mult(x"0D", b7);
		temp( 48 TO 55 ) := mult(x"0D", b4) XOR mult(x"09", b5) XOR mult(x"0E", b6) XOR mult(x"0B", b7);
		temp( 56 TO 63 ) := mult(x"0B", b4) XOR mult(x"0D", b5) XOR mult(x"09", b6) XOR mult(x"0E", b7);
		
		--Third Column
		temp( 64 TO 71 ) := mult(x"0E", b8) XOR mult(x"0B", b9) XOR mult(x"0D", b10) XOR mult(x"09", b11);
		temp( 72 TO 79 ) := mult(x"09", b8) XOR mult(x"0E", b9) XOR mult(x"0B", b10) XOR mult(x"0D", b11);
		temp( 80 TO 87 ) := mult(x"0D", b8) XOR mult(x"09", b9) XOR mult(x"0E", b10) XOR mult(x"0B", b11);
		temp( 88 TO 95 ) := mult(x"0B", b8) XOR mult(x"0D", b9) XOR mult(x"09", b10) XOR mult(x"0E", b11);		

		--Fourth Column
		temp( 96 TO 103 )  := mult(x"0E", b12) XOR mult(x"0B", b13) XOR mult(x"0D", b14) XOR mult(x"09", b15);
		temp( 104 TO 111 ) := mult(x"09", b12) XOR mult(x"0E", b13) XOR mult(x"0B", b14) XOR mult(x"0D", b15);
		temp( 112 TO 119 ) := mult(x"0D", b12) XOR mult(x"09", b13) XOR mult(x"0E", b14) XOR mult(x"0B", b15);
		temp( 120 TO 127 ) := mult(x"0B", b12) XOR mult(x"0D", b13) XOR mult(x"09", b14) XOR mult(x"0E", b15);
		
    return temp; 
    END FUNCTION InverseMixColumns;
	
FUNCTION mult ( a: std_logic_vector(0 to 7); b: std_logic_vector(0 to 7) ) RETURN std_logic_vector IS
	type MultiplyLUT is array(0 to 255) of std_logic_vector(0 to 7);
	
	constant mult9 : MultiplyLUT :=
	(	x"00",x"09",x"12",x"1b",x"24",x"2d",x"36",x"3f",x"48",x"41",x"5a",x"53",x"6c",x"65",x"7e",x"77",
		x"90",x"99",x"82",x"8b",x"b4",x"bd",x"a6",x"af",x"d8",x"d1",x"ca",x"c3",x"fc",x"f5",x"ee",x"e7",
		x"3b",x"32",x"29",x"20",x"1f",x"16",x"0d",x"04",x"73",x"7a",x"61",x"68",x"57",x"5e",x"45",x"4c",
		x"ab",x"a2",x"b9",x"b0",x"8f",x"86",x"9d",x"94",x"e3",x"ea",x"f1",x"f8",x"c7",x"ce",x"d5",x"dc",
		x"76",x"7f",x"64",x"6d",x"52",x"5b",x"40",x"49",x"3e",x"37",x"2c",x"25",x"1a",x"13",x"08",x"01",
		x"e6",x"ef",x"f4",x"fd",x"c2",x"cb",x"d0",x"d9",x"ae",x"a7",x"bc",x"b5",x"8a",x"83",x"98",x"91",
		x"4d",x"44",x"5f",x"56",x"69",x"60",x"7b",x"72",x"05",x"0c",x"17",x"1e",x"21",x"28",x"33",x"3a",
		x"dd",x"d4",x"cf",x"c6",x"f9",x"f0",x"eb",x"e2",x"95",x"9c",x"87",x"8e",x"b1",x"b8",x"a3",x"aa",
		x"ec",x"e5",x"fe",x"f7",x"c8",x"c1",x"da",x"d3",x"a4",x"ad",x"b6",x"bf",x"80",x"89",x"92",x"9b",
		x"7c",x"75",x"6e",x"67",x"58",x"51",x"4a",x"43",x"34",x"3d",x"26",x"2f",x"10",x"19",x"02",x"0b",
		x"d7",x"de",x"c5",x"cc",x"f3",x"fa",x"e1",x"e8",x"9f",x"96",x"8d",x"84",x"bb",x"b2",x"a9",x"a0",
		x"47",x"4e",x"55",x"5c",x"63",x"6a",x"71",x"78",x"0f",x"06",x"1d",x"14",x"2b",x"22",x"39",x"30",
		x"9a",x"93",x"88",x"81",x"be",x"b7",x"ac",x"a5",x"d2",x"db",x"c0",x"c9",x"f6",x"ff",x"e4",x"ed",
		x"0a",x"03",x"18",x"11",x"2e",x"27",x"3c",x"35",x"42",x"4b",x"50",x"59",x"66",x"6f",x"74",x"7d",
		x"a1",x"a8",x"b3",x"ba",x"85",x"8c",x"97",x"9e",x"e9",x"e0",x"fb",x"f2",x"cd",x"c4",x"df",x"d6",
		x"31",x"38",x"23",x"2a",x"15",x"1c",x"07",x"0e",x"79",x"70",x"6b",x"62",x"5d",x"54",x"4f",x"46", others => (others => '0')); 

	constant mult11 : MultiplyLUT :=
	(	x"00",x"0b",x"16",x"1d",x"2c",x"27",x"3a",x"31",x"58",x"53",x"4e",x"45",x"74",x"7f",x"62",x"69",
		x"b0",x"bb",x"a6",x"ad",x"9c",x"97",x"8a",x"81",x"e8",x"e3",x"fe",x"f5",x"c4",x"cf",x"d2",x"d9",
		x"7b",x"70",x"6d",x"66",x"57",x"5c",x"41",x"4a",x"23",x"28",x"35",x"3e",x"0f",x"04",x"19",x"12",
		x"cb",x"c0",x"dd",x"d6",x"e7",x"ec",x"f1",x"fa",x"93",x"98",x"85",x"8e",x"bf",x"b4",x"a9",x"a2",
		x"f6",x"fd",x"e0",x"eb",x"da",x"d1",x"cc",x"c7",x"ae",x"a5",x"b8",x"b3",x"82",x"89",x"94",x"9f",
		x"46",x"4d",x"50",x"5b",x"6a",x"61",x"7c",x"77",x"1e",x"15",x"08",x"03",x"32",x"39",x"24",x"2f",
		x"8d",x"86",x"9b",x"90",x"a1",x"aa",x"b7",x"bc",x"d5",x"de",x"c3",x"c8",x"f9",x"f2",x"ef",x"e4",
		x"3d",x"36",x"2b",x"20",x"11",x"1a",x"07",x"0c",x"65",x"6e",x"73",x"78",x"49",x"42",x"5f",x"54",
		x"f7",x"fc",x"e1",x"ea",x"db",x"d0",x"cd",x"c6",x"af",x"a4",x"b9",x"b2",x"83",x"88",x"95",x"9e",
		x"47",x"4c",x"51",x"5a",x"6b",x"60",x"7d",x"76",x"1f",x"14",x"09",x"02",x"33",x"38",x"25",x"2e",
		x"8c",x"87",x"9a",x"91",x"a0",x"ab",x"b6",x"bd",x"d4",x"df",x"c2",x"c9",x"f8",x"f3",x"ee",x"e5",
		x"3c",x"37",x"2a",x"21",x"10",x"1b",x"06",x"0d",x"64",x"6f",x"72",x"79",x"48",x"43",x"5e",x"55",
		x"01",x"0a",x"17",x"1c",x"2d",x"26",x"3b",x"30",x"59",x"52",x"4f",x"44",x"75",x"7e",x"63",x"68",
		x"b1",x"ba",x"a7",x"ac",x"9d",x"96",x"8b",x"80",x"e9",x"e2",x"ff",x"f4",x"c5",x"ce",x"d3",x"d8",
		x"7a",x"71",x"6c",x"67",x"56",x"5d",x"40",x"4b",x"22",x"29",x"34",x"3f",x"0e",x"05",x"18",x"13",
		x"ca",x"c1",x"dc",x"d7",x"e6",x"ed",x"f0",x"fb",x"92",x"99",x"84",x"8f",x"be",x"b5",x"a8",x"a3", others => (others => '0')); 

	constant mult13 : MultiplyLUT :=	
	(	x"00",x"0d",x"1a",x"17",x"34",x"39",x"2e",x"23",x"68",x"65",x"72",x"7f",x"5c",x"51",x"46",x"4b",
		x"d0",x"dd",x"ca",x"c7",x"e4",x"e9",x"fe",x"f3",x"b8",x"b5",x"a2",x"af",x"8c",x"81",x"96",x"9b",
		x"bb",x"b6",x"a1",x"ac",x"8f",x"82",x"95",x"98",x"d3",x"de",x"c9",x"c4",x"e7",x"ea",x"fd",x"f0",
		x"6b",x"66",x"71",x"7c",x"5f",x"52",x"45",x"48",x"03",x"0e",x"19",x"14",x"37",x"3a",x"2d",x"20",
		x"6d",x"60",x"77",x"7a",x"59",x"54",x"43",x"4e",x"05",x"08",x"1f",x"12",x"31",x"3c",x"2b",x"26",
		x"bd",x"b0",x"a7",x"aa",x"89",x"84",x"93",x"9e",x"d5",x"d8",x"cf",x"c2",x"e1",x"ec",x"fb",x"f6",
		x"d6",x"db",x"cc",x"c1",x"e2",x"ef",x"f8",x"f5",x"be",x"b3",x"a4",x"a9",x"8a",x"87",x"90",x"9d",
		x"06",x"0b",x"1c",x"11",x"32",x"3f",x"28",x"25",x"6e",x"63",x"74",x"79",x"5a",x"57",x"40",x"4d",
		x"da",x"d7",x"c0",x"cd",x"ee",x"e3",x"f4",x"f9",x"b2",x"bf",x"a8",x"a5",x"86",x"8b",x"9c",x"91",
		x"0a",x"07",x"10",x"1d",x"3e",x"33",x"24",x"29",x"62",x"6f",x"78",x"75",x"56",x"5b",x"4c",x"41",
		x"61",x"6c",x"7b",x"76",x"55",x"58",x"4f",x"42",x"09",x"04",x"13",x"1e",x"3d",x"30",x"27",x"2a",
		x"b1",x"bc",x"ab",x"a6",x"85",x"88",x"9f",x"92",x"d9",x"d4",x"c3",x"ce",x"ed",x"e0",x"f7",x"fa",
		x"b7",x"ba",x"ad",x"a0",x"83",x"8e",x"99",x"94",x"df",x"d2",x"c5",x"c8",x"eb",x"e6",x"f1",x"fc",
		x"67",x"6a",x"7d",x"70",x"53",x"5e",x"49",x"44",x"0f",x"02",x"15",x"18",x"3b",x"36",x"21",x"2c",
		x"0c",x"01",x"16",x"1b",x"38",x"35",x"22",x"2f",x"64",x"69",x"7e",x"73",x"50",x"5d",x"4a",x"47",
		x"dc",x"d1",x"c6",x"cb",x"e8",x"e5",x"f2",x"ff",x"b4",x"b9",x"ae",x"a3",x"80",x"8d",x"9a",x"97", others => (others => '0')); 

	constant mult14 : MultiplyLUT :=	
	(	x"00",x"0e",x"1c",x"12",x"38",x"36",x"24",x"2a",x"70",x"7e",x"6c",x"62",x"48",x"46",x"54",x"5a",
		x"e0",x"ee",x"fc",x"f2",x"d8",x"d6",x"c4",x"ca",x"90",x"9e",x"8c",x"82",x"a8",x"a6",x"b4",x"ba",
		x"db",x"d5",x"c7",x"c9",x"e3",x"ed",x"ff",x"f1",x"ab",x"a5",x"b7",x"b9",x"93",x"9d",x"8f",x"81",
		x"3b",x"35",x"27",x"29",x"03",x"0d",x"1f",x"11",x"4b",x"45",x"57",x"59",x"73",x"7d",x"6f",x"61",
		x"ad",x"a3",x"b1",x"bf",x"95",x"9b",x"89",x"87",x"dd",x"d3",x"c1",x"cf",x"e5",x"eb",x"f9",x"f7",
		x"4d",x"43",x"51",x"5f",x"75",x"7b",x"69",x"67",x"3d",x"33",x"21",x"2f",x"05",x"0b",x"19",x"17",
		x"76",x"78",x"6a",x"64",x"4e",x"40",x"52",x"5c",x"06",x"08",x"1a",x"14",x"3e",x"30",x"22",x"2c",
		x"96",x"98",x"8a",x"84",x"ae",x"a0",x"b2",x"bc",x"e6",x"e8",x"fa",x"f4",x"de",x"d0",x"c2",x"cc",
		x"41",x"4f",x"5d",x"53",x"79",x"77",x"65",x"6b",x"31",x"3f",x"2d",x"23",x"09",x"07",x"15",x"1b",
		x"a1",x"af",x"bd",x"b3",x"99",x"97",x"85",x"8b",x"d1",x"df",x"cd",x"c3",x"e9",x"e7",x"f5",x"fb",
		x"9a",x"94",x"86",x"88",x"a2",x"ac",x"be",x"b0",x"ea",x"e4",x"f6",x"f8",x"d2",x"dc",x"ce",x"c0",
		x"7a",x"74",x"66",x"68",x"42",x"4c",x"5e",x"50",x"0a",x"04",x"16",x"18",x"32",x"3c",x"2e",x"20",
		x"ec",x"e2",x"f0",x"fe",x"d4",x"da",x"c8",x"c6",x"9c",x"92",x"80",x"8e",x"a4",x"aa",x"b8",x"b6",
		x"0c",x"02",x"10",x"1e",x"34",x"3a",x"28",x"26",x"7c",x"72",x"60",x"6e",x"44",x"4a",x"58",x"56",
		x"37",x"39",x"2b",x"25",x"0f",x"01",x"13",x"1d",x"47",x"49",x"5b",x"55",x"7f",x"71",x"63",x"6d",
		x"d7",x"d9",x"cb",x"c5",x"ef",x"e1",x"f3",x"fd",x"a7",x"a9",x"bb",x"b5",x"9f",x"91",x"83",x"8d", others => (others => '0')); 
	
		variable temp: std_logic_vector(0 to 7) := (others => '0');
		--VARIABLE temp : std_logic_vector(0 to 7);
		--VARIABLE and_mask : std_logic_vector(0 to 7); 
		--VARIABLE temp : std_logic_vector(0 to 7);
		--VARIABLE temp1 : std_logic_vector(0 to 7);
		--VARIABLE temp2 : std_logic_vector(0 to 7);
		--VARIABLE and_mask : std_logic_vector(0 to 7);
    BEGIN 
		case a is
			when x"09" =>
				temp := mult9(conv_integer(b));
			when x"0B" =>
				temp := mult11(conv_integer(b));
			when x"0D" =>
				temp := mult13(conv_integer(b));
			when x"0E" =>
				temp := mult14(conv_integer(b));
			when others =>
				temp := x"00";
		end case;
	   return temp;
	   
    END FUNCTION mult;		
	
FUNCTION AddRoundKey ( RoundKey128: std_logic_vector(0 to 127); data128: std_logic_vector(0 to 127) ) RETURN std_logic_vector is
	variable result	: std_logic_vector(0 to 127) := (others => '0');
	begin
		result := data128 xor RoundKey128;
	return result;
	end AddRoundKey;
	
	

	
END aes_package;