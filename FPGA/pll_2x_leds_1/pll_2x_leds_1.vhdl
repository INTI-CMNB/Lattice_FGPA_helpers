------------------------------------------------------------------------------
----                                                                      ----
----  iCE40 PLL examples                                                  ----
----                                                                      ----
----  Description:                                                        ----
----  This is an example of use for the iCE40 PLLs.                       ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2016 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2016 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      PLL_2x_LEDs_1(TopLevel) (Entity and architecture)  ----
---- File name:        pll_2x_leds_1.vhdl                                 ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
----                   lattice.components                                 ----
---- Target FPGA:      iCE40HX4K-TQ144                                    ----
---- Language:         VHDL                                               ----
---- Wishbone:         None                                               ----
---- Synthesis tools:  Lattice iCECube2 2016.02.27810                     ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library lattice;
use lattice.components.all;

entity PLL_2x_LEDs_1 is
   port(
      CLK  : in  std_logic;
      LED1 : out std_logic;
      LED2 : out std_logic;
      LED3 : out std_logic;
      LED4 : out std_logic);
end entity PLL_2x_LEDs_1;

architecture TopLevel of PLL_2x_LEDs_1 is
   -- 3 casos:
   -- 1) Para probar el PLL generando 2 frecuencias: 48 y la mitad => PLL_2F=true
   -- 2) Para probar el PLL generando 1 frecuencia: 48, pero manteniendo la de 24 => PLL_2=true
   -- 3) Usar la frecuencia original para medirla => ambos false
   constant PLL_2F : boolean:=false;
   constant PLL_2  : boolean:=true;
   signal clk_core_A : std_logic; -- Clock A (to logic)
   signal clk_glob_A : std_logic; -- Clock A (to global lines)
   signal clk_core_B : std_logic; -- Clock B (to logic)
   signal clk_glob_B : std_logic; -- Clock B (to global lines)
   signal pll_lock   : std_logic; -- PLL is locked
   signal nrst       : std_logic; -- /Reset
   signal rst        : std_logic; -- Reset
   signal cnt_a      : unsigned(25 downto 0):=(others => '0');
   signal cnt_b      : unsigned(25 downto 0):=(others => '0');
   signal cnt_c      : unsigned(25 downto 0):=(others => '0');
   signal led_1_r    : std_logic:='0';
   signal led_2_r    : std_logic:='0';
   signal led_3_r    : std_logic:='0';
