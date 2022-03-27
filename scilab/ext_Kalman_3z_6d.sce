
/////////////////////////////////////////////////////////////////////////////////////////////
////Фильтр Калмана.
/////////////////////////////////////////////////////////////////////////////////////////////
clear; xdel(winsid()); //Очистка рабочей области. Удаление графического окна 
//// Параметры  ////

mn = 100; //Количество измерений
b_size = mn+1; //Размер буфера

//чтение данных
data=read('goo36.txt',11*b_size,1);
x(1,:) = data(1:b_size);          //Вектор состояния
x(2,:) = data(b_size+1:2*b_size); //Вектор состояния
x(3,:) = data(2*b_size+1:3*b_size);     //Вектор измерений
x(4,:) = data(3*b_size+1:4*b_size);          //Вектор состояния
x(5,:) = data(4*b_size+1:5*b_size); //Вектор состояния
x(6,:) = data(5*b_size+1:6*b_size);     //Вектор измерений
u(1,:) = data(6*b_size+1:7*b_size);     //V
u(2,:) = data(7*b_size+1:8*b_size);     //om
z(1,:) = data(8*b_size+1:9*b_size);     //Вектор измерений
z(2,:) = data(9*b_size+1:10*b_size);     //V
z(3,:) = data(10*b_size+1:11*b_size);     //om

//Исходные данные
dt = 1;          //Интервал дискретизации

//Начальное значение вектора состояни размерностью n
//x_0 = [0;   //x
//       0;   //y
//       0;   //th
//       0;   //Vx
//       0;   //Vy
//       0];  //om
       
x_0 = [x(1,1);   //x
       x(2,1);   //y
       x(3,1);   //th
       x(4,1);   //Vx
       x(5,1);   //Vy
       x(6,1)];  //om
       
P_0 = [0.01    0       0       0       0       0;
       0       0.01    0       0       0       0;
       0       0       0.01    0       0       0;
       0       0       0       0.01    0       0;
       0       0       0       0       0.01    0;
       0       0       0       0       0       0.01];       //Начальная матрица ковариаций размерностью nxn
       
R =   [0.9    0       0       0       0       0;
       0       0.9    0       0       0       0;
       0       0       0.1    0       0       0;
       0       0       0       0.1    0       0;
       0       0       0       0       0.1    0;
       0       0       0       0       0      0.1];              //Матрица ковариаций порождающих шумов размерностью nxn
       
//R =   [9999   0       0       0       0       0;
//       0       9999    0       0       0       0;
//       0       0       9999    0       0       0;
//       0       0       0       9999    0       0;
//       0       0       0       0       9999    0;
//       0       0       0       0       0       9999];              //Матрица ковариаций порождающих шумов размерностью nxn
     
//     
Q = [0.1    0       0;
     0      0.1     0;
     0      0       0.1];            //Матрица ковариаций шумов измерений, дисперсия шума измерений размерностью mxm
     
//Q = [99999    0       0;
//     0      99999     0;
//     0      0       99999];            //Матрица ковариаций шумов измерений, дисперсия шума измерений размерностью mxm
//       

//Выделение памяти

x_est = zeros(6,b_size); 
P_est = zeros(6,6,b_size);
x_pr = zeros(6,b_size); 
P_pr = zeros(6,6,b_size);
K = zeros(6,3,b_size); // коэффициент Калмана размерностью nxm

//Инициализация алгоритма
x_est(:,1) = x_0;   //Начальное значение вектора состояния
P_est(:,:,1) = P_0; //Начальная матрица ковариаций

//ФК
for i = 2:b_size

//Экстраполяция

//    x_pr(:,i) = [x_est(1,i-1) + u(1,i)/u(2,i)*(-sin(x_est(3,i-1)) + sin(x_est(3,i-1) + u(2,i)));  //divide by zero!
//                 x_est(2,i-1) + u(1,i)/u(2,i)*(cos(x_est(3,i-1)) - cos(x_est(3,i-1) + u(2,i)));  //divide by zero!
//                 x_est(3,i-1) + u(2,i)*dt
//                 u(1,i)*cos(x_est(3,i-1) + u(2,i)*dt);
//                 u(1,i)*sin(x_est(3,i-1) + u(2,i)*dt);
//                 u(2,i)];
//
    x_pr(:,i) = [x_est(1,i-1) + u(1,i)*cos(x_est(3,i-1))*dt;
                 x_est(2,i-1) + u(1,i)*sin(x_est(3,i-1))*dt;
                 x_est(3,i-1) + u(2,i)*dt;
                 u(1,i)*cos(x_est(3,i-1) + u(2,i)*dt);
                 u(1,i)*sin(x_est(3,i-1) + u(2,i)*dt);
                 u(2,i)]; 

