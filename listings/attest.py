def Attest(challenge):
  try:
    ev = GenAttestationEvidence(challenge)
    return ev
  except:
    return None # attestation failed
