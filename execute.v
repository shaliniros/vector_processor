`timescale 1ns / 1ps

`include "definitions.v"

module execute();


///////////////////////////////////////////////RS scan for//////////////Ex unit///////////////////////////////////////

   //RS scan for free execution unit
   //vector
     integer i,m,n,e1;
     reg [3:0] src_busy_temp[2:1];
     reg [3:0] temp_ex;
     reg [31:0] temp_a, temp_b;
     integer r1;
      integer j,k, busy,ar,p,q;
     always @(posedge var.clk)
     begin
      //#(`clk_period*2);
       //#`clk_period;
       
        
       // if(!var.EX_v_busy)
       // begin
            for(m=0;m<`RS_v_SIZE;m=m+1)
            begin
                if(var.RS_v[m][`rs_v_busy] && (var.RS_v[m][`rs_v_ex]!=4'b1111) )
                begin
                    
                    case (var.RS_v[m][`rs_v_opcode])
                        7'b0000111:
                        begin
                              //calculating the effective address for Loading elements 
                              if(var.ex_v_counter < (`VLEN/`lane_size))                             
                              begin
                             
                             //address = i+initial_address
                             //+(loop_count*(VLEN/n))
                             //for 0 to 7 elements : counter = 0
                             //for 8 to 15 elements : counter = 1
                             //for 16 to 23 elements : counter = 2
                             //for 24 to 31 elements : counter = 3
                             $display("clk_%0t--->entering v_load...", $time*0.0001);
                             
                              LSQ_scan();        
                             var.LSQ[var.LSQ_v_idx][(var.ex_v_counter*8)+7 -: 8]<= 
                             var.ARF_scalar[var.RS_v[m][`rs_v_src1]][`ARF_s_data] + var.ex_v_counter
                             //+ (var.loopcount * (`VLEN/`lane_size))
                             ;
                             
                             var.RS_v[m][`rs_v_lsq]  = var.LSQ_v_idx;
                                                          
                              temp_ex = var.RS_v[m][`rs_v_ex];
                              temp_ex[var.ex_v_counter] = 1'b1;
                              var.RS_v[m][`rs_v_ex] <= temp_ex;
                              
                              if(var.ex_v_counter == 2'b11) 
                                var.LSQ[var.LSQ_v_idx][`lsq_v_busy] = 1'b1;
                              
                                 var.ex_v_counter <= (var.ex_v_counter+1)%4;
                                
                                //increment the counter 
                                
                             end//if counter                                                                           
                        end//ld
                        
                        7'b0100111:
                        begin
                              //calculating the effective address for Storing elements 
                                 
                               if(var.ex_v_counter < (`VLEN/`lane_size))                             
                              begin
                             
                             //address = i+initial_address
                             //+(loop_count*(VLEN/n))
                             //for 0 to 7 elements : counter = 0
                             //for 8 to 15 elements : counter = 1
                             //for 16 to 23 elements : counter = 2
                             //for 24 to 31 elements : counter = 3
                           
                             LSQ_scan(); 
                             var.LSQ[var.LSQ_v_idx][(var.ex_v_counter*8)+7 -: 8]<= 
                             var.ARF_scalar[var.RS_v[m][`rs_v_src1]][`ARF_s_data] + var.ex_v_counter
                             //+(var.loopcount * (`VLEN/`lane_size))
                             ;
                               $display("clk_%0t---> vstore counter = %d r3[%d]: %d",$time*0.0001,var.ex_v_counter,m,var.ARF_scalar[var.RS_v[m][`rs_v_src1]][`ARF_s_data]);
                             
                             var.RS_v[m][`rs_v_lsq]  = var.LSQ_v_idx;
                             
                              temp_ex = var.RS_v[m][`rs_v_ex];
                              temp_ex[var.ex_v_counter] = 1'b1;
                              var.RS_v[m][`rs_v_ex] <= temp_ex;
                              
                              if(var.ex_v_counter == 2'b11) 
                                var.LSQ[var.LSQ_v_idx][`lsq_v_busy] <= 1'b1;
                                
                                //increment the counter 
                                  var.ex_v_counter <= (var.ex_v_counter+1)%4;
                             end//if counter
                           
                        end//st
                        
                        7'b1010111: //addi and subi
                        begin
                             case(var.RS_v[m][`rs_v_func])
                             
                             9'b000000000: 
                                begin
                                  if( var.ex_v_counter < (`VLEN/`lane_size))                                  
                                  begin                                         
                                         //for 0 to 7 elements : counter = 0
                                         //for 8 to 15 elements : counter = 1
                                         //for 16 to 23 elements : counter = 2
                                         //for 24 to 31 elements : counter = 3
                                        
                                         for(j=0; j<4; j=j+1)
                                                begin//15
                                                   busy=0;
                                                for(k=0;k<8;k=k+1)
                                                begin//16
                        
                                                    busy <= busy| var.ARF_vector_temp[var.RS_v[m][`rs_v_src1]][j*8+k][`ARF_v_busy];
                                                    //increment loopcount when bne is executed
                                                    
                                                end//16
                                                    if(!busy) 
                                                    begin //17                           
                                                    
                                                    case(j)
                                                        0: var.RS_v[m][`rs_v_src1_busy] <= 4'b1110;
                                                        1:var.RS_v[m][`rs_v_src1_busy] <= 4'b1100;
                                                        2:
                                                        var.RS_v[m][`rs_v_src1_busy] <= 4'b1000;
                                                        3: 
                                                        var.RS_v[m][`rs_v_src1_busy] <= 4'b0000 ;                       
                                                    endcase 
                                                    end//17
                                                     
                                           end//15
                                            for(j=0; j<4; j=j+1)
                                                        begin//19
                                                            busy = 0;
                                                        for(k=0;k<8;k=k+1)
                                                        begin//20
                                
                                                            busy <= busy| var.ARF_vector_temp[var.RS_v[m][`rs_v_src2]][j*8+k][`ARF_v_busy];
                                                            //increment loopcount when bne is executed
                                                            
                                                        end//20
                                                            if(!busy) 
                                                            begin//21                            
                                                            
                                                            case(j)
                                                                0: var.RS_v[m][`rs_v_src2_busy] <= 4'b1110;
                                                                1:var.RS_v [m][`rs_v_src2_busy] <= 4'b1100;
                                                                2:          
                                                                var.RS_v   [m][`rs_v_src2_busy] <= 4'b1000;
                                                                3:          
                                                                var.RS_v   [m][`rs_v_src2_busy] <= 4'b0000 ;                       
                                                            endcase 
                                                            end//21
                                                             
                                                end//19
                                                 src_busy_temp[1] = var.RS_v[m][`rs_v_src1_busy];
                                                 src_busy_temp[2] = var.RS_v[m][`rs_v_src2_busy];
                                         
                                         if(src_busy_temp[1][var.ex_v_counter] == 1'b0 &&  src_busy_temp[2][var.ex_v_counter] == 1'b0 )//data is ARF_vector is valid
                                         //perform addition/subtraction
                                         begin
                                             for(var.ex_v_lanes=0; var.ex_v_lanes<`lane_size; var.ex_v_lanes=var.ex_v_lanes+1)
                                             begin
                                             //dest_address+ (count*8) + i
                                             //concatenating busy=0 and sum                                             
                                             temp_a = (var.ARF_vector_temp[var.RS_v[m][`rs_v_src1]][(var.ex_v_counter)*`lane_size+var.ex_v_lanes][`ARF_v_data]);
                                             temp_b = (var.ARF_vector_temp[var.RS_v[m][`rs_v_src2]][(var.ex_v_counter)*`lane_size+var.ex_v_lanes][`ARF_v_data]);
                                             $display("clk_%0t--->exe: outof bound: [%d][%d]",$time*0.0001, var.RS_v[m][`rs_v_dest],(var.ex_v_counter)*`lane_size+var.ex_v_lanes);
                                             var.ARF_vector_temp[var.RS_v[m][`rs_v_dest]][(var.ex_v_counter)*`lane_size+var.ex_v_lanes][31:0] <=
                                                {temp_a+temp_b};
                                             var.ARF_vector_temp[var.RS_v[m][`rs_v_dest]][(var.ex_v_counter)*`lane_size+var.ex_v_lanes][32]<=1'b0; 
                                             end//for var.ex_v_lanes
                                             
                                            temp_ex = var.RS_v[m][`rs_v_ex];
                                            temp_ex[var.ex_v_counter] = 1'b1;
                                            var.RS_v[m][`rs_v_ex] <= temp_ex;
                                            $display("\n clk_%0t---> RS[%d] exe--- %d \n",$time*0.0001,m,temp_ex);   
                                              var.ex_v_counter = (var.ex_v_counter+1)%4;                                    
                                         end//if:src check
                                        
                                    //increment the counter 
                               
                                      
                                end //if: var.ex_v_counter 
                              end//case addi;
                              
                           9'b000010100: //sub
                           begin
                                if(var.ex_v_counter < (`VLEN/`lane_size))
                                  begin
                                         //for 0 to 7 elements : counter = 0
                                         //for 8 to 15 elements : counter = 1
                                         //for 16 to 23 elements : counter = 2
                                         //for 24 to 31 elements : counter = 3
                                         
                                          for(j=0; j<4; j=j+1)
                                                        begin//19
                                                            busy = 0;
                                                        for(k=0;k<8;k=k+1)
                                                        begin//20
                                
                                                            busy <= busy| var.ARF_vector_temp[var.RS_v[m][`rs_v_src2]][j*8+k][`ARF_v_busy];
                                                            //increment loopcount when bne is executed
                                                            
                                                        end//20
                                                            if(!busy) 
                                                            begin//21                            
                                                            
                                                            case(j)
                                                                0:var.RS_v [m][`rs_v_src2_busy] = 4'b1110;
                                                                1:var.RS_v [m][`rs_v_src2_busy] = 4'b1100;
                                                                2:var.RS_v [m][`rs_v_src2_busy] = 4'b1000;
                                                                3:var.RS_v [m][`rs_v_src2_busy] = 4'b0000 ;                       
                                                            endcase         
                                                            end//21
                                                             
                                                end//19
                                         
                                         src_busy_temp[2] = var.RS_v[m][`rs_v_src2_busy];
                                         if(src_busy_temp[2] == 4'b0000 )//data is ARF_vector is valid
                                         //perform addition/subtraction
                                         begin
                                             for(var.ex_v_lanes=0; var.ex_v_lanes<`lane_size; var.ex_v_lanes=var.ex_v_lanes+1)
                                             begin
                                             //dest_address+ (count*8) + i
                                             //concatenating busy=0 and sum
                                                   temp_a =  (var.ARF_vector_temp[var.RS_v[m][`rs_v_src2]][(var.ex_v_counter)*`lane_size+var.ex_v_lanes][`ARF_v_data]);
                                                   temp_b = (var.ARF_scalar[var.RS_v[m][`rs_v_src1]][31:0]);
                                                  $display("clk_%0t--->exe: outof bound: [%d][%d]",$time*0.0001, var.RS_v[m][`rs_v_dest],(var.ex_v_counter)*`lane_size+var.ex_v_lanes);

                                                   var.ARF_vector_temp[var.RS_v[m][`rs_v_dest]][(var.ex_v_counter)*`lane_size+var.ex_v_lanes][31:0]<=
                                                     {temp_a - temp_b};
                                                  var.ARF_vector_temp[var.RS_v[m][`rs_v_dest]][(var.ex_v_counter)*`lane_size+var.ex_v_lanes][32]<=1'b0; 
                                                   temp_ex = var.RS_v[m][`rs_v_ex];
                                               temp_ex[var.ex_v_counter] = 1'b1;
                                               var.RS_v[m][`rs_v_ex] <= temp_ex; 
                                             end//for var.ex_v_lanes
                                             $display("clk_%0t---> out of forrr subv",$time*0.0001);
                                            
                                                 $display("clk_%0t_--- exe--RS[%d] = [%d]",$time*0.0001,m,temp_ex);                                          
                                                var.ex_v_counter = (var.ex_v_counter+1)%4;                                      
                                         end//if:src check                                        
                                                                                  
                                   //increment the counter 
                                 
                                      
                                end //if: var.ex_v_counter
                           
                           end//case sub 
                           
                           endcase//add,sub    
                        end//vadd,vsub
                        
                    endcase//case: opcode
                    m = `RS_v_SIZE;
                end    
            end//for m
        //end//if:ex_busy
     end //always   
     
     //Scan for free LSQ
//     integer e1;
//     always @(posedge var.clk)
//     begin
//        for(e1 = 0; e1 < `LSQ_v_SIZE; e1=e1+1)
//        begin
//            if(!var.LSQ[e1][`lsq_v_busy]) //if atleast one lsq is free
//            begin
//                var.LSQ_v_idx = e1;
//                var.LSQ_v_full = 1'b0;
//                e1 = `LSQ_v_SIZE;
//                 $display("clk_%0t---> LSQ index ",$time*0.0001,e1);
//            end //if 
//            else
//                var.LSQ_v_full = 1'b1;
        
//        end //for
        
//     end//always
     
     
     //scalar :---------------------------- Ex/Mem(single unit)----------------------------------------
     reg [11:0]imm12;
     reg [31:0] temp_a1;
     integer id,file2;
     always @(posedge var.clk)
     begin
        //#(`clk_period*2);
        //#10
        if(!var.EX_s_busy)
        begin
            for(n=0;n<`RS_s_SIZE;n=n+1)
            begin
                if(var.RS_s[n][`rs_s_busy] && !var.RS_s[n][`rs_s_exe])
                begin
                    case (var.RS_s[n][`rs_s_opcode])
                        7'b0010011: //ADDi
                        begin
                            //#10;
                            imm12 = var.RS_s[n][`rs_s_imm12];
                            temp_a1 = var.ARF_scalar[var.RS_s[n][`rs_s_src1]][`ARF_s_data];
                            
                            if(!imm12[11])
                                var.ARF_s_temp_data[var.RS_s[n][`rs_s_dest]]<= temp_a1 + {{21{1'b0}},imm12[10:0]};
                            else
                                var.ARF_s_temp_data[var.RS_s[n][`rs_s_dest]] <= temp_a1 - {{21{1'b0}},imm12[10:0]} ;
                             $display("clk_%0t--->source : %d Addi %d +/- immess. %b| %d = %d",$time*0.0001,var.RS_s[n][`rs_s_src1],temp_a1,imm12[11],imm12[10:0],var.ARF_s_temp_data[var.RS_s[n][`rs_s_dest]]);
                             
                            var.RS_s[n][`rs_s_exe] <= 1'b1;
                        end//addi
                        
                        7'b1100011://BNE
                        begin
                            //#10;
                            if(var.ex_v_store_done)
                            begin
                                var.loopcount = var.loopcount + 4'b1; //increment the loopcount after the store is wb
                                if( (var.ARF_s_temp_data[var.RS_s[n][`rs_s_src1]]!=var.ARF_s_temp_data[var.RS_s[n][`rs_s_src2]]) //recent R5 required--> Forwarding from temp
                                 && var.loopcount<4'd10) 
                                 //BNE R5 not equal to 0 
                                 //0 to 9: 10 loops : VLEN = 32; 32elements per loop*10loops = 320
                                begin
                                //pc update
                                imm12 = var.RS_s[n][`rs_s_imm12];
                                if(!imm12[11])
                                    var.ex_s_bne_target = var.pc + (imm12*2);
                                else
                                    var.ex_s_bne_target = var.pc - (imm12*2);  
                                    
                                    
                                     var.pc = var.ex_s_bne_target;                                   
                                 
                                 //Reset IQ, RS_v , RS_s and LSQ for next iteration
                                 
                                    //clearing IQ 
                                    for(i=0; i<`IQ_SIZE;i=i+1)
                                    begin
                                       var.IQ[i] = {32{1'b0}};
                                    end                                    
                                   //clearing RS_s 
                                   for(i=0; i<`RS_s_SIZE;i=i+1)
                                   begin
                                      var.RS_s[i] = {36{1'b0}};
                                   end 
                                   //clear LSQ  
                                   for(i=0;i<`LSQ_v_SIZE;i=i+1)
                                   begin
                                      var.LSQ[i] = {33{1'b0}};
                                   end//clear lsq
                                   
                                   //write back for Scalar
                                   for(id=0;id<32;id=id+1)
                                    begin
                                         var.ARF_scalar[id][`ARF_s_data] = var.ARF_s_temp_data[id];
                                         var.ARF_scalar[id][`ARF_s_busy] = 1'b0;
                                    end
                                   
                                    for(i=0; i<6;i=i+1)
                                   begin
                                      var.RS_v[i] = {52{1'b0}};
                                   end 
                                   
                                        var.bne_instr_detect = 1'b0;
                                        var.IQ_count = 1'b0;
                                        var.decoder_en = 1'b0;
                                        var.IQ_tail=3'b000;
                                        var.IQ_head=3'b000;
                                          
                                       // var.RS_s[n][`rs_s_exe] = 1'b1;
                                        var.RS_v_FULL = 0;
                                        var.EX_v_busy = 0;
                                        var.EX_s_busy = 1'b0;
                                        var.LSQ_v_full = 1'b0;
                                        var.ex_v_store_done = 0;
                                        var.RS_idx = 1'b0;
                                        var.LSQ_v_idx = 3'h0;
                                        var.decoder_busy=0;
                                        var.ex_v_counter  = 2'h0;
                                        var.mem_v_counter = 2'h0;
                                        var.wb_v_counter  = 2'h0;
                                        
                              /* file2 = $fopen("data_2.dat","w");
                                for(p=0;p<120;p=p+1)
                                begin
                                for(q=0;q<8;q=q+1)
                                begin
                                $fwrite(file2," %d ",var.data_mem[p][q]); 

                                end  
                                  $fwrite(file2,"\n");  
                                 end      
                                $fclose(file2)*/;
                                       
                                // $stop;
                                end//if:loop
                                
                                else
                                begin
                              file2 = $fopen("data_2.dat","w");
                                for(p=0;p<120;p=p+1)
                                begin
                                for(q=0;q<8;q=q+1)
                                begin
                                $fwrite(file2," %d ",var.data_mem[p][q]); 

                                end  
                                  $fwrite(file2,"\n");  
                                 end      
                                $fclose(file2);
                                    
                                    $stop;
                                    end 
                                   //Ending the program execution when calulation A[i]+B[i]-1 for 320 elements completes
                                     
                            end//if:store done
                            //else ex will be 0 and continuously scanned till store is done                           
                             
                        end//bne
                       
                    endcase//case: opcode
                   
                    n = `RS_s_SIZE;
                end    
            end//for m
        end//if:ex_busy
     end //always 
          
     
     


//////////////////////////////////////////////////////////

task automatic LSQ_scan;
begin
for(e1 = 0; e1 < `LSQ_v_SIZE; e1=e1+1)
    begin
        if(!var.LSQ[e1][`lsq_v_busy]) //if atleast one lsq is free
        begin
            var.LSQ_v_idx = e1;
            var.LSQ_v_full = 1'b0;
            e1 = `LSQ_v_SIZE;
             $display("clk_%0t---> LSQ index ",$time*0.0001,e1);
        end //if 
        else
            var.LSQ_v_full = 1'b1;
 end//for lsq 
end                             
endtask      
endmodule
