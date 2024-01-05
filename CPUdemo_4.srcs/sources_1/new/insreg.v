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
//        unit[3] = 32'b0000000_00011_00001_000_00110_0000011;     //rs6=rs1+rs3    
        unit[3] = 32'b000000000000_00000_000_00000_0000000;     //NOP (ADDI 0x,0x 0)
        unit[4] = 32'b000000001111_00011_011_00110_0000000;     //ANDI 3x,0h15 6x
        unit[5] = 32'b000000001111_00011_011_00101_0000000;     //ANDI 3x,0h15 5x
        unit[6] = 32'b00000_00000_00000_00001_00110_0000001;    //LUI 1,x6
        unit[7] = 32'b00000_00000_00000_00010_00111_0000010;    //AUIPC 2,x7
        unit[9] = 32'b0_0000001000_0_00000000_01111_0000100;    //JAL 8,x7
//        unit[9] = 32'b;
        unit[19] = 32'b0000000_00011_00001_000_00110_0000011;     //rs6=rs1+rs3 
        unit[20] = 32'b0000000_00101_00010_000_00101_0000011;     //rs7=rs2+rs5       

        
    end

    assign Ins = unit[addr];  
    assign pcaddr = addr;
    
endmodule

