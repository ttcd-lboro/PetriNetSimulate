function [t_trans,maskForRepairRates] = AddRestorableTransitionTimes(t_trans,repairRateTable)
maskForRepairRates = zeros(size(t_trans));
if ~isempty(repairRateTable)
    t_trans(repairRateTable.TID) = repairRateTable.Ttime;
    maskForRepairRates(repairRateTable.TID) = true;
end
end