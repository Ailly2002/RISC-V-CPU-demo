//IR
`include "define.v"
module insReg(
    input wire [`ADDR_BUS] addr,  //32位指令地址码
    output wire [`InstBus] Ins,  //32位指令
    output wire [`ADDR_BUS] pcaddr
);
    reg[`InstBus] unit[4096:0];  //2^12个存储单元,每个存储单元32位

    initial begin//初始化，预先在IR中存入指令
        //unit[0] = 32'b0000000//00000//00000//000//00001//0000000;    //0000 0000 0000 0000  清除累加器指令CLA
        unit[1] = 32'b0000000_00010_00001_000_00011_0000011;     //rs3=rs1+rs2    0000000//00010//00001//000//00011//0000011
        unit[2] = 32'b0000000_00010_00001_000_00100_0000011;     //rs4=rs1+rs2    0000000//00010//00001//000//00100//0000011
        unit[3] = 32'b000000000000_00000_000_00000_0000000;     //NOP (ADDI 0x,0x 0)
        unit[4] = 32'b000000001111_00011_011_00010_0000000;     //ANDI 3x,0h15 2x
//        unit[3] = 32'b;
        unit[5] = 32'b000000001111_00011_011_00101_0000000;     //ANDI 3x,0h15 5x
    end

    assign Ins = unit[addr];
    assign pcaddr = addr;
endmodule

