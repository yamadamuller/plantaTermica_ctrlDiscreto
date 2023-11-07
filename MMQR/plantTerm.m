clear all;
clc;
%clf;

%hardware info
ino = arduino('COM3', 'UNO');
sensor = "NTC"; 

%PID
set_point = 50; %setpoint temperatura
max_write = 1; %maximo duty aceito
min_write = 0; %minimo duty aceito
u_past = 0.5; %output passado do PID discreto
u_now = 0; %output atual do PID discreto
err = [0 0]; %vetor de erros passados
Kp = 5.12; %ganho proporcional
Ki = 14.19; %ganho integral
Kd = 0.26; %ganho derivativo
Ts = 0.6; %periodo amostragem 
Taw = sqrt((Kp/Ki)*(Kd/Kp)); %Constante de tempo anti-windup
eaw = 0; %erro limitador
end_time = 0; %controle de plot

%teste 
run_iter = intmax; %numero de iterações
T = 0.3; %período do PWM
period(1) = 0; %periodo para controle de plot
temp(1) = 0; %vetor das temperaturas
up(1) = 0; %vetor da ação proporcional
ui(1) = 0; %vetor da ação integral
ud(1) = 0; %vetor da ação derivativa

%Criando objeto de plot para acelerar as leituras a cada loop
figure(1)
subplot(4,1,1)
temp_plot = plot(period, temp); % Guarda as informações do plot para atualização depois
set(temp_plot,'LineWidth', 1);
title('Resposta do Sistema');
ylabel("Temperatura [°C]");
ylim([0 60]);
yline(set_point,'red')
legend('Sensor', 'Setpoint', Location='southeast');

subplot(4,1,2)
temp_plot2 = plot(period, up, Color='magenta');
set(temp_plot2,'LineWidth', 1);
title('Ação proporcional');

subplot(4,1,3)
temp_plot3 = plot(period, ui, Color='magenta');
title('Ação integral');
set(temp_plot3,'LineWidth', 1);

subplot(4,1,4)
temp_plot4 = plot(period, ud, Color='magenta');
set(temp_plot4,'LineWidth', 1);
title('Ação derivativa');
xlabel("Tempo decorrido [s]");

%Variáveis de controle para o algoritmo MMQR
transp_delay = 0.228; %tempo morto
reg = 2;
theta(:,1) = zeros(reg,1);
cov(:,:,1) = 1000*eye(length(theta));

for i = 2:run_iter
    tic
    temp(i) = readSensor(ino, sensor); %chama leitura sensor
    period(i) = period(i-1) + toc; %controle de tempo para plot
    period(i) = period(i) + end_time;
    
    %Algoritmo MMQR (Mínimos quadrados recursivo)
    psi(:,i) = [temp(i-1) u_past]; %vetor de medidas
    K(:,i) = cov(:,:,i-1) * psi(:,i)*[1+psi(:,i)'*...
        cov(:,:,i-1)*psi(:,i)]^(-1); %ganhos
    n(i) = temp(i) - psi(:,i)'*theta(:,i-1); %inovação
    theta(:,i) = theta(:,i-1) + K(:,i)*n(i); %atualizando os param.
    cov(:,:,i) = cov(:,:,i-1) - K(:,i)*psi(:,i)'*cov(:,:,i-1); %covariancia

    if period(i) >= 10 %controle adapativo aciona apenas a partir de 10s
        %Atualizando os ganhos do PID por Ziegler-Nihcols
        Tau = (theta(1,i)*Ts)/(1-theta(1,i)); %tempo para atingir 0.63A
        K_proc = ((theta(2,i)*Tau) + (theta(2,i)*Ts))/Ts; %ganho de proc.
        Kp = (1.2*Tau)/(K_proc*transp_delay); %ganho proporcional
        Ki = Kp/(2*transp_delay); %ganho integral
        Kd = 0.5*Kp*transp_delay; %ganho derivativo
        Taw = sqrt((Kp/Ki)*(Kd/Kp)); %atualiza constante de tempo anti-windup
    end

    err_now = set_point - temp(i); %termo de erro
    up(i) = Kp*err_now - Kp*err(1); %ação proporcional
    ui(i) = ui(i-1) + Ki*Ts*err_now + (Ts/Taw)*eaw; %ação integral
    %ui(i) = Ki*Ts*err_now; %ação integral
    ud(i) = (Kd/Ts)*err_now - (2*Kd/Ts)*err(1) + (Kd/Ts)*err(2); %ação der.
    u_now = u_past + up(i) + ui(i) + ud(i); %saída do PID
    
    %Plots
    set(temp_plot, 'XData', period, 'YData', temp); 
    set(temp_plot2, 'XData', period, 'YData', up); 
    set(temp_plot3, 'XData', period, 'YData', ui); 
    set(temp_plot4, 'XData', period, 'YData', ud); 
    drawnow; 

    %Controle de saturação
    if u_now >= max_write
        u_f = max_write;
    elseif u_now <= min_write
        u_f = min_write;
    else
        u_f = u_now;
    end
    
    end_time = generatePWM(T, u_f, ino);
    
    %Comutando variáveis para próxima iteração
    err(2) = err(1);
    err(1) = err_now;
    u_past = u_f; 
    eaw = u_f - u_now;
    
    Ts = period(i) - period(i-1); %atualiza o perído de amostragem
end 
