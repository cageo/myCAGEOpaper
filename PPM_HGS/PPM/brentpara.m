%
% This function solves npara 1D optimization problems in parallel
%
% Author: Celine Scheidt
% Date: May 2011
% Adapted from Fortran code from Todd Hoffman

function [xmin,brent,rD,OF,OF_regions] = brentpara(ax,bx,cx,tol,npara,brent,of_threshold,head_objfun)

%% Input parameters
%   - ax: minimum value of rD (0)
%   - bx: starting value for rD (vector, one value for each region) 
%   - cx: maximum value for rD (vector, one value for each region) (1)
%   - tol: tolerence on the OF
%   - npara: number of rD (or number of regions)
%   - brent: OF value at the initial realization (can be a vector - one value of OF per region)

%% Output parameters
%   - xmin: optimal value of rD optained during optimization
%   - brent: optimal objective function optained during optimization
%   - rD: vector containing all the rD evaluated during the optimization
%        (including 0 - for the initial model)
%   - OF: vector containing all the objective functions evaluated during
%         the optimization
%   - OF_regions: vector containing all the objective function per region 

d = zeros(1,npara); u = zeros(1,npara);

% c
% c Initialize all npara parameters
% c

ITMAX=5;
% T.H. Parameters for Brent optimization???
CGOLD=.3819660;
ZEPS=1.0e-10;

rD = repmat(0,1,npara);
OF = sum(brent);
OF_regions = brent;
brent = sum(brent);

% T.H. What are all those parameters?
a=min(ax,cx);
b=max(ax,cx);
v=bx;
w=v;
x=v;
e=zeros(1,npara);

brent_old = sum(brent);

% c
% c Here we call the objective function with all npara parameters stored in x
% c

iiter=1;

% T.H. Calculation of the objective function for the first value
fx = head_objfun(x); %x=rD
fprintf('Initial realization, OF = %f \n',sum(fx))

brent = sum(fx);  % current objective function
iiter=iiter+1;

rD = [rD,x];
OF = [OF,brent];
OF_regions = horzcat(OF_regions,fx');

if brent < of_threshold
    xmin = x;
    return
end

fv=fx;
fw=fx;

% c
% c First search for a new set of parameters
% c 
iswitch = 0;
iter = 1;
while (iter < ITMAX && iswitch == 0)
    
    imdone = 0;
    xm=0.5*(a+b);
    tol1=tol*abs(x)+ZEPS;
    tol2=2.*tol1;
    for np = 1:npara
        if(abs(x(np)-xm(np))<=(tol2(np)-.5*(b(np)-a(np))))  % can be simplified I believe!
            imdone = imdone+1;
        end
    end
    if (imdone == npara)
        %goto 3       
        xmin = x;
        break;    
    end
    
    for np = 1:npara
        if (abs(e(np)) > tol1(np))
            r=(x(np)-w(np))*(fx(np)-fv(np));
			q=(x(np)-v(np))*(fx(np)-fw(np));
			p=(x(np)-v(np))*q-(x(np)-w(np))*r;
			q=2.*(q-r);
            if(q > 0)
                p=-p;
            end
            q=abs(q);
			etemp=e(np);
			e(np)=d(np);
            if (abs(p)>=abs(.5*q*etemp) || p <= q*(a(np)-x(np)) || p >= q*(b(np)-x(np))) 
                % below is step 1
                if(x(np)>=xm(np))
                    e(np)=a(np)-x(np);
                else
                    e(np)=b(np)-x(np);
                end
                d(np)=CGOLD*e(np);
                % below is step 2
                if(abs(d(np))>= tol1(np))
                    u(np)=x(np)+d(np);
                else
                    u(np)=x(np)+sign_fortran(tol1(np),d(np));
                end
            else
                % what happens if you don't go to step 1
                d(np)=p/q;
				u(np)=x(np)+d(np);
                if(u(np)-a(np) < tol2(np)  || b(np)-u(np)< tol2(np)) 
                    d(np)=sign_fortran(tol1(np),xm(np)-x(np));
                    if(abs(d(np)) >= tol1(np));
                        u(np)=x(np)+d(np);
                    else
                        u(np)=x(np)+sign_fortran(tol1(np),d(np));
                    end
                end
            end
        end 
        if(x(np) >= xm(np))
            e(np)=a(np)-x(np);
        else
            e(np)=b(np)-x(np);
        end
        d(np)=CGOLD*e(np);
        if(abs(d(np)) >= tol1(np))
            u(np)=x(np)+d(np);
        else
            u(np)=x(np)+sign_fortran(tol1(np),d(np));
        end
    end
       
            
    % c      
    % c Evaluate the function in these parameters
    % c
    fu = head_objfun(u); %x=rD       
    fprintf('Finished iteration # %i \n',iiter);   
    fprintf('rD =  # %f \n',u);   

    iiter=iiter+1;
    
    % c
    % c Now decide, for each parameter, on the next 3 values used for parabolic interpolation
    % c
    
    for np = 1:npara       
        if(fu(np) <= fx(np))
            if(u(np)>= x(np))
                a(np)=x(np);
            else
                b(np)=x(np);
            end
            v(np)=w(np);
            fv(np)=fw(np);
            w(np)=x(np);
            fw(np)=fx(np);
            x(np)=u(np);
            fx(np)=fu(np);
        else
            if(u(np) < x(np))
                a(np)=u(np);
            else
                b(np)=u(np);
            end
            if(fu(np) <= fw(np) || w(np) == x(np))
                v(np)=w(np);
                fv(np)=fw(np);
                w(np)=u(np);
                fw(np)=fu(np);
            elseif(fu(np)<=fv(np) || v(np) == x(np) ||v(np) == w(np))
                v(np)=u(np);
				fv(np)=fu(np);
            end
        end
    end
    
    brent1 = sum(fu);
    fprintf('iteration OF = %f \n ', brent1)
    
    rD = [rD,u];
    OF = [OF,brent1];
    OF_regions = horzcat(OF_regions,fu');
    
    if (brent1 < brent)
        fprintf('kept this inner iteration %d \n', iiter-1);
		fprintf('old OF = %f - new of= %f \n', brent, brent1);
		brent=brent1;
    end
    if(iter == 2)
        if(brent > (brent_old))
            iswitch=1;
        end
    end
    if (brent < of_threshold)
        iswitch=1;
    end
        
    iter = iter + 1;
end

xmin = x;

          
        
        
end