//    G = [1  0   u(1,i)/u(2,i)*(-cos(x_est(3,i-1)) + cos(x_est(3,i-1) + u(2,i)*dt))    0   0   0;
//         0  1   u(1,i)/u(2,i)*(-sin(x_est(3,i-1)) + sin(x_est(3,i-1) + u(2,i)*dt))    0   0   0;
//         0  0   1                           0   0   0;
//         0  0  -u(1,i)*sin(x_est(3,i-1))    0   0   0;
//         0  0   u(1,i)*cos(x_est(3,i-1))    0   0   0;
//         0  0   0                           0   0   0];
//
    G = [1  0   -u(1,i)*sin(x_est(3,i-1))*dt   0   0   0;
         0  1   u(1,i)*cos(x_est(3,i-1))*dt    0   0   0;
         0  0   1                              0   0   0;
         0  0   -u(1,i)*sin(x_est(3,i-1))      0   0   0;
         0  0   u(1,i)*cos(x_est(3,i-1))       0   0   0;
         0  0   0                              0   0   0];
//         
    P_pr(:,:,i) = G*P_est(:,:,i-1)*G' + R; // Матрица ковариаций прогноза
    
    
// Коррекция
    
    H = [0  0   1                                            0                   0   0;
         0  0   x_pr(4,i)*sin(x_pr(3,i))*(cos(x_pr(3,i))^-2) cos(x_pr(3,i))^-1   0   0;  //divide by zero!
         0  0   0                                            0                   0   1];
         

    K(:,:,i) = P_pr(:,:,i)*H'*inv(H*P_pr(:,:,i)*H' + Q); // Коэфициент усиления Inverse matrix
    
    h = [x_pr(3,i);
         x_pr(4,i)/cos(x_pr(3,i));      //divide by zero!
         x_pr(6,i)];
    
    x_est(:,i) = x_pr(:,i) + K(:,:,i)*(z(:,i) - h); // Оценка
    P_est(:,:,i) = (eye() - K(:,:,i)*H)*P_pr(:,:,i);
end

//Действительные ошибки оценивания
//x_est_err = x_est(1,:)-x(1,:);
//Vx_est_err = x_est(2,:)-x(2,:);
//y_est_err = x_est(1,:)-x(1,:);
//Vy_est_err = x_est(2,:)-x(2,:);

//// Графики ////
figure(1); clf;

subplot(3,2,1);
title('x')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(1,:),'b');
plot(0:mn,x_est(1,:),'g');
plot(0:mn,x_pr(1,:),'go');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');

subplot(3,2,2);
title('y')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(2,:),'b');
plot(0:mn,x_pr(2,:),'go');
plot(0:mn,x_est(2,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');


subplot(3,2,3);
title('theta')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(3,:),'b');
plot(0:mn,z(1,:),'r*');
plot(0:mn,x_pr(3,:),'go');
plot(0:mn,x_est(3,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка экстр','Оценка коррекции');

subplot(3,2,4);
title('Vx')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(4,:),'b');
plot(0:mn,x_pr(4,:),'go');
plot(0:mn,x_est(4,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Оценка экстр','Оценка коррекции');

subplot(3,2,5);
title('Vy')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(5,:),'b');
plot(0:mn,x_pr(5,:),'go');
plot(0:mn,x_est(5,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');

subplot(3,2,6);
title('om')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(6,:),'b');
plot(0:mn,z(3,:),'r*');
plot(0:mn,x_pr(6,:),'go');
plot(0:mn,x_est(6,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');


figure(2); clf;

title('Trajectory')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(x(1,:),x(2,:),'b');
plot(x_est(1,:),x_est(2,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('x-y','x-y Оценка');



//subplot(1,2,1); set(gca(),"auto_clear","off"); xgrid(1,0.1,10); title('СКО вертикальной скорости')
//plot(0:mn,3*sqrt(squeeze(P_est(2,2,:)))','r');
//plot(0:mn,3*sqrt(Q(2,2))*ones(1,b_size),'b');
//plot(0:mn,y_est_err,'g')
//plot(0:mn,-3*sqrt(squeeze(P_est(2,2,:)))','r');
//plot(0:mn,-3*sqrt(Q(2,2))*ones(1,b_size),'b');
//ylabel('СКО (м/с)'); xlabel('Время (c)');
//legend('3 sigma оценки','Действительная ошибка');
//
//subplot(1,2,2); set(gca(),"auto_clear","off"); xgrid(1,0.1,10); title('СКО высоты')
//plot(0:mn,3*sqrt(squeeze(P_est(1,1,:)))','r');
//plot(0:mn,3*sqrt(Q(1,1))*ones(1,b_size),'b');
//plot(0:mn,x_est_err,'g');
//plot(0:mn,-3*sqrt(squeeze(P_est(1,1,:)))','r');
//plot(0:mn,-3*sqrt(Q(1,1))*ones(1,b_size),'b');
//ylabel('СКО (м)'); xlabel('Время (c)');
//legend('3 sigma оценки','3 sigma измерений','Действительная ошибка');
//
//mprintf('Отношение СКО погрешности оценивания \nк СКО погрешности измерений: %f / %f = %f \n',sqrt(P_est(1,1,$)),sqrt(Q),sqrt(P_est(1,1,$))/sqrt(Q));
//mprintf('Оценка высоты на 50 секунде полета: %f\n',x_est(1,51));

