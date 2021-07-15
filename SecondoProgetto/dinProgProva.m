clear;
clc;

%identificatori dei job
J=[1 2 3 4 5 6 7 8 9 10]';
%process time
p= [5 3 6 8 4 12 12 5 3 2]';
%due date
d=[12 60 16 15 9 15 32 20 18 18]';
%minimizzare sommatoria su j di wj*Tj
w=[1 1 1 1.5 1 1 2 1 1.2 3]';

%creo la matrice con tutti gli stati possibili in base al diverso stadio
X0=0;
for i=1:length(J)
    X{i}=combnk(J,i); 
end

%creo la matrice delle precedenze
precedenza =zeros(10,10);
%precedenza(1,3) = 1;
%precedenza(9,10) = 1;

%pruning del primo stadio
%ciclo sulle colonne della matrice di prec.se non ho 1 sulla colonna vuol
%dire che lo stato è ammissibile in quanto non ha precedenze
j=1;
for i=1:length(X{1}(:,1))
    if(sum(precedenza(:,i)) == 0)
        Y{1}(j,:) = X{1}(i,:);
        j = j+1;
    end 
end
%pruning del resto del grafo
%in generale per ogni stadio mi vado a vedere:
%1) per ogni stato se è raggiungibile da quello precedente.
%  2) se lo è allora verifico che rispetto i vincoli ovvero devo
%  controllare se all'interno di questo stato è presente il job della
%  precedenza
    %3) se mi rispetta la precedenza allora è ammissibile e lo posso tenere 
%ciclo tutti gli stadi
for c=2:length(J)
    j=1;
    %ciclo tutte i possibili stati dello stadio c
    for i=1:length(X{c}(:,1))
        count = 0;
        %ciclo gli stati dello stadio precedente
        for k=1:length(Y{c-1}(:,1))
            %se almeno uno stato dello stadio precedente dista di una
            %posizione dallo stato dello stadio attuale allora questo
            %stato è ammissibile a patto che vengano rispettati i 
            %vincoli di precedenza
            if(size(setdiff(X{c}(i,:),Y{c-1}(k,:)))==1)
                count = count + 1;
            end 
        end
        %controllo se questo stato rispetta i vincoli
        if count > 0
            count = 0;
            %ciclo sui job effettuati dallo stato i nello stadio c
            for a=1:length(X{c}(i,:))
                %ciclo le righe della precedenza
                for b=1:length(precedenza(1,:))
                    if(precedenza(b,X{c}(i,a)) ~= 0)
                        %ho un vincolo di precedenza su questo job
                        %controllo che il job che deve essere eseguito prima di lui sia
                        %stato eseguito nello stato considerato
                        if (~ismember(b,X{c}(i,:)))
                            count = count + 1;
                        end
                    end
                end
            end
            if count == 0 %allora ero uno stato ammissimile e me lo tengo
                Y{c}(j,:) = X{c}(i,:);
                j = j+1;
            end
        end
    end%finisce ciclo sugli stati nello stadio c
end

%inizializzo il percorso
for i=1:length(J)
    percorso{i}=0;
end

X = Y;

G{length(J)}=0;
Go{length(J)}=G{length(J)};

%iterativo
for stadio=length(J)-1:-1:1
    stati = factorial(length(J))/(factorial(stadio)*factorial(length(J)-stadio));
    for n=1:stati
        tabella{length(J)-stadio}{2}(n,1) = 1000;
    end
    for i=1:size(X{stadio},1)    %1 sta per le righe che ha X3
        start_time=0;
        %ciclo tra i job presenti in questo stato
        for j=1:size(X{stadio},2)    %2 sta per le colonne che ha X3
            %calcolo lo start time come somma dei process time dei job nello
            %stato analizzato
            start_time=start_time+p(X{stadio}(i,j));
        end
        %calcolo tardiness job di controllo
        for k=1:size(X{stadio+1},1) 
            controllo=setdiff(X{stadio+1}(k,:), X{stadio}(i,:));     %ritorna quale job manca
            if (size(controllo)==1)
                tardiness=max(0,(start_time + p(controllo)- d(controllo)));     %ritardo del job mancante/4
                G{stadio}(i,k)=Go{stadio+1}(k)+w(controllo)*tardiness;
                %la matrice A contiene in 1 i predecessori che sono stati
                %eseguiti, in 2 i costi e in 3 il job che verrà eseguito
                %successivamente
                if(G{stadio}(i,k)<tabella{length(J)-stadio}{2}(i,1))
                    tabella{length(J)-stadio}{1}(i,:) = X{stadio}(i,:);
                    tabella{length(J)-stadio}{2}(i,1) = G{stadio}(i,k);
                    tabella{length(J)-stadio}{3}(i,1) = controllo;
                end
            else
                G{stadio}(i,k)=1000;
            end
        end
        Go{stadio}(i) = min(G{stadio}(i,:));
    end
end

%calcolo il costo minimo e trovo il primo job che viene eseguito
[G1opt, index]= min(Go{1});
G1opt
percorso{1}= X{1}(index,:);
 
for i=1:length(J)-1
    while (percorso{i+1} == 0)
        [costo, index] = min(tabella{length(J)-i}{2}(:,1));
        if (tabella{length(J)-i}{3}(index,1) ~= percorso{i})
            percorso{i+1} = tabella{length(J)-i}{3}(index,1);
        else
            tabella{length(J)-i}{2}(index,1) = 1000;
        end
    end
end

percorso

