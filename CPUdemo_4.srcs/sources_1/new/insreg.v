//IR
`include "define.v"
module insReg(
    input wire [`ADDR_BUS] addr,  //32λָ���ַ��
    output wire [`InstBus] Ins,  //32λָ��
    output wire [`ADDR_BUS] pcaddr
);
    reg[`InstBus] unit[4096:0];  //2^12���洢��Ԫ,ÿ���洢��Ԫ32λ

    initial begin//��ʼ����Ԥ����IR�д���ָ��
        //unit[0] = 32'b0000000//00000//00000//000//00001//0000000;    //0000 0000 0000 0000  ����ۼ���ָ��CLA
        unit[1] = 32'b00000000001000001000000110000011;     //rs3=rs0+rs1    0000000//00010//00001//000//00011//0000011
        unit[2] = 32'b00000000001000001000001000000011;     //rs4=rs1+rs2    0000000//00010//00001//000//00100//0000011
//        unit[3] = 32'b00000000001000011000000010000011;     //rs1=rs3+rs2    0000000//00010//00011//000//00001//0000011
        unit[3] = 32'b000000000000_00000_000_00000_0000000;     //NOP (ADDI 0x,0x 0)
        unit[4] = 32'b000000001111_00011_011_00010_0000000;     //ANDI 3x,0h15 2x
        unit[5] = 32'b000000001111_00011_011_00101_0000000;     //ANDI 3x,0h15 5x
    end

    assign Ins = unit[addr];
    assign pcaddr = addr;
endmodule
