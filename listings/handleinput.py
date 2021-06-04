def HandleInput(conn_id, payload):
  try:
    conn = ConnectionTable[conn_id]
    if conn != 0:
      cb = CbTable[conn.io_id]
      key = conn.key
      nonce = conn.nonce
      cb(Decrypt(nonce, payload, key))
      conn.incrementNonce()
  except: pass
