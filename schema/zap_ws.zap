# zap-ws — multi-stream pubsub over ZAP.
#
# Each ZAP-WS connection multiplexes N independent logical streams.
# Frames carry a stream identifier and a per-stream sequence number,
# so a packet loss on one stream does not block any other stream.
# Optional Reed-Solomon (k+m, k) per-stream FEC masks loss without a
# retransmit RTT.

# Frame is the unit on the wire. Each ZAP transport frame carries
# exactly one of these.
struct Frame
  union
    open    Open
    data    Data
    close   Close
    reset   Reset
    ack     Ack

# Open declares a new logical stream. The opener proposes a streamId
# (32-bit, even for client-initiated, odd for server-initiated, like
# HTTP/2). The receiver MAY reject by sending Reset.
struct Open
  streamId UInt32
  topic    Text
  flags    UInt32

# Data carries an opaque payload on a stream. seqNum is monotonic per
# stream; FEC parity frames share seqNum range with their data window.
struct Data
  streamId UInt32
  seqNum   UInt64
  body     Data
  fin      Bool

# Close ends a stream cleanly. Both sides must send Close (analogous
# to TCP FIN/FIN+ACK).
struct Close
  streamId UInt32

# Reset terminates a stream abruptly. Reason codes are namespace-free
# unsigned ints; see spec for canonical values.
struct Reset
  streamId UInt32
  code     UInt32
  reason   Text

# Ack carries credit (window-update) for backpressure.
struct Ack
  streamId UInt32
  bytes    UInt64
