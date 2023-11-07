function elapsed_time = generatePWM(T, cycle, ino)
    Tau = T*cycle; %periodo em que o PWM é 5V
    elapsed_time = 0; %contador de tempo para plot
    while(elapsed_time < Tau) %5V equanto time < Tau
        tic
        writeDigitalPin(ino, 'D6', 0); 
        elapsed_time = elapsed_time + toc;
    end
    
    while(elapsed_time >= Tau && elapsed_time < T) %0V enquanto Tau < time < T
        tic
        writeDigitalPin(ino, 'D6', 1);
        elapsed_time = elapsed_time + toc;
    end
end