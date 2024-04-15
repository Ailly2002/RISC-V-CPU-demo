`include "define.v"
module shift_mux(
    input wire [`RegBus]    in1,
    input wire [`RegBus]    in2,
    input wire sel,
    
    output wire [`RegBus]    out
);
    //���selΪ1����out����in2������out����in1
    assign out = sel?in2:(in1+2);
endmodule