SM_OUTPUT(FloS1, Flooded);
SM_DATA(FloS1) int flooded, count;

SM_INPUT(FloS1, Sensor, data, len) {
  if (len > 0) {
    if (data[0] >= SATURATED) {
      flooded = 1;
    } else {
      flooded = count = 0;
      Flooded(&flooded, sizeof(flooded)); 
    }
  }
}
SM_INPUT(FloS1, Tick, data, len) {
  if (flooded && ++count > MAX) {
    Flooded(&flooded, sizeof(flooded)); 
  }
}
