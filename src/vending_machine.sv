module vending_machine(
    //Commented out because doesnt build with this
/*    parameter CLK_FREQ = 50_000_000 // 50MHz clock frequency
)(  */
    input  logic clk,
    input  logic nRST,
    input  logic [1:0] coin_val, // Fixed: dimension comes before the variable name
    output logic [2:0] display   // 3 bits is perfect for representing 0 to 6
);

    //localparam WAIT_CYCLES = 3 * CLK_FREQ; // 3 seconds worth of clock cycles

    // coin constants
    // coin values:
    // 00 = no coin
    // 01 = nickel
    // 10 = dime

    localparam NOCOIN = 2'b00;
    localparam NICKEL = 2'b01;
    localparam DIME   = 2'b10;
    localparam VEND   = 3'b111 * 5; // Special display value for vending

    
    // State encoding (0 to 6 fits perfectly in 3 bits)
    typedef enum logic [2:0] { 
        S0  = 3'd0,
        S5  = 3'd1,
        S10 = 3'd2,
        S15 = 3'd3,
        S20 = 3'd4,
        S25 = 3'd5,
        S30 = 3'd6
    } state_t;

    state_t current_state, next_state;

    // ---------------------------------------------------------
    // 1. Sequential Logic (State Memory)
    // ---------------------------------------------------------
    always_ff @(posedge clk or negedge nRST) begin
        if (!nRST) begin
            current_state <= S0; // Reset state
        end else begin
            current_state <= next_state; // Advance to next state
        end
    end

    // ---------------------------------------------------------
    // 2. Combinational Logic (Next State & Outputs)
    // ---------------------------------------------------------


    always_comb begin
        // Default assignments to prevent latches
        next_state = current_state; 
        display = 3'b000; // Default display is 0

        case (current_state)
            S0: begin
                display = 3'd0; 
                if (coin_val == NICKEL)      next_state = S5;
                else if (coin_val == DIME)   next_state = S10;
                
            end
            
            S5: begin
                display = 3'd1;
                if (coin_val == NICKEL)      next_state = S10;
                else if (coin_val == DIME)   next_state = S15;
                 
            end
            
            S10: begin
                display = 3'd2;
                if (coin_val == NICKEL)      next_state = S15;
                else if (coin_val == DIME)   next_state = S20;
                
            end
            
            S15: begin
                display = 3'd3;
                if (coin_val == NICKEL)      next_state = S20;
                else if (coin_val == DIME)   next_state = S25;
                
            end
            
            S20: begin
                display = 3'd4;
                if (coin_val == NICKEL)      next_state = S25;
                else if (coin_val == DIME)   next_state = S30;
                
            end
            
            S25: begin
                display = VEND;
                //TODO: implement a "waiting" mechanism that shows the display for 3 seconds before resetting to S0
                next_state = S0; // Move to bal = 0 after vending
         
            end
            
            S30: begin
                display = VEND;
                //TODO: implement a "waiting" mechanism that shows the display for 3 seconds before resetting to S5
                next_state = S5;
            end
            
            default: next_state = S0;
        endcase
    end

endmodule