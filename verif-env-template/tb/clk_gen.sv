/*******************************************************************************
 * Copyright 2020 Nelson Alves Ferreira Neto
 * All Rights Reserved Worldwide
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice, 
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice, 
 * this list of conditions and the following disclaimer in the documentation 
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
/*
 * Package: clk_gen
 *
 * Description: Generate clock in accordance with given period, phase and duty cycle.
 *
 * Maintainer: Nelson Alves <nelsonafn@gmail.com>
 *
 * History:
 * March 01, 2022 at 23:53 - Created by Nelson Alves <nelsonafn@gmail.com>
 */
  
module clk_gen (
    input logic en, //[in] Clock Enable   
    output logic clk    //[out] Clock 
);
    parameter CLK_PERIOD = 4; // Period in ns
    parameter CLK_PHASE = 0; // Phase in degrees 
    parameter CLK_DUTY = 50; // Duty cycle of %

    real clk_frequency = 1.0 / CLK_PERIOD;
    real clk_on = CLK_DUTY / 100.0 * CLK_PERIOD;
    real clk_off = (100.0 - CLK_DUTY) / 100.0 * CLK_PERIOD;
    real start_delay = CLK_PERIOD * CLK_PHASE / 360.0;

    logic clk_en;

    initial begin
        clk_en = 0;
        clk = 0;
    end

	/* 
     * Apply start delay and stop delay to create the phase effect over the clock.
     */
    always @(posedge en or negedge en) begin: start_clk
        if (en) begin
            #(start_delay) clk_en <= '1;
        end 
        else begin
            #(start_delay) clk_en <= '0;
        end
    end: start_clk

	/* 
     * Generates the clock with the duty cycle.
     */
    always @(posedge clk_en) begin: generation
        if (clk_en) begin
            while (clk_en) begin
                #(clk_on) clk <= '1;
                #(clk_off) clk <= '0;
            end
            clk <= '0;
        end
    end: generation
    
endmodule: clk_gen