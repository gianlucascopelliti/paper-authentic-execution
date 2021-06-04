def HandleOutput(conn_id, data):
  conn = ConnectionTable[conn_id]
  if conn != 0:
    nonce = conn.nonce
    key = conn.key
    payload = Encrypt(nonce, data, key)
    conn.incrementNonce()
    HandleLocalEvent(conn_id, payload)
