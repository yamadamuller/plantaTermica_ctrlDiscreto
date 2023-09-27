function elapsed_time = generatePWM(T, cycle, ino, plt_period)
    Tau = T*cycle; %periodo em que o PWM é 5V
    elapsed_time = 0; %contador de tempo para plot
    while(elapsed_time < Tau) %5V equanto time < Tau
        tic
        writeDigitalPin(ino, 'D6', 0); 
%         figure(1)
%         subplot(2,1,2)
%         stem(elapsed_time + plt_period, 5, 'filled', 'blue'); 
%         title("PWM")
%         xlabel("Tempo decorrido [s]");
%         ylabel("Tensão [V]");
%         ylim([0 5.1])
%         hold on
        elapsed_time = elapsed_time + toc;
    end
    
    while(elapsed_time >= Tau && elapsed_time < T) %0V enquanto Tau < time < T
        tic
        writeDigitalPin(ino, 'D6', 1);
%         figure(1)
%         subplot(2,1,2)
%         stem(elapsed_time + plt_period, 0, 'filled', 'blue');
%         title("PWM")
%         xlabel("Tempo decorrido [s]");
%         ylabel("Tensão [V]");
%         ylim([0 5.1])
%         hold on
        elapsed_time = elapsed_time + toc;
    end

    %fprintf("PWM tempo = %d \n", elapsed_time);
end