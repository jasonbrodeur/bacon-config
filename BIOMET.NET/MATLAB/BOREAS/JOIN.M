clear
tic
Date1 = 'jun07';
StartTime = 18;
StartHalf = 2;
StopTime = 20;
StopHalf = 1;
TraceNames = 'uvwtchrpg';
TraceName = TraceNames(9);
xx = '_z2';                      % name suffix (sumc01)
Izlaz = 0;
t1 = StartTime;
h1 = StartHalf;
sum = [];
while Izlaz == 0
    x = loadZip1(Date1,t1,h1,TraceName);
    sum = [sum ; x];
    if h1 == 1
        h1 = 2;
    else
        h1 = 1;
    end
    if h1 == 1
        t1 = t1 + 1;
    end 
    if t1 > StopTime | (t1 == StopTime & h1 > StopHalf)
        Izlaz = 1 ;
    end
end
VarName = ['sum' TraceName xx];
eval([VarName ' = sum;']);
clear sum
pack
eval([ 'save ' VarName ' ' VarName ]); 
dos('zip-met');
dos('del *.mat');
toc

    
    
        
        
