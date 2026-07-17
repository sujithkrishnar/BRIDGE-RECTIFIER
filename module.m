clc;
clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMMERCIAL POWER SUPPLY DESIGN CALCULATOR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% USER INPUTS

Input.Vac = 12;                    % Transformer Secondary Voltage (VAC)
Input.RequiredDC = 15;             % Required DC Output Voltage (V)
Input.LoadCurrent = 1.0;           % Load Current (A)
Input.Frequency = 50;              % AC Frequency (Hz)

Input.DiodeForwardVoltage = 0.7;   % Diode Forward Voltage (V)

Input.AllowedRipple = 2;           % Ripple Voltage (Vpp)

Input.CapacitorESR = 0.08;         % Capacitor ESR (Ohm)

Input.LEDVoltage = 2;              % LED Forward Voltage (V)

Input.LEDCurrent = 0.01;           % LED Current (10 mA)

Input.AmbientTemperature = 25;     % Ambient Temperature (°C)

Input.ThermalResistance = 30;      % Bridge Thermal Resistance (°C/W)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALL MODULES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Transformer = TransformerModule(Input);

Bridge = BridgeRectifierModule(Input,Transformer);

Capacitor = CapacitorModule(Input,Bridge);

LED = LEDResistorModule(Input,Transformer);

Power = PowerAnalysisModule(...
    Input,...
    Transformer,...
    Bridge,...
    Capacitor,...
    LED);

Voltage = VoltageRegulationModule(...
    Input,...
    Transformer,...
    Bridge,...
    Capacitor);

Thermal = ThermalAnalysisModule(...
    Input,...
    Transformer,...
    Bridge,...
    Capacitor,...
    LED);

Components = ComponentSelectionModule(...
    Input,...
    Transformer,...
    Bridge,...
    Capacitor,...
    LED);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISPLAY FINAL RESULTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(' ');
disp('=======================================')
disp('POWER SUPPLY DESIGN COMPLETED')
disp('=======================================')

disp(Transformer)

disp(Bridge)

disp(Capacitor)

disp(LED)

disp(Power)

disp(Voltage)

disp(Thermal)

disp(Components)
