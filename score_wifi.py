from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class WifiData(BaseModel):
    signal: int
    encryption: str
    band: str

@app.post("/score")
def get_trust_score(data: WifiData):
    trust = 0
    if data.encryption == "WPA2" and data.signal > -70:
        trust = 80
    elif data.encryption == "WPA" and data.signal > -80:
        trust = 60
    else:
        trust = 30

    return {"trust_score": trust}
