function TF = getFanTF()
%GETFANTF Summary of this function goes here
    load('ArcticP14_TF.mat', 'FanTF');
    TF = FanTF;
end
