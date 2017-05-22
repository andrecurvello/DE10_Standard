force -freeze sim:/bitcoinminer/OSC_CLK_50MHZ 1 0, 0 {10000 ps} -r 20ns
force -freeze sim:/bitcoinminer/slResetInput 0 0 -cancel 10000ms

force -freeze sim:/bitcoinminer/slvTxData_64 0000000000000000000000000000000000000001000000000000000000000000 0 -cancel 800000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 0ns -cancel 25ns

force -freeze sim:/bitcoinminer/slvTxData_64 1010010000011011100001011011100000000000000000000000100010100011 800020ns -cancel 1595000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 800020ns -cancel 803000ns

force -freeze sim:/bitcoinminer/slvTxData_64 1101111011110010100110011111111010110010100110101101010001000100 1595020ns -cancel 2400000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 1595020ns -cancel 1596000ns

force -freeze sim:/bitcoinminer/slvTxData_64 1000101110011110010101100111111011100010000101111001001111001101 2400020ns -cancel 3300000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 2400020ns -cancel 2409000ns

force -freeze sim:/bitcoinminer/slvTxData_64 0010101100010010111111001111000110101011000000101100110110000001 3300020ns -cancel 4100000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 3300020ns -cancel 3309000ns

force -freeze sim:/bitcoinminer/slvTxData_64 1010111111110111100101111101011110110000100100101000100011111100 4100020ns -cancel 4900000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 4100020ns -cancel 4109000ns

force -freeze sim:/bitcoinminer/slvTxData_64 1010111001000010101110010001111000011110100101010000111001110001 4900020ns -cancel 5700000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 4900020ns -cancel 4902000ns

force -freeze sim:/bitcoinminer/slvTxData_64 0111010110001101111111001111111110001011110110110010001100000100 5700020ns -cancel 6500000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 5700020ns -cancel 5703000ns

force -freeze sim:/bitcoinminer/slvTxData_64 0100110111010111111101011100011111000010101101100010000011100011 6500020ns -cancel 7300000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 6503020ns -cancel 6506000ns

force -freeze sim:/bitcoinminer/slvTxData_64 1001010101000110101000010100001000011010010001001011100111110010 7300020ns -cancel 8100000ns
force -freeze sim:/bitcoinminer/slTxStrobe 1 7302020ns -cancel 7309000ns
