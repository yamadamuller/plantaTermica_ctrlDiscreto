clear all;
clc;

%Carregando os dados experimentais
data = load('DADOS_aula.mat');
sensor_temp = data.Temp_C'; %temperaturas registradas
sensor_temp = sensor_temp(2:end);
elapsed_time = data.b';
%pred_elapsed_time = elapsed_time(1:end-1);
med_elapsed_time = elapsed_time(2:end);
pred_elapsed_time = med_elapsed_time;

%Variáveis de controle e condições iniciais
ts = 0.03; %período de amostragem
n_it = size(med_elapsed_time,1);
reg = 2; %num. de regressores
theta(:,1) = zeros(reg,1);
cov(:,:,1) = 1000*eye(length(theta));
y_hat(1) = sensor_temp(1);

for k = 2:n_it
    %montando o vetor de medidas
    psi(:,k) = [y_hat(k-1,1) 1];
    %ganhos
    K(:,k) = cov(:,:,k-1) * psi(:,k)*[1+psi(:,k)'*cov(:,:,k-1)*psi(:,k)]^(-1);
    %Inovação
    n(k) = sensor_temp(k) - psi(:,k)'*theta(:,k-1);
    %Atualização dos Parâmetros
    theta(:,k) = theta(:,k-1) + K(:,k)*n(k);
    %Atualização da matriz covariancia
    cov(:,:,k) = cov(:,:,k-1) - K(:,k)*psi(:,k)'*cov(:,:,k-1);
    
    %Estimativa da saída atual
    y_hat(k,1) = psi(:,k)' * theta(:,k);
end

figure(1)
plot(med_elapsed_time, sensor_temp)
hold on
plot(pred_elapsed_time, y_hat, Color='red')
hold off
xlim([0 2500]);
legend('Sensor', 'MMQR', Location='southeast');
title("Lâmpada: MSE = " + immse(y_hat, sensor_temp));
xlabel("Tempo decorrido [s]");
ylabel("Temperatura [°C]");
