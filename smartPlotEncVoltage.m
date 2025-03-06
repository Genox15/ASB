function [isProper] = smartPlotEncVoltage(data,filename,filter)
% rows:
% 1 = timestamps
% 2 = encoder 0
% 3 = encoder 1
% 4 = motor Volt 0
% 5 = motor Volt 1
Ts = 0.002;
CheckTime = 1.5;
CheckIndex = int32(CheckTime/Ts);

if size(data,1)>3 && size(data,2)>CheckIndex

    isProper = true;
    
    if abs(data(4,CheckIndex)) > abs(data(5,CheckIndex))
        motorId = 0;
    else 
        motorId = 1;
    end
    
    motorV = data(4+motorId,CheckIndex);
    t = data(1,:); % get timeline

    if filter   
        gridRows = 3;
    else
        gridRows = 2;
    end
    f = figure;
    subplot(gridRows,1,1);
        hold on;
        plot(t ,data(2,:)/(2048/pi));
        plot(t ,data(3,:)/(2048/pi));
        ylabel("rad");
        xlabel("time (s)");
        hold off
        sgtitle(filename,'Interpreter','none');
        title('Encoders');
        subtitle("Motor"+motorId+" at: " + motorV + "V" );
        legend(["Enc 0","Enc 1"],'Location','northwest');
    subplot(gridRows,1,2); 
        hold on;
        plot(t ,data(4,:));
        plot(t ,data(5,:));
        ylabel("V");
        xlabel("time (s)");
        hold off
        title('Motor Inputs');
        legend(["M 0","M 1"],'Location','northwest');

     if filter
        f.Position(3:4) = [500 700];
        e = data(2+motorId,:)*pi/2048; % get "excitated" motor
        pole1 = 2*pi*50;
        pole2 = 2*pi*50;
        derivAndLowPass = zpk([0],[-pole1 -pole2],(pole1 * pole2));
        subplot(gridRows,1,3); 
            hold on;
            ls = lsimplot(derivAndLowPass,e,t);
            ls.ylim([-5 5]);
            ls.title("Estimated ang. speed");
            ls.ylabel("omega_L (rad/s)");
            hold off;
    end  

else 
    isProper = false;
end