begin
   nrst <= '1';
   rst  <= not(nrst);

   with_pll:
   if PLL_2F generate
      -- *************************************************************************
      -- PLL: 48 MHz clock from 24 MHz clock
      -- *************************************************************************
      PLL1 : SB_PLL40_2F_PAD -- entity lattice.SB_PLL40_2_PAD
         generic map(
            --- Feedback (all defaults)
            FEEDBACK_PATH => "SIMPLE",
            DELAY_ADJUSTMENT_MODE_FEEDBACK => "FIXED",
            -- DELAY_ADJUSTMENT_MODE_RELATIVE => "FIXED",
            SHIFTREG_DIV_MODE => "00",  --  0 --> Divide by 4, 1 --> Divide by 7, 3 --> Divide by 5
            FDA_FEEDBACK => "0000",
            -- FDA_RELATIVE => "0000",
            PLLOUT_SELECT_PORTA => "GENCLK",
            PLLOUT_SELECT_PORTB => "GENCLK_HALF",
            -- Freq. Multiplier (DIVF+1)/((2**DIVQ)*(DIVR+1))=32/16=2
            DIVF => "0011111", -- 31
            DIVR => "0000",
            DIVQ => "100", -- 4
            FILTER_RANGE => "010", -- Not documented!
            --- Output clock gates (for low power modes)
            ENABLE_ICEGATE_PORTA => '0',
            ENABLE_ICEGATE_PORTB => '0'
            --- Test Mode Parameter
            -- TEST_MODE => '0',
            -- EXTERNAL_DIVIDE_FACTOR => 1 -- Not Used by model, Added for PLL config GUI
            )
         port map(
            PACKAGEPIN    => CLK,        -- Clock pin from GBx
            PLLOUTCOREA   => clk_core_A, -- Clock A (to logic)
            PLLOUTGLOBALA => clk_glob_A, -- Clock A (to global lines)
            PLLOUTCOREB   => clk_core_B, -- Clock B (to logic)
            PLLOUTGLOBALB => clk_glob_B, -- Clock B (to global lines)
            EXTFEEDBACK   => open,       -- External feedback (not used here)
            DYNAMICDELAY  => open,       -- Dynamic delay (not used here)
            LOCK          => pll_lock,   -- PLL is locked
            BYPASS        => '0',        -- Bypass enable
            RESETB        => nrst,       -- /Reset
            LATCHINPUTVALUE => open,     -- Clock gate enable
            -- Test Pins (not documented)
            SDO => open, SDI => open, SCLK => open);
   end generate with_pll;

   with_pll_b:
   if PLL_2 generate
      -- *************************************************************************
      -- PLL: 48 MHz clock from 24 MHz clock
      -- *************************************************************************
      PLL1 : SB_PLL40_2_PAD
         generic map(
            --- Feedback (all defaults)
            FEEDBACK_PATH => "SIMPLE",
            DELAY_ADJUSTMENT_MODE_FEEDBACK => "FIXED",
            -- DELAY_ADJUSTMENT_MODE_RELATIVE => "FIXED",
            SHIFTREG_DIV_MODE => "00",  --  0 --> Divide by 4, 1 --> Divide by 7, 3 --> Divide by 5
            FDA_FEEDBACK => "0000",
            -- FDA_RELATIVE => "0000",
            PLLOUT_SELECT_PORTB => "GENCLK",
            -- Freq. Multiplier (DIVF+1)/((2**DIVQ)*(DIVR+1))=32/16=2
            DIVF => "0011111", -- 31
            DIVR => "0000",
            DIVQ => "100", -- 4
            FILTER_RANGE => "010", -- Not documented!
            --- Output clock gates (for low power modes)
            ENABLE_ICEGATE_PORTA => '0',
            ENABLE_ICEGATE_PORTB => '0'
            --- Test Mode Parameter
            -- TEST_MODE => '0',
            -- EXTERNAL_DIVIDE_FACTOR => 1 -- Not Used by model, Added for PLL config GUI
            )
         port map(
            PACKAGEPIN    => CLK,        -- Clock pin from GBx
            PLLOUTCOREA   => clk_core_A,  -- Clock A (to logic)
            PLLOUTGLOBALA => clk_glob_A, -- Clock A (to global lines)
            PLLOUTCOREB   => clk_core_B, -- Clock B (to logic)
            PLLOUTGLOBALB => clk_glob_B, -- Clock B (to global lines)
            EXTFEEDBACK   => open,       -- External feedback (not used here)
            DYNAMICDELAY  => open,       -- Dynamic delay (not used here)
            LOCK          => pll_lock,   -- PLL is locked
            BYPASS        => '0',        -- Bypass enable
            RESETB        => nrst,       -- /Reset
            LATCHINPUTVALUE => open,     -- Clock gate enable
            -- Test Pins (not documented)
            SDO => open, SDI => open, SCLK => open);
   end generate with_pll_b;

   without_pll:
   if not(PLL_2F or PLL_2) generate
      clk_glob_A <= CLK;
      clk_glob_B <= CLK;
      pll_lock    <= '1';
   end generate without_pll;

   -- LED1
--    do_led_1:
--    process (CLK)
--    begin
--       if rising_edge(CLK) then
--          if rst='1' then
--             cnt_a <= (others => '0');
--             led_1_r <= '0';
--          else
--             cnt_a <= cnt_a+1;
--             if cnt_a=24e6 then
--                cnt_a <= (others => '0');
--                led_1_r <= not(led_1_r);
--             end if;
--          end if;
--       end if;
--    end process do_led_1;
   LED1 <= pll_lock;
   -- LED2
   do_led_2:
   process (clk_glob_A)
   begin
      if rising_edge(clk_glob_A) then
         if rst='1' then
            cnt_b <= (others => '0');
            led_2_r <= '0';
         else
            cnt_b <= cnt_b+1;
            if cnt_b=24e6 then
               cnt_b <= (others => '0');
               led_2_r <= not(led_2_r);
            end if;
         end if;
      end if;
   end process do_led_2;
   LED2 <= led_2_r;
   -- LED3
   do_led_3:
   process (clk_glob_B)
   begin
      if rising_edge(clk_glob_B) then
         if rst='1' then
            cnt_c <= (others => '0');
            led_3_r <= '0';
         else
            cnt_c <= cnt_c+1;
            if cnt_c=24e6 then
               cnt_c <= (others => '0');
               led_3_r <= not(led_3_r);
            end if;
         end if;
      end if;
   end process do_led_3;
   LED3 <= led_3_r;
   LED4 <= rst;
end architecture TopLevel; -- Entity: PLL_2x_LEDs_1
