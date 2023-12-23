//CU
`include "define.v"
module cu(
    input wire          clk,
    input wire          rst,
    input wire[`RegBus]         inst,
    input wire [`ADDR_BUS]      pcadd,//当前PC地址
    input wire [`RegBus]        valid_bit,//读取记分牌当前有效位
    
    //读取得Regfile的值
    input wire[`RegBus]         reg1_data,
    input wire[`RegBus]         reg2_data,
    //输出到Regfile的信息
    output reg                  reg1_read,
    output reg                  reg2_read,
    output reg[`RegAddr]        reg1_addr,
    output reg[`RegAddr]        reg2_addr,
    output reg[4:0]             id_chvdb,//目的寄存器地址，用于记分牌功能
    
    
    //输出到EX阶段
        //到Add
    output reg [`ADDR_BUS]      pcadd_o,
    output reg [`RegBus]        shift,//立即数偏移量，EX_ADD的另一个操作数
        //到Add_MUX
    output reg[`RegBus]         rs1_o,
    output reg                  j_type,//跳转指令的类型：JAL/JALR
        //到ALU
    output reg                  stop, //停机信号
    output reg [9:0]            source_regs, //源寄存器地址，用于记分牌功能
    output reg[`AluOpBus]       aluop_o,//
    output reg[6:0]             funct7,
    output reg[`AluSelBus]      funct3,//funct//
    output reg[`RegBus]         reg1_o,//
    output reg[`RegBus]         reg2_o,//
    output reg[`RegAddr]        wd_o,//
    output reg                  wreg_o//
);

    
    wire[`OPcode] operate = inst[6:0];//7位指令操作码,操作码类型
    
    //保存指令执行需要的立即数
    //32宽度，按照需要裁剪
    reg[`RegBus]   imm12;//I立即数
    reg[`RegBus]   imm20;//U立即数
    
    
    
    //指示指令是否有效
    reg instvalid;
    //符号位
    reg imm_signed;//在RISC-V 中，所有立即数的符号位总是在指令的 31 位
    
    
    initial begin
        stop = 0;
    end
    
    always @(posedge clk) begin
        if(rst == `RstEnable)begin
                        //复位
                        aluop_o <= 7'b0000000;
                        wreg_o  <=  `WriteDisable;
                        reg1_read <= `ReadDisable;
                        reg2_read <= `ReadDisable;
                        funct7=7'b0000000;
                        reg1_addr=`NOPRegAddr;
                        reg2_addr=`NOPRegAddr;
                        wd_o   =  `NOPRegAddr;
                        source_regs = 10'b00000_00000;
                        
        end
        else begin
            imm12 <= { {20{inst[31]}}, inst[31:20] };//12位I立即数,符号扩展
            imm20 <= { inst[31:12] , {12'b0000_0000_0000} };//20位U立即数,低位扩展
            funct3 = inst[14:12];//3位funct
            case(operate)
                `OP:    begin//所有操作都是读取rs1和rs2寄存器作为源操作数，并把结果写入到寄存器rd中
                        //指令执行要读写的目的寄存器
                        reg1_addr=inst[19:15];
                        reg2_addr=inst[24:20];
                        wd_o   =  inst[11:7];
                            //在所有格式中，RISC-V ISA将源寄存器（rs1和rs2）和目标寄存器（rd）固定在同样的位置，以简化指令译码
                            if(valid_bit[reg1_addr] && valid_bit[reg2_addr] && valid_bit[wd_o]) begin//检查记分牌
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadEnable;
                                funct7=inst[31:25];
                                source_regs = {reg2_addr,reg1_addr};
                                instvalid   =  `InstValid;//指令有效
                            end
                            else begin
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadDisable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                reg2_addr=`NOPRegAddr;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                            end//如果记分牌无效，用全零填充，原指令状态通过控制PC和IR重新读取
                    end
                 `OP_IMM:begin
                        reg1_addr=inst[19:15];
                        wd_o   =  inst[11:7];
                            if(valid_bit[reg1_addr] && valid_bit[wd_o]) begin//检查记分牌
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=inst[31:25];//立即数高7位，供alu用
                                source_regs = {5'b00000,reg1_addr};
                                instvalid   =  `InstValid;
                            end 
                            else begin//NOP
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                imm12 = 32'b0000_0000_0000_0000_0000_0000_0000;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                            end
                    end
                 `LUI:begin
                        reg1_addr=inst[11:7];
                        wd_o   =  inst[11:7];
                        if(valid_bit[reg1_addr] && valid_bit[wd_o]) begin//检查记分牌
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;
                                reg2_read <= `ReadDisable;
                                instvalid   =  `InstValid;
                        end
                        else begin//NOP
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                imm12 = 32'b0000_0000_0000_0000_0000_0000_0000;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                        end
                    end
                    `AUIPC:begin
                            wd_o   =  inst[11:7];
                            if(valid_bit[wd_o]) begin//检查记分牌
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;//通过rs1读取PC当前的地址
                                reg2_read <= `ReadDisable;
                                instvalid   =  `InstValid;
                            end
                            else begin//NOP
                                stop <= `Stall;
                                aluop_o <= 7'b0000000;
                                wreg_o  <=  `WriteDisable;
                                reg1_read <= `ReadEnable;
                                reg2_read <= `ReadDisable;
                                funct7=7'b0000000;
                                reg1_addr=`NOPRegAddr;
                                imm12 = 32'b0000_0000_0000_0000_0000_0000_0000;
                                wd_o   =  `NOPRegAddr;
                                source_regs = 10'b00000_00000;
                            end
                    end
                    `JAL:begin//处理上可以类似U类指令，对其中的imm20进行分割截取
                            wd_o   =  inst[11:7];
                            if(valid_bit[wd_o]) begin//检查记分牌,要暂存pc的寄存器未被占用
                                stop <= `unStall;
                                aluop_o <= operate;
                                wreg_o  <=  `WriteEnable;
                                reg1_read <= `ReadDisable;//通过rs1读取PC当前的地址
                                reg2_read <= `ReadDisable;
                                instvalid   =  `InstValid;
                            end
                            else begin
                                
                            end
                    end
                    `JALR:begin
                    end
                    `BRANCH:begin
                    end
                default:begin
                end
            endcase
        end
    end
    //******
    //确定运算源操作数1
    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            reg1_o <= `ZeroWord;
        end else if(reg1_read == `ReadEnable) begin
            reg1_o <= reg1_data;  //Regfile读端口1的输出值
        end else if(reg1_read == `ReadDisable) begin
            if(operate == `AUIPC)begin
                reg1_o <= pcadd;end
            else begin
                reg1_o <= `ZeroWord;end          //立即数
        end else begin
            reg1_o <= `ZeroWord;
        end
    end
    
    //确定运算源操作数2
    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            reg2_o <= `ZeroWord;
        end else if(reg2_read == `ReadEnable) begin
            reg2_o <= reg2_data;  //Regfile读端口1的输出值
        end else if(reg2_read == `ReadDisable) begin
            if(operate == `OP_IMM)begin
                reg2_o <= imm12;end          //立即数
            else if(operate == `LUI)begin
                reg2_o <= imm20;end
            else if(operate == `AUIPC)begin
                reg2_o <= imm20;end
        end else begin
            reg2_o <= `ZeroWord;
        end
    end
    //维护记分牌
    always @(*)begin
        id_chvdb <= wd_o;
        pcadd_o  <= pcadd;
    end
    //******
//    always @(*) begin
//      case(funct)
//        3'b000: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100000;   //1,清除累加器CLA
//        3'b001: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100001;   //2,累加器取反COM    
//        3'b010: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100010;   //3,算术右移一位SHR
//        3'b011: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100011;   //4,循环左移一位CSL
//        3'b100: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100100;   //5,加法指令ADD
//        3'b101: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00010101;   //6,存数STA
//        3'b110: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00100110;   //7,取数指LDA
//        3'b111: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b01000111;   //8,无条件转移JMP
////        4'b1000: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b00001000;   //9,有条件转移BAN
////        4'b1001: {stop,uct,acc_wr,dataMem_wr,alu_op} = 8'b10000000;   //10,停机STOP
//        endcase
//    end

endmodule