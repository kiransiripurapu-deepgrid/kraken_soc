// Copy of PULP register_interface typedefs needed by cluster RTL.
// Source: https://github.com/pulp-platform/register_interface/blob/master/include/register_interface/typedef.svh

`ifndef REGISTER_INTERFACE_TYPEDEF_SVH_
`define REGISTER_INTERFACE_TYPEDEF_SVH_

`define REG_BUS_TYPEDEF_REQ(req_t, addr_t, data_t, strb_t) \
 typedef struct packed { \
 addr_t addr; \
 logic write; \
 data_t wdata; \
 strb_t wstrb; \
 logic valid; \
 } req_t;

`define REG_BUS_TYPEDEF_RSP(rsp_t, data_t) \
 typedef struct packed { \
 data_t rdata; \
 logic error; \
 logic ready; \
 } rsp_t;

`define REG_BUS_TYPEDEF_ALL(name, addr_t, data_t, strb_t) \
 `REG_BUS_TYPEDEF_REQ(name``_req_t, addr_t, data_t, strb_t) \
 `REG_BUS_TYPEDEF_RSP(name``_rsp_t, data_t)

`endif

