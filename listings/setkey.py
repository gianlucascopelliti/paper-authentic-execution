def SetKey(payload):
    try:
      conn_id, io_id, key = Decrypt(payload)
      conn = Connection(conn_id, io_id, key)
      ConnectionTable[conn_id] = conn
    except: pass
