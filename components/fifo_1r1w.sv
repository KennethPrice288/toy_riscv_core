module fifo_1r1w
  #(parameter [31:0] width_p = 8
   // Note: Not depth_p! depth_p should be 1<<depth_log2_p
   ,parameter [31:0] depth_log2_p = 8
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [width_p - 1:0] data_i
  ,input [0:0] valid_i
  ,output [0:0] ready_o 

  ,output [0:0] valid_o 
  ,output [width_p - 1:0] data_o 
  ,input [0:0] ready_i
  );

  //upstream interface signals
  //ready to accept data as long as the fifo is not full
  wire [0:0] upstream_ready_w = ~fifo_full_r;
  wire [0:0] upstream_valid_w = valid_i;
  logic [0:0] data_accepted_l;
  reg [0:0] data_accepted_r;

  //downstream interface signals
  wire [0:0] downstream_ready_w = ready_i;
  //data is not valid if the fifo is empty
  //logic [0:0] downstream_valid_l;
  wire [0:0] downstream_valid_w = (read_count_r == 1) & (~fifo_empty_r | data_accepted_r);
  wire [width_p-1:0]downstream_data_w;
  logic [0:0] data_released_l;

  //FIFO head/tail and logic to check if its full
  reg [depth_log2_p-1:0] fifo_tail_r;
  reg [depth_log2_p-1:0] fifo_head_r;
  logic [depth_log2_p-1:0] fifo_tail_n;
  logic [depth_log2_p-1:0] fifo_head_n;

  reg [0:0] fifo_full_r;
  logic [0:0] fifo_full_n;
  reg [0:0] fifo_empty_r;
  logic [0:0] fifo_empty_n;

  //read delay register
  reg [1:0] read_count_r;
  logic [1:0] read_count_n;

  //forwarding logic for when the FIFO is empty or head trails tail by one slot
  logic [0:0] forward_required_l;
  reg [width_p-1:0] forward_data_r;
  reg [width_p-1:0] forward_data_n;
  logic [depth_log2_p-1:0] next_head_pos_l;

  logic [width_p-1:0] data_l;

  always_comb begin
    //initialization
    fifo_tail_n = fifo_tail_r;
    fifo_head_n = fifo_head_r;
    fifo_full_n = fifo_full_r;
    fifo_empty_n = fifo_empty_r;
    read_count_n = 0;
    forward_required_l = 0;
    //downstream_valid_l = 0;
    forward_data_n = data_i;
    next_head_pos_l = fifo_head_r + 1;

    //accepted and released are high while ready & valid on the upstream/downstream side
    data_accepted_l = upstream_ready_w & upstream_valid_w;
    // data_released_l = downstream_ready_w & downstream_valid_l;
    data_released_l = downstream_ready_w & downstream_valid_w;

    //forward when the next head pos overlaps and we've just accepted some data, or the fifo is empty
    if(((next_head_pos_l == fifo_tail_r) & (data_accepted_r)) | (fifo_empty_r)) begin
        forward_required_l = 1;
    end

    //increment read delay counter when downstream is ready for data and the fifo isnt empty
    //or is about to not be empty (data accepted)
    if(~fifo_empty_r | (data_accepted_l & downstream_ready_w)) begin
      read_count_n = 1;
    end

    if(data_accepted_l) begin
      //increment tail pointer on accepted data
      fifo_tail_n = fifo_tail_r + 1;
      //after accepting data, the fifo cannot be empty
      fifo_empty_n = 0;
      //if after enqueuing the pointers overlap, the fifo is full
      if(fifo_tail_n == fifo_head_r) begin
        fifo_full_n = 1;
      end
    end

    if(data_released_l) begin
      //increment the head pointer on accepted data
      fifo_head_n = fifo_head_r + 1;
      //after releasing data, the fifo cannot be full
      fifo_full_n = 0;
      //if after dequeuing the pointers overlap, the fifo is empty
      if(fifo_head_n == fifo_tail_r) begin
        fifo_empty_n = 1;
      end
    end

    //if forwarding is required then data_o should come from the forward_data_r register
    //otherwise, pass data_o data from memory
    if(forward_required_l) begin
      data_l = forward_data_r;
    end else begin
      data_l = downstream_data_w;
    end

  end 

  always_ff @(posedge clk_i) begin
    if(reset_i) begin
      fifo_tail_r <= 0;
      fifo_head_r <= 0;
      read_count_r <= 0;
      fifo_full_r <= 0;
      fifo_empty_r <= 1;
      forward_data_r <= 0;
      data_accepted_r <= 0;
    end else begin
      fifo_tail_r <= fifo_tail_n;
      fifo_head_r <= fifo_head_n;
      read_count_r <= read_count_n;
      fifo_full_r <= fifo_full_n;
      fifo_empty_r <= fifo_empty_n;
      forward_data_r <= forward_data_n;
      data_accepted_r <= data_accepted_l;
    end
  end

  ram_1r1w_sync
    #(.width_p(width_p)
     ,.depth_p(1<<depth_log2_p))
  fifo_mem_inst 
      (.clk_i(clk_i)
      ,.reset_i(reset_i)
      ,.wr_valid_i(data_accepted_l)
      ,.wr_data_i(data_i)
      ,.wr_addr_i(fifo_tail_r)
      ,.rd_data_o(downstream_data_w)
      ,.rd_addr_i(fifo_head_n)
      ,.rd_valid_i(1));

  //assign valid_o = downstream_valid_l;
  assign valid_o = downstream_valid_w;
  assign ready_o = upstream_ready_w;
  assign data_o = data_l;


endmodule
