`ifndef IDMA_TYPEDEF_SVH
`define IDMA_TYPEDEF_SVH

// Matches 4 arguments at line 153: NAME, ID_T, ADDR_T, LEN_T
`define IDMA_TYPEDEF_FULL_REQ_T(NAME, ID_T, ADDR_T, LEN_T) \
  typedef struct packed { \
    ID_T    id;    \
    ADDR_T  addr;  \
    LEN_T   len;   \
  } NAME;

// Matches 2 arguments at line 154: NAME, ADDR_T
`define IDMA_TYPEDEF_FULL_RSP_T(NAME, ADDR_T) \
  typedef struct packed { \
    ADDR_T addr; \
  } NAME;

// Matches 4 arguments at line 157: NAME, REQ_T, REPS_T, STRIDES_T
`define IDMA_TYPEDEF_FULL_ND_REQ_T(NAME, REQ_T, REPS_T, STRIDES_T) \
  typedef struct packed { \
    REQ_T     req;     \
    REPS_T    reps;    \
    STRIDES_T strides; \
  } NAME;

`endif