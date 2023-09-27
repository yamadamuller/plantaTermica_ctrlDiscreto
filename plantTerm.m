clear all;
clc;
clf;

%hardware info
ino = arduino('COM3', 'UNO');
sensor = "NTC"; 

%PID
set_point = 42; %setpoint temperatura
max_write = 1; %maximo duty aceito
min_write = 0; %minimo duty aceito
u_past = 0; %output passado do PID discreto
u_now = 0; %output atual do PID discreto
err = [set_point set_point]; %vetor de erros passados
Kp = 0.5; %ganho proporcional
Ki = 0.007; %ganho integral
Kd = 0.01; %ganho derivativo
Ts = 1/2; %periodo amostragem (fs = 2Hz)

%teste 
run_iter = intmax; %numero de iterações
T = 1/2; %período do PWM
period = 0; %periodo para controle de plot

for i = 0:run_iter
    tic
    temp = readSensor(ino, sensor, period, set_point); %chama leitura sensor
    period = period + toc; %controle de tempo para plot
    
    err_now = set_point - temp; %termo de erro
    up = Kp*err_now - Kp*err(1);
    ui = Ki*Ts*err_now;
    ud = (Kd/Ts)*err_now - (2*Kd/Ts)*err(1) + (Kd/Ts)*err(2);
    u_now = u_past + up + ui + ud;
    
    figure(1)
    subplot(4,1,2)
    stem(i, up, 'filled', 'red');
    title("Proporcional")
    hold on
    subplot(4,1,3)
    stem(i, ui, 'filled', 'red'); 
    title("Integrativo")
    hold on
    subplot(4,1,4)
    stem(i, ud, 'filled', 'red'); 
    title("Derivativo")
    xlabel("Amostra");
    hold on
    
    %Controle de saturação
    if u_now >= max_write
        u_f = max_write;
    elseif u_now <= min_write
        u_f = min_write;
    else
        u_f = u_now;
    end

    end_time = generatePWM(T, u_f, ino, period);

    err(2) = err(1);
    err(1) = err_now;
    u_past = u_f;

    period = period + end_time;
    Ts = period - end_time;
end 

hold off