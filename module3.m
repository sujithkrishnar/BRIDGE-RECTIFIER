%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CapacitorModule.m
%
% COMMERCIAL POWER SUPPLY DESIGN CALCULATOR
%
% Calculates smoothing capacitor parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Design Constants

SafetyVoltageFactor = 1.50;
MaximumRippleVoltage = Input.AllowedRipple;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ripple Frequency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.RippleFrequency = ...
    2 * Input.Frequency;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Required Capacitance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.RequiredCapacitance = ...
    (Input.LoadCurrent / ...
    (Capacitor.RippleFrequency * MaximumRippleVoltage)) ...
    *1e6;          % uF

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Standard Capacitor Selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

StandardCaps = [470 680 1000 1500 2200 3300 ...
                4700 6800 8200 10000 ...
                15000 22000];

Index = find(StandardCaps >= ...
             Capacitor.RequiredCapacitance,1);

if isempty(Index)

    Capacitor.RecommendedCapacitance = ...
        StandardCaps(end);

else

    Capacitor.RecommendedCapacitance = ...
        StandardCaps(Index);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Ripple Voltage Using Recommended Capacitor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.ActualRipple = ...
    Input.LoadCurrent / ...
    (Capacitor.RippleFrequency * ...
    (Capacitor.RecommendedCapacitance/1e6));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Capacitor Ripple Current
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.RippleCurrent = ...
    1.8 * Input.LoadCurrent;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ESR Power Loss
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.ESR = ...
    Input.CapacitorESR;

Capacitor.PowerLoss = ...
    Capacitor.RippleCurrent^2 * ...
    Capacitor.ESR;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Energy Stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BridgeVoltage = Bridge.OutputVoltage;

Capacitor.StoredEnergy = ...
    0.5 * ...
    (Capacitor.RecommendedCapacitance/1e6) * ...
    BridgeVoltage^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Time Constant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.LoadResistance = ...
    Bridge.OutputVoltage / Input.LoadCurrent;

Capacitor.TimeConstant = ...
    Capacitor.LoadResistance * ...
    (Capacitor.RecommendedCapacitance/1e6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Capacitor Voltage Rating
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.MinimumVoltage = ...
    Bridge.OutputVoltage;

VoltageRequired = ...
    Bridge.OutputVoltage * SafetyVoltageFactor;

if VoltageRequired <=16

    Capacitor.VoltageRating=16;

elseif VoltageRequired<=25

    Capacitor.VoltageRating=25;

elseif VoltageRequired<=35

    Capacitor.VoltageRating=35;

elseif VoltageRequired<=50

    Capacitor.VoltageRating=50;

else

    Capacitor.VoltageRating=63;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Capacitor Lifetime Estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ReferenceLife = 2000;      % hours
ReferenceTemp = 105;       % deg C

OperatingTemp = ...
    Input.AmbientTemperature + 15;

Capacitor.EstimatedLife = ...
    ReferenceLife * ...
    2^((ReferenceTemp-OperatingTemp)/10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Capacitor Charge Time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.ChargeTime = ...
    5 * Capacitor.TimeConstant;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Capacitor Discharge Time
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Capacitor.DischargeTime = ...
    Capacitor.TimeConstant;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Safety Checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Capacitor.ActualRipple <= MaximumRippleVoltage

    RippleStatus='PASS';

else

    RippleStatus='FAIL';

end

if Capacitor.PowerLoss<2

    ESRStatus='PASS';

else

    ESRStatus='FAIL';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Overall Status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(RippleStatus,'PASS') && ...
   strcmp(ESRStatus,'PASS')

    Capacitor.Status='PASS';

else

    Capacitor.Status='FAIL';

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\n');
fprintf('-----------------------------------------------\n');
fprintf('Capacitor Module Completed\n');
fprintf('-----------------------------------------------\n');

fprintf('Ripple Frequency            : %.2f Hz\n', ...
        Capacitor.RippleFrequency);

fprintf('Required Capacitance        : %.0f uF\n', ...
        Capacitor.RequiredCapacitance);

fprintf('Recommended Capacitor       : %.0f uF\n', ...
        Capacitor.RecommendedCapacitance);

fprintf('Actual Ripple Voltage       : %.2f Vpp\n', ...
        Capacitor.ActualRipple);

fprintf('Ripple Current             : %.2f A\n', ...
        Capacitor.RippleCurrent);

fprintf('ESR                        : %.3f Ohm\n', ...
        Capacitor.ESR);

fprintf('Capacitor Loss             : %.3f W\n', ...
        Capacitor.PowerLoss);

fprintf('Stored Energy              : %.3f J\n', ...
        Capacitor.StoredEnergy);

fprintf('Time Constant              : %.3f s\n', ...
        Capacitor.TimeConstant);

fprintf('Charge Time                : %.3f s\n', ...
        Capacitor.ChargeTime);

fprintf('Discharge Time             : %.3f s\n', ...
        Capacitor.DischargeTime);

fprintf('Voltage Rating             : %d V\n', ...
        Capacitor.VoltageRating);

fprintf('Estimated Life             : %.0f hours\n', ...
        Capacitor.EstimatedLife);

fprintf('Status                     : %s\n', ...
        Capacitor.Status);

fprintf('-----------------------------------------------\n');

end
