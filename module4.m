%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% LEDResistorModule.m
%
% COMMERCIAL POWER SUPPLY DESIGN CALCULATOR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Constants

SafetyPowerFactor = 2.0;
MaximumLEDTemperature = 85;      % deg C
LEDThermalResistance = 200;       % deg C/W (typical 5 mm LED)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Supply Voltage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.SupplyVoltage = Transformer.EstimatedDC;

LED.ForwardVoltage = Input.LEDVoltage;

LED.RequiredCurrent = Input.LEDCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Voltage Across Resistor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.ResistorVoltage = ...
    LED.SupplyVoltage - LED.ForwardVoltage;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Required Resistance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.CalculatedResistance = ...
    LED.ResistorVoltage / LED.RequiredCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Standard Resistor Selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

StandardResistors = [...
220 270 330 390 470 560 680 820 ...
1000 1200 1500 1800 2200 2700 ...
3300 3900 4700 5600 6800 8200 ...
10000 12000 15000];

Index = find(StandardResistors >= ...
             LED.CalculatedResistance,1);

if isempty(Index)

    LED.RecommendedResistance = ...
        StandardResistors(end);

else

    LED.RecommendedResistance = ...
        StandardResistors(Index);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Actual LED Current
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.ActualCurrent = ...
    LED.ResistorVoltage / ...
    LED.RecommendedResistance;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LED Power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.Power = ...
    LED.ForwardVoltage * ...
    LED.ActualCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Resistor Power
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.ResistorPower = ...
    LED.ActualCurrent^2 * ...
    LED.RecommendedResistance;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recommended Resistor Wattage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RequiredPower = ...
    LED.ResistorPower * SafetyPowerFactor;

if RequiredPower <= 0.25

    LED.ResistorRating = 0.25;

elseif RequiredPower <= 0.50

    LED.ResistorRating = 0.50;

elseif RequiredPower <= 1

    LED.ResistorRating = 1;

elseif RequiredPower <= 2

    LED.ResistorRating = 2;

else

    LED.ResistorRating = 5;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LED Efficiency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.InputPower = ...
    LED.SupplyVoltage * ...
    LED.ActualCurrent;

LED.Efficiency = ...
    (LED.Power / LED.InputPower) * 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Approximate Brightness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ReferenceCurrent = 0.020;     % 20 mA

ReferenceLumens = 2.5;

LED.LuminousFlux = ...
    (LED.ActualCurrent / ReferenceCurrent) * ...
    ReferenceLumens;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thermal Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.TemperatureRise = ...
    LED.Power * ...
    LEDThermalResistance;

LED.JunctionTemperature = ...
    Input.AmbientTemperature + ...
    LED.TemperatureRise;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thermal Margin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.ThermalMargin = ...
    MaximumLEDTemperature - ...
    LED.JunctionTemperature;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thermal Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if LED.JunctionTemperature < MaximumLEDTemperature

    LED.ThermalStatus = 'SAFE';

else

    LED.ThermalStatus = 'OVERHEATED';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Voltage Margin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.VoltageMargin = ...
    LED.SupplyVoltage - ...
    LED.ForwardVoltage;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Current Error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LED.CurrentError = ...
    abs(LED.ActualCurrent - LED.RequiredCurrent) ...
    / LED.RequiredCurrent * 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Overall Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if LED.CurrentError <= 10 && ...
   strcmp(LED.ThermalStatus,'SAFE')

    LED.Status = 'PASS';

else

    LED.Status = 'FAIL';

end

end
