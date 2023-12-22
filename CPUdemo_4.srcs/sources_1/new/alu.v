//alu2
`include "define.v"
module alu(
    input wire clk,
    input wire rst,
    input wire [9:0] source_regs, //Դ�Ĵ�����ַ�����ڼǷ��ƹ���
    input wire [`AluOpBus] aluop_i,//opcode,ʹ����һ�����
    input wire [6:0] funct7,//ָ��ĸ�7λ����I��λ��ָ���R��ָ��˳���ָ���STOREָ����𵽸�������
    input wire[`AluSelBus] funct,  //����ѡ���ź�alu_op/funct//
    input wire[`AluSelBus]          alusel_i,
    input wire[`RegAddr]           wd_i,
    input wire                     wreg_i,
    input wire [`RegBus] in1, 
    input wire [`RegBus] in2,   //������in1��in2
    
    output reg ct, //����ת��ct
    output reg [9:0] ex_chvdb, //Դ�Ĵ�����ַ�����ڼǷ��ƹ���
    output reg[`RegAddr]         wd_o,
    output reg                   wreg_o,
    output reg [`RegBus] z   //wdata_o
);
    //�����߼�����Ľ�� 
    reg[`RegBus] logicout;
    
    initial begin
      ct = 0;
      z = 0;  //��ʼ�����zΪ0
    end
    
    always@(posedge clk) begin
        if(rst == `RstEnable) begin
        logicout <= `ZeroWord;
        end 
        else if(aluop_i==`OP) begin//************ opcode == OP begin************
                if(funct7==7'b0000000)begin
                    case(funct)
                        3'b000: z = in1+in2;//ADD
                        3'b001: z = in1<in2?in1:`ZeroWord;//SLT
                        3'b010: begin
                            if($signed(in1)<$signed(in2))z = in1;
                            else z = `ZeroWord;
                        end                 //SLTU
                        3'b011: z = in1&in2;//AND
                        3'b100: z = in1|in2;//OR
                        3'b101: z = in1^in2;//XOR
                        3'b110: z = in1<<in2[4:0];//SLL�߼�����
                        3'b111: z = in1>>in2[4:0];//SRL
                    endcase
                end
                else begin
                     case(funct)
                        3'b000: z = in1-in2;//SUB
                        3'b001: z = in1>>>in2[4:0];//SRA��������
                     endcase
                    end
                end//************ opcode == OP end************
         else if(aluop_i==`OP_IMM)begin//************ opcode==OP_IMM begin************
                case(funct)
                    3'b000: z = in1+in2;//ADDI
                    3'b001: begin
                            if($signed(in1)<$signed(in2))       z = in1;
                            else z = `ZeroWord;
                        end             //SLTI
                    3'b010: begin
                            if($unsigned(in1)<$unsigned(in2))   z = in1;
                            else z = `ZeroWord;
                        end             //SLTIU
                    3'b011: z = in1&in2;//ANDI
                    3'b100: z = in1|in2;//ORI
                    3'b101:begin
                            if(in2 == -1) z = ~in1;
                            else z = in1^in2;
                    end                 //XORI
                    //��������ָ��ƫ��Ϊimm��5λ
                    3'b110: z = in1<<in2[4:0];//SLLI
                    3'b111:begin
                        if(funct7==7'b0000000)z = in1>>in2[4:0];//SRLI
                        else z = in1>>>in2;//SRAI
                    end
                endcase
            end//************ opcode==OP_IMM end************
         else if(aluop_i==`LUI)begin
                z = {{20'b0000_0000_0000_0000_0000},in1[11:0]}+{{in2[31:12]},{12'b0000_0000_0000}};//in1��Ŀ�ļĴ�����ԭ����
            end//************ opcode==LUI end************
         else if(aluop_i==`AUIPC)begin
                z = in1 + in2;//rd = pc+extend'IMM_U
            end
      end
//          case (funct)
//              3'b000: z = 0;   //����ۼ���ָ��CLA
//              3'b001: z = ~in1;    //�ۼ���ȡ��ָ��COM    
//              3'b010: z = in1[15] == 1 ? {1'b1, in1[15:1]} : {1'b0, in1[15:1]};    //��������һλָ��SHR in1>>>1;//
//              3'b011: z = {in1[14:0], in1[15]};    //ѭ������һλָ��CSL
//              3'b100: z = in1 + in2;   //�ӷ�ָ��ADD
//              3'b101: z = in1;    //����ָ��STA
//              3'b110: z = in2;   //ȡ��ָ��LDA
//              4'b1000: ct = in1[15]==1?1:0;   //������ת��BAN
//              4'b1001: ;    //ͣ��ָ��
//              4'b1010:  z=in1&in2;//AND
//              4'b1011: z=in1|in2;//OR
//              4'b1100: z=in1-in2;//SUB
//      default ;
//      endcase
    always @ (posedge clk) begin
         wd_o = wd_i;       //Ҫд��Ŀ�ļĴ�����ַ
         wreg_o = wreg_i;
         ex_chvdb = source_regs;
    end


endmodule
