module tb_vending_machine;

    localparam NOCOIN = 2'b00;
    localparam NICKEL = 2'b01;
    localparam DIME   = 2'b10;

    logic clk = 0;
    logic rst_n = 1;
    logic [1:0] coin_val;
    logic [2:0] display;

    vending_machine DUT(
        .clk(clk),
        .nRST(rst_n),
        .coin_val(coin_val),
        .display(display)
    );

    always #(10) clk++;

    task reset();
        begin
            rst_n = 0;
            @(posedge clk); // Wait for a clock edge
            rst_n = 1;
        end
    endtask

    task resetSignals();
        begin
            coin_val = NOCOIN;
            display = 3'b000;
        end
    endtask

    task insert_coin(input logic [1:0] coin);
        begin
            coin_val = coin;
            @(posedge clk); // Wait for a clock edge to register the coin
            coin_val = NOCOIN; // Clear the coin input after registering
        end
    endtask

    task check_display(input logic [2:0] expected);
        begin
            @(posedge clk); // Wait for a clock edge to update the display
            if (display !== expected) begin
                $display("Test Failed: Expected display = %d, Got = %d", expected, display);
            end else begin
                $display("Test Passed: Display = %d", display);
            end
        end
    endtask

    initial begin
        
        $dumpfile("waveform.fst");
        $dumpvars(0, tb_vending_machine);
        rst_n = 1'b1;

        reset();
        resetSignals();

        // Test #1, inserting a single nickel
        insert_coin(NICKEL); //Insert a nickel
        check_display(3'd1); // Expect display to show 1 (5 cents)

        // Test #2, inserting a dime
        reset();
        resetSignals();
        insert_coin(DIME); //Insert a dime
        check_display(3'd2); // Expect display to show 2 (10 cents)

        // Test #3, sequence to vend (25 cents)
        reset();
        resetSignals();
        insert_coin(DIME); // 10 cents
        check_display(3'd2);
        insert_coin(DIME); // 20 cents
        check_display(3'd4);
        insert_coin(NICKEL); // 25 cents -> VEND (7)
        check_display(3'd7);
        
        // Test #4, check state resets after vend
        check_display(3'd0); // Expect to go back to 0 automatically

        // Test #5, randomize inputs (simulated random sequence)
        reset();
        resetSignals();
        insert_coin(NICKEL); // 5
        check_display(3'd1);
        insert_coin(NICKEL); // 10
        check_display(3'd2);
        insert_coin(DIME); // 20
        check_display(3'd4);
        insert_coin(DIME); // 30 (Over-vend) -> expected to show VEND for S30 or handle correctly
        // We'll just wait to observe behavior

        $finish;
    end

endmodule


