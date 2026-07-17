%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BridgeRectifierModule.m
%
% COMMERCIAL POWER SUPPLY DESIGN CALCULATOR
%
% Calculates all bridge rectifier parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Design Constants

SafetyCurrentFactor = 2.0;      % Recommended diode current margin
SafetyPIVFactor     = 2.5;      % Recommended reverse voltage margin
MaximumJunctionTemp = 125;      % deg C

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Basic Electrical Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.PeakACVoltage = Transformer.PeakVoltage;

Bridge.ForwardVoltagePerDiode = Input.DiodeForwardVoltage;

Bridge.NumberConductingDiodes = 2;

Bridge.TotalForwardDrop = ...
    Bridge.NumberConductingDiodes * ...
    Bridge.ForwardVoltagePerDiode;

Bridge.OutputVoltage = ...
    Bridge.PeakACVoltage - ...
    Bridge.TotalForwardDrop;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Current Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.LoadCurrent = Input.LoadCurrent;

Bridge.DiodeAverageCurrent = ...
    Input.LoadCurrent / 2;

Bridge.DiodeRMSCurrent = ...
    Input.LoadCurrent / sqrt(2);

Bridge.PeakCurrent = ...
    1.8 * Input.LoadCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Peak Inverse Voltage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.MinimumPIV = ...
    Bridge.PeakACVoltage;

Bridge.RecommendedPIV = ...
    ceil((Bridge.MinimumPIV * SafetyPIVFactor)/100)*100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Power Dissipation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.PowerLoss = ...
    Bridge.TotalForwardDrop * ...
    Input.LoadCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rectifier Efficiency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.InputPower = ...
    Bridge.OutputVoltage * ...
    Input.LoadCurrent + ...
    Bridge.PowerLoss;

Bridge.OutputPower = ...
    Bridge.OutputVoltage * ...
    Input.LoadCurrent;

Bridge.Efficiency = ...
    (Bridge.OutputPower / Bridge.InputPower) * 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reverse Voltage Margin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.VoltageMargin = ...
    Bridge.RecommendedPIV - ...
    Bridge.MinimumPIV;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Thermal Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.TemperatureRise = ...
    Bridge.PowerLoss * ...
    Input.ThermalResistance;

Bridge.JunctionTemperature = ...
    Input.AmbientTemperature + ...
    Bridge.TemperatureRise;

Bridge.ThermalMargin = ...
    MaximumJunctionTemp - ...
    Bridge.JunctionTemperature;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Recommended Diode Current Rating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Bridge.RecommendedCurrent = ...
    SafetyCurrentFactor * ...
    Input.LoadCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Bridge Rectifier Selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Bridge.RecommendedCurrent <= 1

    Bridge.RecommendedPart = ...
        '1N4007 (1A,1000V)';

elseif Bridge.RecommendedCurrent <= 2

    Bridge.RecommendedPart = ...
        'KBP206 (2A,600V)';

elseif Bridge.RecommendedCurrent <= 4

    Bridge.RecommendedPart = ...
        'KBP406 (4A,600V)';

elseif Bridge.RecommendedCurrent <= 6

    Bridge.RecommendedPart = ...
        'KBU6M (6A,1000V)';

elseif Bridge.RecommendedCurrent <= 10

    Bridge.RecommendedPart = ...
        'GBU10M (10A,1000V)';

else

    Bridge.RecommendedPart = ...
        'Industrial Bridge Rectifier';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Safe Operating Area Check
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Bridge.JunctionTemperature < MaximumJunctionTemp

    Bridge.ThermalStatus = 'SAFE';

else

    Bridge.ThermalStatus = 'OVERHEATING';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Overall Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Bridge.Efficiency >= 90 && ...
   strcmp(Bridge.ThermalStatus,'SAFE')

    Bridge.Status = 'PASS';

else

    Bridge.Status = 'FAIL';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
fprintf('-----------------------------------------------\n');
fprintf('Bridge Rectifier Module Completed\n');
fprintf('-----------------------------------------------\n');

fprintf('Peak AC Voltage              : %.2f V\n',...
        Bridge.PeakACVoltage);

fprintf('Bridge Forward Drop          : %.2f V\n',...
        Bridge.TotalForwardDrop);

fprintf('Rectified Output Voltage     : %.2f V\n',...
        Bridge.OutputVoltage);

fprintf('Average Diode Current        : %.2f A\n',...
        Bridge.DiodeAverageCurrent);

fprintf('RMS Diode Current            : %.2f A\n',...
        Bridge.DiodeRMSCurrent);

fprintf('Peak Current                 : %.2f A\n',...
        Bridge.PeakCurrent);

fprintf('Minimum PIV                 : %.2f V\n',...
        Bridge.MinimumPIV);

fprintf('Recommended PIV             : %.0f V\n',...
        Bridge.RecommendedPIV);

fprintf('Power Dissipation           : %.2f W\n',...
        Bridge.PowerLoss);

fprintf('Rectifier Efficiency        : %.2f %%\n',...
        Bridge.Efficiency);

fprintf('Temperature Rise            : %.2f C\n',...
        Bridge.TemperatureRise);

fprintf('Junction Temperature        : %.2f C\n',...
        Bridge.JunctionTemperature);

fprintf('Thermal Margin              : %.2f C\n',...
        Bridge.ThermalMargin);

fprintf('Recommended Current Rating  : %.2f A\n',...
        Bridge.RecommendedCurrent);

fprintf('Recommended Bridge          : %s\n',...
        Bridge.RecommendedPart);

fprintf('Thermal Status              : %s\n',...
        Bridge.ThermalStatus);

fprintf('Status                      : %s\n',...
        Bridge.Status);

fprintf('-----------------------------------------------\n');

end
