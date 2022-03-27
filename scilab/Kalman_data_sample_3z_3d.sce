clear; xdel(winsid());

mn = 100; //Количество измерений
b_size = mn+1; //Размер буфера

dt = 1;

u = zeros(2,b_size);

a=-2*%pi:0.1:2*%pi;
b=1;//int(2*rand());
c=0.5;//int(1*rand());
d=1;
u(1,:) = b*sin(c*a(1:b_size))+d;

e=0.5;//int(2*rand());
f=0.8;//int(10*rand());
g=0;
u(2,:) = e*sin(f*a(1:b_size))+g;

x = zeros(3,b_size);

x(:,1) = [0 0 0]';

for i = 2:b_size
    x(1,i) = x(1,i-1) - u(1,i)*sin(x(3,i-1))/u(2,i) + u(1,i)*sin(x(3,i-1) + u(2,i)*dt)/u(2,i); //divide by zero!
    x(2,i) = x(2,i-1) + u(1,i)*cos(x(3,i-1))/u(2,i) - u(1,i)*cos(x(3,i-1) + u(2,i)*dt)/u(2,i); //divide by zero!
    x(3,i) = x(3,i-1) + u(2,i)*dt;
end

z = zeros(3,b_size);

r = grand(b_size,"mn",0,0.1);
z(1,:) = r + x(1,:);
q = grand(b_size,"mn",0,0.2);
z(2,:) = q + x(2,:);
w = grand(b_size,"mn",0,0.3);
z(3,:) = w + x(3,:);

deletefile('goo33.txt');
goo=file("open",'goo33.txt')
write(goo,x,'(1(f10.5))');
write(goo,z,'(1(f10.5))');
write(goo,u,'(1(f10.5))');
file("close",goo);

//// Графики ////
figure(1); clf;

subplot(1,2,1);
title('МР')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(x(1,:),x(2,:),'g');
xlabel('x'); ylabel('y'); 
legend('Истинная траектория');

subplot(2,2,2);
title('МР')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:b_size-1,x(1,:),'r');
plot(0:b_size-1,x(2,:),'g');
plot(0:b_size-1,x(3,:),'b');
xlabel('x'); ylabel('y'); 
legend('Истинная траектория');


subplot(2,2,4);
title('МР')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:b_size-1,u(1,:),'r');
plot(0:b_size-1,u(2,:),'g');
xlabel('x'); ylabel('y'); 
legend('Истинная траектория');
