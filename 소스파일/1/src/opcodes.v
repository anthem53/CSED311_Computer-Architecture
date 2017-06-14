		  
// Opcode
`define	ALU_OP	4'd15
`define	ADI_OP		4'd4
`define	ORI_OP	4'd5
`define	LHI_OP		4'd6

// ALU Function Codes
`define	FUNC_ADD	3'b000
`define	FUNC_SUB	3'b001				 
`define	FUNC_AND	3'b010
`define	FUNC_ORR	3'b011								    
`define	FUNC_NOT	3'b100
`define	FUNC_TCP	3'b101
`define	FUNC_SHL	3'b110
`define	FUNC_SHR	3'b111	

`define	WORD_SIZE	16			
`define	NUM_REGS	4