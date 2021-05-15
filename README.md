# vector_architecture
## Opcodes and instruction set formats are taken from:													
													
[https://github.com/riscv/riscv-v-spec/blob/e49574c92b072fd4d71e6cb20f7e8154de5b83fe/valu-format.adoc
.   
https://github.com/riscv/riscv-opcodes/blob/master/opcodes-rvv
.  
https://github.com/riscv/riscv-v-spec/blob/e49574c92b072fd4d71e6cb20f7e8154de5b83fe/vmem-format.adoc
.  
https://github.com/riscv/riscv-v-spec/blob/e49574c92b072fd4d71e6cb20f7e8154de5b83fe/v-spec.adoc#vector-instruction-formats
.  

## Solution is implemented in Verilog			
			
			
Address	Instructions	Opcode	
000_0	ADDI R5,R5,10	0x00A28293
000_4	loop: Vload V1, R10x0000e087
000_8	Vload V2, R2	0x00016107
000_12	Vadd V3, V1, V2 0x002081D7	
000_16	Vsub V4, V3, R4	0x08324257	
000_20	Vstore R3, V4 	0x0001e227	
000_24	ADDI R1,R1, 4	0x00408093	
000_28	ADDI R2,R2,4	0x00410113	
000_32	ADDI R3,R3 4	0x00418193	
000_36	SUBI R5, R5, 1	0x80128293	
000_40	BNEZ R5, loop	0x82029263

	Architecture considered						
	VLEN: 32 Elements						
	SEW: 32 bits						
	Number of Lanes: 8						
	Number of Banks: 8						
	Vector Register file: V0 to V31						
	Scalar Register file: R0 to R31						
							
	Assumptions made						
	Same Fetch and Decoders are used for both Vector and Scalar instructions						
	Rest of the pipeline units are seperate						
	Vector Load/Store memory latency: 4 cycles						
	Vector Add/Sub latency : 1 cycle						
	Scalar instructions latency: 1cycle						
