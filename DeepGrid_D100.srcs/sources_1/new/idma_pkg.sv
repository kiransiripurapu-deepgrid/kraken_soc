package idma_pkg;
  // Standard stubs
  typedef logic [31:0] idma_req_t;
  typedef logic [31:0] idma_rsp_t;
  typedef logic        idma_busy_t;
  
  // Fixes error at idma_wrap.sv:298
  typedef enum logic {
    NO_ERROR_HANDLING = 1'b0
  } idma_error_config_t;

  // Fixes error at idma_wrap.sv:301
  typedef logic idma_eh_req_t; 
endpackage