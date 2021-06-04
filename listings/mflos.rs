/* global variables definition omitted for brevity */

//@ sm_output(Flooded)

//@ sm_input
pub fn Sensor(data : &[u8]) {
  if data.len() > 0 {
    if data[0] >= SATURATED {
      flooded = true;
    } else {
      flooded = false;
      Flooded(&[0]); 
    }
  }
}
//@ sm_input
pub fn Tick(_data : &[u8]) {
  if flooded {
    count += 1;
    if count > MAX {
      Flooded(&[1]); 
    }
  }
}