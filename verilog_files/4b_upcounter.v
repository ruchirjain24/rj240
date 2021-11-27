// module jkfflop(input  J, K , clk ,rst, output reg Q);
`include "jk_ff.v"
module fourb_upcount(input clk, rst, output [3:0] Q);
  
  jkfflop first(1'b1 , 1'b1 , clk , rst , Q[0]);
  
  jkfflop second(Q[0], Q[0], clk , rst, Q[1]);
  
  jkfflop third(Q[0] & Q[1] , Q[0] & Q[1] , clk , rst , Q[2]);

  jkfflop fourth(Q[0] & Q[1] & Q[2], Q[0] & Q[1] & Q[2] , clk ,rst, Q[3]);

endmodule

module upcounterTB;
  reg CLK = 0, rst = 1;
  wire[3:0] Q;
  fourb_upcount UUT(CLK ,rst, Q);
  initial 
    begin
        $monitor($time," Q=%d, rst=%d\n",Q,rst);    
    end
  initial 
    repeat(40) 
        #50 CLK=~CLK;
  initial 
    #70 rst = 0;    //1st #50 changes Q to 0, at #70, we change the reset bit so that this doesn't happen at #100.
endmodule