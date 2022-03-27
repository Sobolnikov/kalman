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

x = zeros(6,b_size);

x(:,1) = [0 0 0 u(1,1) 0 u(2,1)]';

for i = 2:b_size
    x(1,i) = x(1,i-1) - u(1,i)*sin(x(3,i-1))/u(2,i) + u(1,i)*sin(x(3,i-1) + u(2,i)*dt)/u(2,i); //divide by zero!
    x(2,i) = x(2,i-1) + u(1,i)*cos(x(3,i-1))/u(2,i) - u(1,i)*cos(x(3,i-1) + u(2,i)*dt)/u(2,i); //divide by zero!
    x(3,i) = x(3,i-1) + u(2,i)*dt;
    x(4,i) = u(1,i)*cos(x(3,i-1) + u(2,i)*dt);
    x(5,i) = u(1,i)*sin(x(3,i-1) + u(2,i)*dt);
    x(6,i) = u(2,i);
end

//for i = 2:b_size
//    x(1,i) = x(1,i-1) + u(1,i)*cos(x(3,i-1))*dt;
//    x(2,i) = x(2,i-1) + u(1,i)*sin(x(3,i-1))*dt;
//    x(3,i) = x(3,i-1) + u(2,i)*dt;
//    x(4,i) = u(1,i)*cos(x(3,i));
//    x(5,i) = u(1,i)*sin(x(3,i));
//    x(6,i) = u(2,i);
//end

z = zeros(3,b_size);

for i = 1:b_size-1
    z(2,i) = x(4,i)/cos(x(3,i));
end

r = grand(b_size,"mn",0,0.02);
z(1,:) = r + x(3,:);
q = grand(b_size,"mn",0,0.01);
z(2,:) = q + z(2,:);
w = grand(b_size,"mn",0,0.01);
z(3,:) = w + x(6,:);

deletefile('goo36.txt');
goo=file("open",'goo36.txt')
write(goo,x,'(1(f10.5))');
write(goo,u,'(1(f10.5))');
write(goo,z,'(1(f10.5))');
file("close",goo);

//// Графики ////
figure(1); clf;

subplot(2,2,1);
title('МР')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(x(1,:),x(2,:),'g');
xlabel('x'); ylabel('y'); 
legend('Траектория');
comet(x(1,:),x(2,:));

subplot(2,2,3);
title('z')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:b_size-1,z(1,:),'r');
plot(0:b_size-1,z(2,:),'g');
plot(0:b_size-1,z(3,:),'b');
xlabel('z'); ylabel('t'); 
legend('th','V','om');

subplot(2,2,2);
title('МР')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:b_size-1,x(1,:),'r');
plot(0:b_size-1,x(2,:),'g');
plot(0:b_size-1,x(3,:),'b');
xlabel('x'); ylabel('y'); 
legend('x','y','th');


subplot(2,2,4);
title('МР')
set(gca(),"auto_clear","off"); xgrid(1,0.1,10);
plot(0:b_size-1,u(1,:),'r');
plot(0:b_size-1,u(2,:),'g');
plot(0:b_size-1,z(2,:),'g');
plot(0:b_size-1,z(3,:),'b');
xlabel('x'); ylabel('y'); 
legend('uV','uom','V','om');


