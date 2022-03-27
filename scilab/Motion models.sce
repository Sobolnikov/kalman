clear; xdel(winsid());

b_size = 1000;
dt = 0.01;

x = zeros(3,b_size);
x1 = zeros(3,b_size);
x2 = zeros(3,b_size);

u = [10 0.5]';

x(:,1) = [0 0 0]';

for i = 2:b_size
    x(1,i) = x(1,i-1) + u(1)*cos(x(3,i-1))*dt;
    x(2,i) = x(2,i-1) + u(1)*sin(x(3,i-1))*dt;
    x(3,i) = x(3,i-1) + u(2)*dt;
end

x2(:,1) = [0 0 0]';

for i = 2:b_size
    x2(3,i) = x2(3,i-1) + u(2)*dt;
    x2(1,i) = x2(1,i-1) + u(1)*cos(x2(3,i))*dt;
    x2(2,i) = x2(2,i-1) + u(1)*sin(x2(3,i))*dt;

end

x1(:,1) = [0 0 0]';

for i = 2:b_size
    x1(1,i) = x1(1,i-1) - u(1)*sin(x1(3,i-1))/u(2) + u(1)*sin(x1(3,i-1) + u(2)*dt)/u(2);
    x1(2,i) = x1(2,i-1) + u(1)*cos(x1(3,i-1))/u(2) - u(1)*cos(x1(3,i-1) + u(2)*dt)/u(2);
    x1(3,i) = x1(3,i-1) + u(2)*dt;
end

//// Графики ////
figure(1); clf;

//subplot(2,2,1);
title('МР')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(x(1,:),x(2,:),'g');
plot(x1(1,:),x1(2,:),'r');
plot(x2(1,:),x2(2,:),'b');
xlabel('x'); ylabel('y'); 
legend('Истинная траектория');
