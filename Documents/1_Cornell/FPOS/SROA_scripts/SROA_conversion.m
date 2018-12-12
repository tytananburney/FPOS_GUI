function final_data = SROA_conversion(V)

cold_tip = -179.2*V(1)^2 - 234.18*V(1) + 517.03;
SC_diodes = -190.*V(2:4).^2 - 263.36.*V(2:4) + 574.87;
pressure = 10^(2*V(5)-11);
% thermocouple coefficients found: http://www.omega.com/techref/pdf/z198-201.pdf
% c= [0,17.057,-2.330175e-4,6.543558e-9,-7.356274e-14];
 E1 = V(6)*1000 + 1.495*1;  E2 = V(7)*1000 + 1.495*1;
% thermocouple1 = c*[1,E1,E1^2,E1^3,E1^4]';
% thermocouple2 = c*[1,E2,E2^2,E2^3,E2^4]';
thermocouple1=15.8155*E1+1.0884;
thermocouple2=15.8155*E2+1.0884;


data = [cold_tip, SC_diodes, pressure, thermocouple1, thermocouple2];
% data = [cold_tip, SC_diodes, pressure, E1, E2];
final_data = reshape(data, 1, 7);
