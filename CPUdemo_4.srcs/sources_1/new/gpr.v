`include "define.v"
module regfile(
    input   wire    clk,
    input   wire    rst,
    //IDU��WBU�޸ļǷ������
    input wire [4:0] id_chvdb,
    input wire [9:0] wb_chvdb,
    //���Ĵ��� reg1
    input wire                    re1,     // read enable
    input   wire    [`RegAddr]   rs1_addr,
    output   reg    [`RegBus]    rs1_data,
    //���Ĵ��� reg2
    input wire                    re2,     // read enable
    input   wire    [`RegAddr]   rs2_addr,
    output   reg    [`RegBus]    rs2_data,
    //д�Ĵ��� reg
    input wire                    we,     // write enable
    input   wire    [`RegAddr]   wd_addr,
    input   wire   [`RegBus]    wd_wdata,
    //�͵��߶��������ʾ
    output reg [11:0] disp_dat,
    //�͵�IDU�����ڶ�ȡ�Ƿ���
    output reg [`RegBus] valid_bit
    );
    
    reg[`RegBus] regs[0:31];//32��ͨ�üĴ���
    
    //�Ƿ��ƣ����ڼ�����
    reg[`InstBus] reg_valid;//Ϊÿ���Ĵ���������Чλ
    
    
    initial begin
        reg_valid = 32'b0000_0000_0000_0000_0000_0000;
        
        regs[0] = 32'b0000000000000000;//�Ĵ���x0��Ӳ�����ߵĳ���0��û��Ӳ�����ߵ��ӳ��򷵻ص�ַ���ӼĴ���������
                                       //��һ�����̵����У���׼��������Լ��ʹ�üĴ���x1�����淵�ص�ַ��
        regs[1] = 32'b0000000000000001;
        regs[2] = 32'b0000000000000011;
        regs[3] = 32'b0000000000001000;
    end
    always @(clk)begin//�������ʾ
        disp_dat <= regs[3][11:0];//��16λ
    end
    
    
    /* д���� */
    always @ (negedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (wd_addr != 5'b00000)) begin
                regs[wd_addr] <= wd_wdata;
            end
        end
    end
    //�Ƿ���ά��
        //IDU�����rs1/rs2/rd�仯ʱ
    always @ (rs1_addr or rs2_addr or id_chvdb)begin//��ID���޸Ķ�ӦλΪ��Ч
        reg_valid[rs1_addr] = 1'b1;
        reg_valid[rs2_addr] = 1'b1;
        reg_valid[id_chvdb] = 1'b1;
    end
        //WBUд��ʱ
    always @ (wd_addr)begin//��ID���޸Ķ�ӦλΪ��Ч
        reg_valid[wb_chvdb[4:0]] =  1'b0;
        reg_valid[wb_chvdb[9:5]] =  1'b0;
        reg_valid[wd_addr] =        1'b0;
    end 
        
    always @(*)begin
        valid_bit <= ~reg_valid;
    end
    
	/* ���˿�1���� */
    always @ (*) begin
        if(rst == `RstEnable) begin
            rs1_data <= `ZeroWord;
        end else if(rs1_addr == 5'b00000) begin
            rs1_data <= `ZeroWord;  
        end else if(re1 == `ReadEnable) begin
            rs1_data <= regs[rs1_addr];
        end else begin
            rs1_data <= `ZeroWord;
        end
    end

    /* ���˿�2���� */
    always @ (*) begin
        if(rst == `RstEnable) begin
            rs2_data <= `ZeroWord;
        end else if(rs2_addr == 5'b00000) begin
            rs2_data <= `ZeroWord;  
        end else if(re2 == `ReadEnable) begin
            rs2_data <= regs[rs2_addr];
        end else begin
            rs2_data <= `ZeroWord;
        end
    end
endmodule