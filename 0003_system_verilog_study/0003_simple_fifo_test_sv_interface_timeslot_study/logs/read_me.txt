test0 -->  compare btw interface sampling and non-interface sampling

test1 --> compare btw interface sampling and non-interface sampling, with interface sampling delay #1step

test2 --> compare btw interface sampling and non-interface sampling and with blocking assignment for tb line 250 and tb line 142 for the rd_en_next :: results --> for the non-interface samping, have to use non-blocking assignment in order to get 1 ck delay assignment, but for the interface samping, blocking and non-blocking would both get 1ck delay assignment, but I think use non-blocking is perfered.

 