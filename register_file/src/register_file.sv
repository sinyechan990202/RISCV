// ============================================================
// RISC-V RV32I Register File
// Target Board : Zybo Z7-20 (Xilinx Zynq-7000 XC7Z020-1CLG400C)
//
// [스펙]
//   - 32개 범용 레지스터 (x0 ~ x31), 각 32비트
//   - x0 는 하드와이어드 0 (쓰기 무시, 읽기 항상 0)
//   - 2-포트 동시 읽기 (rs1, rs2)
//   - 1-포트 동기 쓰기 (posedge clk, write enable)
//   - 리셋 : 동기 리셋 (active-high), 전체 레지스터 0 으로 초기화
//
// [포트 설명]
//   clk       : 시스템 클럭
//   rst_n     : 동기 리셋 (active-low)  ← Zybo Z7 관례
//   rs1_addr  : 읽기 포트 1 주소 (5비트, 0~31)
//   rs2_addr  : 읽기 포트 2 주소 (5비트, 0~31)
//   rd_addr   : 쓰기 포트 주소 (5비트, 0~31)
//   rd_wdata  : 쓰기 데이터 (32비트)
//   wen       : 쓰기 활성화 (Write ENable)
//   rs1_rdata : 읽기 포트 1 출력 (비동기, 조합 논리)
//   rs2_rdata : 읽기 포트 2 출력 (비동기, 조합 논리)
//
// [읽기 우선순위 (Write-Through / Forwarding)]
//   같은 사이클에 동일 주소로 쓰기 + 읽기가 발생하면
//   쓰기 데이터를 바이패스하여 읽기 포트로 즉시 반영
//   → 파이프라인 해저드 감소 (EX 단계에서 WB 결과 즉시 사용)
//   → Vivado synthesis : BRAM 대신 Distributed RAM 으로 추론
//
// [XC7Z020 구현 노트]
//   - 32×32b = 1 Kbit → Distributed RAM (LUT) 으로 합성
//   - BRAM 는 최소 16Kb 이므로 레지스터 파일 크기에 낭비
//   - Distributed RAM 추론을 위해 출력에 always_comb 사용
// ============================================================
`timescale 1ns / 1ps

module register_file (
    input  logic        clk,
    input  logic        rst_n,      // 동기 리셋 (active-low)

    // 읽기 포트
    input  logic [4:0]  rs1_addr,   // 소스 레지스터 1 주소
    input  logic [4:0]  rs2_addr,   // 소스 레지스터 2 주소
    output logic [31:0] rs1_rdata,  // 소스 레지스터 1 출력
    output logic [31:0] rs2_rdata,  // 소스 레지스터 2 출력

    // 쓰기 포트
    input  logic [4:0]  rd_addr,    // 목적 레지스터 주소
    input  logic [31:0] rd_wdata,   // 쓰기 데이터
    input  logic        wen         // 쓰기 활성화
);

    // ----------------------------------------------------------
    // 레지스터 파일 배열 (x0 ~ x31)
    //   reg_file[0] 은 항상 0 → x0 에 대한 쓰기 무시로 보장
    // ----------------------------------------------------------
    logic [31:0] reg_file [0:31];

    // ----------------------------------------------------------
    // 동기 쓰기 (posedge clk)
    //   - rst_n == 0 : 전체 레지스터 0 으로 초기화
    //   - wen == 1 && rd_addr != 0 : 지정 레지스터에 rd_wdata 저장
    //   - x0 (rd_addr == 0) 는 쓰기 무시 → 항상 0 유지
    // ----------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // 동기 리셋 : x0 ~ x31 전체 초기화
            for (int i = 0; i < 32; i++) begin
                reg_file[i] <= 32'd0;
            end
        end else if (wen && (rd_addr != 5'd0)) begin
            reg_file[rd_addr] <= rd_wdata;
        end
    end

    // ----------------------------------------------------------
    // 비동기 읽기 + Write-Through 포워딩
    //   조건 : wen && 주소 일치 && 주소 != x0
    //   → 같은 사이클 쓰기 데이터를 바이패스하여 출력
    //   그 외  : 레지스터 배열에서 직접 읽기 (x0 → 항상 0)
    // ----------------------------------------------------------
    always_comb begin
        // rs1 포워딩
        if (wen && (rs1_addr == rd_addr) && (rs1_addr != 5'd0))
            rs1_rdata = rd_wdata;
        else
            rs1_rdata = reg_file[rs1_addr];

        // rs2 포워딩
        if (wen && (rs2_addr == rd_addr) && (rs2_addr != 5'd0))
            rs2_rdata = rd_wdata;
        else
            rs2_rdata = reg_file[rs2_addr];
    end

endmodule
