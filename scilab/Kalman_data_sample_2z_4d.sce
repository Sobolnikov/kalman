clear; xdel(winsid())

a=-2*%pi:0.1:2*%pi;
dt=1;

n_var = 30;

//for j = 1:n_var
 y = zeros(2, 126);
 b=int(10*rand());
 c=int(10*rand());
 d=10;
 y(1,:) = b*sin(c*a)+d;
 e=int(10*rand());
 f=int(10*rand());
 g=5;
 y(2,:) = e*sin(f*a)+g;
 
 size = 101;
 x = zeros(6, size); 
 x(2,:) = y(1,1:size);
 x(1,1) = 0;
 x(5,:) = y(2,1:size);
 x(4,1) = 0;

 for i = 2:size
     x(1,i) = x(1,i-1) + dt*x(2,i-1);
     x(4,i) = x(4,i-1) + dt*x(5,i-1);
 end
 
 r = grand(size,"mn",0,0.1);
 x(3,:) = r + x(1,:);
 q = grand(size,"mn",0,0.2);
 x(6,:) = q + x(4,:);
 
 deletefile('goo24.txt');
 write('goo24.txt',x,'(1(f10.5))');
 
 //deletefile('goo'+ string(j) +'.txt');
 //write('goo'+ string(j) +'.txt',x,'(1(f10.5))');
//end

plot2d(1:size,x(1,:));
plot2d(1:size,x(2,:));
plot2d(1:size,x(3,:));
plot2d(1:size,x(6,:));
