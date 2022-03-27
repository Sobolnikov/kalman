
/////////////////////////////////////////////////////////////////////////////////////////////
////Фильтр Калмана.
/////////////////////////////////////////////////////////////////////////////////////////////
clear; xdel(winsid()); //Очистка рабочей области. Удаление графического окна 
//// Параметры  ////

mn = 100; //Количество измерений
b_size = mn+1; //Размер буфера

//чтение данных
data=read('goo33.txt',8*b_size,1);
x(1,:) = data(1:b_size)';          //Вектор состояния
x(2,:) = data(b_size+1:2*b_size)'; //Вектор состояния
x(3,:) = data(2*b_size+1:3*b_size);     //Вектор измерений
z(1,:) = data(3*b_size+1:4*b_size)';          //Вектор состояния
z(2,:) = data(4*b_size+1:5*b_size)'; //Вектор состояния
z(3,:) = data(5*b_size+1:6*b_size);     //Вектор измерений
u(1,:) = data(6*b_size+1:7*b_size)';     //V
u(2,:) = data(7*b_size+1:8*b_size)';     //om

//Исходные данные
dt = 1;          //Интервал дискретизации

x_0 = [0; 
       0;
       0];    //Начальное значение вектора состояния
       
P_0 = [0.01 0       0;       //Начальная матрица ковариаций
       0    0.01    0;
       0    0       0.01];
       
R = [0.01    0      0;
     0      0.01    0;
     0      0      0.01];              //Матрица ковариаций порождающих шумов
     
C = [1 0 0;
     0 1 0; 
     0 0 1];          //Матрица наблюдения / измерений
     
Q = [0.3    0       0;
     0      0.3     0;
     0      0       0.3];            //Матрица ковариаций шумов измерений, дисперсия шума измерений

//C = [1 0 0;
//     0 1 0];          //Матрица наблюдения / измерений
//     
//Q = [0.3    0;
//     0      0.3];            //Матрица ковариаций шумов измерений, дисперсия шума измерений
//     
//C = [1 0 0];          //Матрица наблюдения / измерений
//     
//Q = [0.3];            //Матрица ковариаций шумов измерений, дисперсия шума измерений
      

//Выделение памяти

x_est = zeros(3,b_size); 
P_est = zeros(3,3,b_size);
x_pr = zeros(3,b_size); 
P_pr = zeros(3,3,b_size);
K = zeros(3,3,b_size);
//K = zeros(3,2,b_size);
//K = zeros(3,1, b_size);

//Инициализация алгоритма
x_est(:,1) = x_0;   //Начальное значение вектора состояния
P_est(:,:,1) = P_0; //Начальная матрица ковариаций

//ФК
for i = 2:b_size
    
//    U = [-u(1,i)*sin(x_est(3,i-1))/u(2,i) + u(1,i)*sin(x_est(3,i-1) + u(2,i)*dt)/u(2,i);//divide by zero!
//          u(1,i)*cos(x_est(3,i-1))/u(2,i) - u(1,i)*cos(x_est(3,i-1) + u(2,i)*dt)/u(2,i);//divide by zero!
//          u(2,i)*dt];

    U = [u(1,i)*cos(x_est(3,i-1))*dt;
         u(1,i)*sin(x_est(3,i-1))*dt;
         u(2,i)*dt]; 
          
    x_pr(:,i) = x_est(:,i-1) + U;
//    G = [1 0 -u(1,i)*cos(x_est(3,i-1))/u(2,i) + u(1,i)*cos(x_est(3,i-1) + u(2,i)*dt)/u(2,i); //divide by zero!
//         0 1 -u(1,i)*sin(x_est(3,i-1))/u(2,i) + u(1,i)*sin(x_est(3,i-1) + u(2,i)*dt)/u(2,i); //divide by zero!
//         0 0  u(2,i)*dt];

    G = [1 0 -u(1,i)*sin(x_est(3,i-1));
         0 1  u(1,i)*cos(x_est(3,i-1));
         0 0  1];
         
    P_pr(:,:,i) = G*P_est(:,:,i-1)*G' + R; // Матрица ковариаций прогноза

    K(:,:,i) = P_pr(:,:,i)*C'*inv(C*P_pr(:,:,i)*C' + Q); // Коэфициент усиления
    x_est(:,i) = x_pr(:,i) + K(:,:,i)*(z(:,i) - C*x_pr(:,i)); // Оценка
    P_est(:,:,i) = (eye() - K(:,:,i)*C)*P_pr(:,:,i);
end

//Действительные ошибки оценивания
//x_est_err = x_est(1,:)-x(1,:);
//Vx_est_err = x_est(2,:)-x(2,:);
//y_est_err = x_est(1,:)-x(1,:);
//Vy_est_err = x_est(2,:)-x(2,:);

//// Графики ////
figure(1); clf;

subplot(2,2,1);
title('x')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(1,:),'b');
plot(0:mn,z(1,:),'r*');
plot(0:mn,x_est(1,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');

subplot(2,2,2);
title('y')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(2,:),'b');
plot(0:mn,z(2,:),'r*');
plot(0:mn,x_est(2,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');




subplot(2,2,3);
title('theta')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:mn,x(3,:),'b');
plot(0:mn,z(3,:),'r*');
plot(0:mn,x_est(3,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');

subplot(2,2,4);
title('Trajectory')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(x(1,:),x(2,:),'b');
plot(z(1,:),z(2,:),'r*');
plot(x_est(1,:),x_est(2,:),'g');
xlabel('Время (c)'); ylabel('Высота (м)'); 
legend('Истинная траектория','Измерения','Оценка','   ');

//figure(2); clf;
//
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

