clear;
clc;

nJob = 10;                                          %numero di job
p = int16(unifrnd(1,50,[nJob 3]));         %processing time job i su macchina k
w1 = int16(unifrnd(0,50,[1 nJob]));                %waiting time del job i tra macchina 1 e 2

%processing time sommato da utilizzare in johnson (2 macchine invece di 3)
for i = 1:nJob
    Pf(i,1) = p(i,1) + p(i,2);          %Pf = p first
    Pf(i,2) = p(i,2) + p(i,3);
end

%Algoritmo di Johnson (slide lez04_MES_technologies)
%passo 1
Pf2 = Pf;       %copio Pf in modo da poter sovrascrivere liberamente Pf2
k = 1;
L = nJob;
%passo 2
unscheduled = [1:nJob];
scheduled = zeros(1,nJob);

while ~isempty(unscheduled)
    %passo 3
     if min(Pf2) ~= 200         %200 >> 100 (limite massimo teorico processing time)
         mina = find(Pf2(:,1) == min(Pf2(:,1)),1);      %trovo l'indice del minimo di p1
         minb = find(Pf2(:,2) == min(Pf2(:,2)),1);      %trovo l'indice del minimo di p2
     end
    %passo 4
    if Pf2(mina,1) < Pf2(minb,2)
        scheduled(k) =  unscheduled(find(unscheduled == mina,1));       %aggiungo elemento allo scheduling
        unscheduled(find(unscheduled == mina)) = [];                               %lo rimuovo dalla lista dei job unscheduled
        k = k + 1;                                                                                            %incremento k
        Pf2(mina,1) = 200;                                                                            %sovrascrivo il proc. time del job schedulizzato
        Pf2(mina, 2) = 200;                                                                           %sovrascrivo il proc. time del job schedulizzato
    %passo 5
    elseif Pf2(minb,2) < Pf2(mina,1)
        scheduled(L) =  unscheduled(find(unscheduled == minb,1));           %aggiungo elemento allo scheduling
        unscheduled(find(unscheduled == minb)) = [];                                   %lo rimuovo dalla lista dei job unscheduled
        L = L - 1;                                                                                                %Decremento L
        Pf2(minb,1) = 200;                                                                                %sovrascrivo il proc. time del job schedulizzato
        Pf2(minb, 2) = 200;                                                                               %sovrascrivo il proc. time del job schedulizzato
    else    %caso in cui mina = minb
        if k > nJob-L     %se ci sono meno elementi a sinistra rispetto a destra
            scheduled(L) =  unscheduled(find(unscheduled == minb,1));           
            unscheduled(find(unscheduled == minb)) = [];                               
            L = L - 1;
            Pf2(minb,1) = 200;
            Pf2(minb, 2) = 200;
        else                   %viceversa
            scheduled(k) =  unscheduled(find(unscheduled == mina,1));         
             unscheduled(find(unscheduled == mina)) = [];                            
            k = k + 1;
            Pf2(mina,1) = 200;
            Pf2(mina, 2) = 200;
        end
    end
    %passo 6: prosegui finchè la lista degli unscheduled non è vuota
end

C = Inf(size(Pf,1),size(Pf,2));                     %completion time sulla macchina k per ogni job i
S = Inf(size(Pf,1),size(Pf,2));                     %starting time su ogni macchina k per ogni job i

%macchina 1
time = 0;
for i = 1:nJob
    S(scheduled(i),1) = time;
    C(scheduled(i),1) = time + Pf(scheduled(i), 1);
    time = time + Pf(scheduled(i), 1);
end

%macchina 2
S(scheduled(1),2)= C(scheduled(1),1) + w1(scheduled(1));            %starting time primo job = completion time su m1 + w1
C(scheduled(1),2) = S(scheduled(1),2) + Pf(scheduled(1), 2);        %completion time primo job
for i=2:nJob
    if(C(scheduled(i),1) + w1(scheduled(i))) >= C(scheduled(i-1),2)         %se al termine del waiting time la macchina è libera
        S(scheduled(i),2) = C(scheduled(i),1) + w1(scheduled(i));
    else                                                                                                           %altrimenti se non è libera esegui al termine del job precedente
        S(scheduled(i),2) = C(scheduled(i-1),2);
    end
    C(scheduled(i),2) = S(scheduled(i),2) + Pf(scheduled(i), 2);                %completion time = starting time + processing time
end

%Gantt Chart
M1 = zeros(1,nJob*2);                 %macchina 1
k = 1;
for i = 2:2:nJob*2
    M1(i) = Pf(scheduled(k),1);
    k = k+1;
end

M2 = zeros(1,nJob*2);                  %macchina 2
k = 2;
M2(1) = Pf(scheduled(1),1)+w1(scheduled(1));
M2(2) = Pf(scheduled(1),2);
for i = 3:2:nJob*2
    M2(i) = S(scheduled(k),2) - C(scheduled(k-1),2);
    M2(i+1) = Pf(scheduled(k), 2);
    k = k+1;
end

Positions=[1,2];
Gap_Duration = [M1; M2];
H = barh(Positions,Gap_Duration,'stacked');
set(H([1 3 5 7 9 11 13 15 17 19]),'Visible','off');
