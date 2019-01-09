function [p_below_0, p_above_0] = fit_tc(poly_order)
%
% Thermocouple polynomial fitting
% 
x = tc_table;
n=find(x(:,3)<=0);                              % fit the below-zero
p_below_0 = polyfit(x(n,3),x(n,1),poly_order);  % polynomial
n = find(x(:,3)>=0);                            % fit the above-zero
p_above_0 = polyfit(x(n,3),x(n,1),poly_order);  % polynomial



function x = tc_table

    x = [ ...
          -40.0000     -40.0000         -2.2550 ; ...
          -39.4444     -39.0000         -2.2250 ; ...
          -38.8889     -38.0000         -2.1950 ; ...
          -38.3333     -37.0000         -2.1650 ; ...
          -37.7778     -36.0000         -2.1350 ; ...
          -37.2222     -35.0000         -2.1050 ; ...
          -36.6667     -34.0000         -2.0740 ; ...
          -36.1111     -33.0000         -2.0440 ; ...
          -35.5556     -32.0000         -2.0140 ; ...
          -35.0000     -31.0000         -1.9840 ; ...
          -34.4444     -30.0000         -1.9530 ; ...
          -33.8889     -29.0000         -1.9230 ; ...
          -33.3333     -28.0000         -1.8930 ; ...
          -32.7778     -27.0000         -1.8620 ; ...
          -32.2222     -26.0000         -1.8320 ; ...
          -31.6667     -25.0000         -1.8010 ; ...
          -31.1111     -24.0000         -1.7710 ; ...
          -30.5556     -23.0000         -1.7400 ; ...
          -30.0000     -22.0000         -1.7090 ; ...
          -29.4444     -21.0000         -1.6790 ; ...
          -28.8889     -20.0000         -1.6480 ; ...
          -28.3333     -19.0000         -1.6170 ; ...
          -27.7778     -18.0000         -1.5870 ; ...
          -27.2222     -17.0000         -1.5560 ; ...
          -26.6667     -16.0000         -1.5250 ; ...
          -26.1111     -15.0000         -1.4940 ; ...
          -25.5556     -14.0000         -1.4630 ; ...
          -25.0000     -13.0000         -1.4320 ; ...
          -24.4444     -12.0000         -1.4010 ; ...
          -23.8889     -11.0000         -1.3700 ; ...
          -23.3333     -10.0000         -1.3390 ; ...
          -22.7778      -9.0000         -1.3080 ; ...
          -22.2222      -8.0000         -1.2770 ; ...
          -21.6667      -7.0000         -1.2450 ; ...
          -21.1111      -6.0000         -1.2140 ; ...
          -20.5556      -5.0000         -1.1830 ; ...
          -20.0000      -4.0000         -1.1520 ; ...
          -19.4444      -3.0000         -1.1200 ; ...
          -18.8889      -2.0000         -1.0890 ; ...
          -18.3333      -1.0000         -1.0570 ; ...
          -17.7778       0.0000         -1.0260 ; ...
          -17.2222       1.0000         -0.9940 ; ...
          -16.6667       2.0000         -0.9630 ; ...
          -16.1111       3.0000         -0.9310 ; ...
          -15.5556       4.0000         -0.9000 ; ...
          -15.0000       5.0000         -0.8680 ; ...
          -14.4444       6.0000         -0.8360 ; ...
          -13.8889       7.0000         -0.8050 ; ...
          -13.3333       8.0000         -0.7730 ; ...
          -12.7778       9.0000         -0.7410 ; ...
          -12.2222      10.0000         -0.7090 ; ...
          -11.6667      11.0000         -0.6770 ; ...
          -11.1111      12.0000         -0.6450 ; ...
          -10.5556      13.0000         -0.6140 ; ...
          -10.0000      14.0000         -0.5820 ; ...
           -9.4444      15.0000         -0.5500 ; ...
           -8.8889      16.0000         -0.5170 ; ...
           -8.3333      17.0000         -0.4850 ; ...
           -7.7778      18.0000         -0.4530 ; ...
           -7.2222      19.0000         -0.4210 ; ...
           -6.6667      20.0000         -0.3890 ; ...
           -6.1111      21.0000         -0.3570 ; ...
           -5.5556      22.0000         -0.3240 ; ...
           -5.0000      23.0000         -0.2920 ; ...
           -4.4444      24.0000         -0.2600 ; ...
           -3.8889      25.0000         -0.2270 ; ...
           -3.3333      26.0000         -0.1950 ; ...
           -2.7778      27.0000         -0.1630 ; ...
           -2.2222      28.0000         -0.1300 ; ...
           -1.6667      29.0000         -0.0980 ; ...
           -1.1111      30.0000         -0.0650 ; ...
           -0.5556      31.0000         -0.0330 ; ...
            0.0000      32.0000          0.0000 ; ...
            0.5556      33.0000          0.0330 ; ...
            1.1111      34.0000          0.0650 ; ...
            1.6667      35.0000          0.0980 ; ...
            2.2222      36.0000          0.1310 ; ...
            2.7778      37.0000          0.1630 ; ...
            3.3333      38.0000          0.1960 ; ...
            3.8889      39.0000          0.2290 ; ...
            4.4444      40.0000          0.2620 ; ...
            5.0000      41.0000          0.2940 ; ...
            5.5556      42.0000          0.3270 ; ...
            6.1111      43.0000          0.3600 ; ...
            6.6667      44.0000          0.3930 ; ...
            7.2222      45.0000          0.4260 ; ...
            7.7778      46.0000          0.4590 ; ...
            8.3333      47.0000          0.4920 ; ...
            8.8889      48.0000          0.5250 ; ...
            9.4444      49.0000          0.5580 ; ...
           10.0000      50.0000          0.5910 ; ...
           10.5556      51.0000          0.6240 ; ...
           11.1111      52.0000          0.6570 ; ...
           11.6667      53.0000          0.6910 ; ...
           12.2222      54.0000          0.7240 ; ...
           12.7778      55.0000          0.7570 ; ...
           13.3333      56.0000          0.7900 ; ...
           13.8889      57.0000          0.8240 ; ...
           14.4444      58.0000          0.8570 ; ...
           15.0000      59.0000          0.8900 ; ...
           15.5556      60.0000          0.9240 ; ...
           16.1111      61.0000          0.9570 ; ...
           16.6667      62.0000          0.9900 ; ...
           17.2222      63.0000          1.0240 ; ...
           17.7778      64.0000          1.0570 ; ...
           18.3333      65.0000          1.0910 ; ...
           18.8889      66.0000          1.1240 ; ...
           19.4444      67.0000          1.1580 ; ...
           20.0000      68.0000          1.1920 ; ...
           20.5556      69.0000          1.2250 ; ...
           21.1111      70.0000          1.2590 ; ...
           21.6667      71.0000          1.2920 ; ...
           22.2222      72.0000          1.3260 ; ...
           22.7778      73.0000          1.3600 ; ...
           23.3333      74.0000          1.3940 ; ...
           23.8889      75.0000          1.4270 ; ...
           24.4444      76.0000          1.4610 ; ...
           25.0000      77.0000          1.4950 ; ...
           25.5556      78.0000          1.5290 ; ...
           26.1111      79.0000          1.5630 ; ...
           26.6667      80.0000          1.5970 ; ...
           27.2222      81.0000          1.6310 ; ...
           27.7778      82.0000          1.6650 ; ...
           28.3333      83.0000          1.6990 ; ...
           28.8889      84.0000          1.7330 ; ...
           29.4444      85.0000          1.7670 ; ...
           30.0000      86.0000          1.8010 ; ...
           30.5556      87.0000          1.8350 ; ...
           31.1111      88.0000          1.8690 ; ...
           31.6667      89.0000          1.9040 ; ...
           32.2222      90.0000          1.9380 ; ...
           32.7778      91.0000          1.9720 ; ...
           33.3333      92.0000          2.0060 ; ...
           33.8889      93.0000          2.0410 ; ...
           34.4444      94.0000          2.0750 ; ...
           35.0000      95.0000          2.1090 ; ...
           35.5556      96.0000          2.1440 ; ...
           36.1111      97.0000          2.1780 ; ...
           36.6667      98.0000          2.2120 ; ...
           37.2222      99.0000          2.2470 ; ...
           37.7778     100.0000          2.2810 ];
