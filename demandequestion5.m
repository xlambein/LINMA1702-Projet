function [fval,x,f,A,b,Aeq,beqvrai]= demandequestion5( donnees ,epsilon,temps)

if nargin <2
    epsilon = 0;
end
%parametre d'optimisation
semaine = donnees.T;
if nargin > 2
    semaine = temps;
end
d_t = donnees.demande;
c_m = donnees.cout_materiaux;
c_s = donnees.cout_stockage;
d_a = donnees.duree_assemblage/60;
n_o = donnees.nb_ouvriers;
c_h = donnees.cout_horaire;
n_h = 35;
c_r = donnees.cout_retard;
c_hs= donnees.cout_heure_sup;
n_hs= donnees.nb_max_heure_sup;
c_st= donnees.cout_sous_traitant;
s_i = donnees.stock_initial;
n_max_st = donnees.nb_max_sous_traitant;
c_e = donnees.cout_embauche;
c_l = donnees.cout_licenciement;
nb_o = donnees.nb_max_ouvriers;
delta = donnees.delta_demande;
d_t = d_t + epsilon * delta;
n_max = n_h * n_o / d_a;
nhs_max = n_hs * n_o /d_a;

%cr�ation de f � optimiser
f=zeros(8*semaine+1,1);
for i=1:semaine
    f(i,1)=c_m;
end

for i=semaine+1:2*semaine
    f(i,1)=c_m + d_a / 60 * c_hs;
end

for i=2*semaine+1: 3*semaine
    f(i,1)=c_st;
end

for i=3*semaine+2:4*semaine+1
    f(i,1)=c_s;
end

for i=4*semaine+2:5*semaine+1
    f(i,1)=c_r;
end

for i=5*semaine+2 : 6*semaine+1
    f(i,1) = c_h;
end

for i=6*semaine+2 : 7*semaine+1
    f(i,1) = c_e;
end

for i=7*semaine+2 : 8*semaine+1
    f(i,1) = c_l;
end



%Contraintes telles que Ax <= b
%cr�ation de la matrice A
A=zeros(12*semaine,8*semaine+1);
for i=1:semaine-1 %r^(t+1) <= d_t(i)
    A(i, i+4*semaine+2)=1;
    
end 


count=1;
for i=semaine : 2*semaine-1 % contrainte n_t <= n_h * n_o_t /d_a
    A(i,count)=1;
    A(i,count+5*semaine+1)= -n_h / d_a;
    count = count + 1;
end

count=semaine+1;
for i=2*semaine : 3*semaine-1 % nhs_t <= nhs * no_t /d_a
    A(i,count)=1;
    A(i,count+4*semaine+1)= -n_hs / d_a;
    count = count + 1; ;
end

count = 2*semaine+1;
for i=3*semaine:4*semaine-1% n_st <= n_max_st 
   A(i, count) = 1;
   count = count +1;
end

count=1;
for i=4*semaine:12*semaine %variables plus grandes que 0
    A(i,count)=-1;
    count = count +1;
end
%A
%size(A)


%cr�ation de la matrice b
b=zeros(12*semaine,1);
for i=1:semaine-1
    b(i)= d_t(i);
end

for i=3*semaine:4*semaine-1% n_st <= n_max_st 
   b(i) = n_max_st;
end
%for i=1:2*semaine %premiere contrainte
%  b(i)=d_t;
%end
% for i=semaine+1:(2*semaine) %2eme
%     b(i)= n_max;
%
% end
%
% for i =2*semaine+1: 3*semaine %3eme contrainte
%     b(i)= nhs_max;
% end
%b(5*semaine+1) = s_i;
%b(5*semaine+2) = s_i;
%b(5*semaine+3) = s_i;
%b(5*semaine+4) = s_i;
%b
%size(A)
%size(f)
%size(transpose(f))
%size(b)


%Contraintes tellles que Aeq * x = beq

Aeq=zeros(2*semaine+2,8*semaine+1);
for i=1:semaine-1 %n_t + nhs_t +ns_t + s_t-1 - s_t -r_t +r_t+1 = d_t(i)
    Aeq(i ,i)=1;
    Aeq(i, i+semaine)=1;
    Aeq(i, i+2*semaine)=1;
    Aeq(i, i+3*semaine)=1;
    Aeq(i, i+3*semaine+1)=-1;
    Aeq(i, i+4*semaine+1)=-1;
    Aeq(i, i+4*semaine+2)=1;
end %premiere contrainte pour les semaines sauf la derniere

for i=semaine:semaine %n_t + nhs_t +ns_t + s_t-1 - s_t -r_t + 0 = d_t(T)
   Aeq(i ,i)=1;
   Aeq(i, i+semaine)=1;
   Aeq(i, i+2*semaine)=1;
   Aeq(i, i+3*semaine)=1;
   Aeq(i, i+3*semaine+1)=-1;
   Aeq(i, i+4*semaine+1)=-1;
  
end %premiere contrainte pour la derniere semaine

Aeq(semaine+1,3*semaine+1)=1;
Aeq(semaine+2,4*semaine+1)=1;
Aeq(semaine+3,4*semaine+2)=1;

%Contraintes rajout�es par la question 7 %no_t - no_t-1 = ne_t - nl_t
count = 5*semaine+2;
if(semaine > 1)
    for i=semaine+4 : 2*semaine +2
        Aeq(i,count)=-1;
        Aeq(i,count+1)= 1;
        Aeq(i,count+semaine+1)=-1;
        Aeq(i,count + 2*semaine+1) = 1;
        count = count +1;
    end
end

beq = zeros(1,2*semaine+2);
for i=1:semaine %n_t + nhs_t +ns_t + s_t-1 - s_t -r_t +r_t+1 = d_t(i)
                %n_t + nhs_t +ns_t + s_t-1 - s_t -r_t + 0 = d_t(T)
    beq(i)=d_t(i);
end
for i=semaine+1:semaine+2 %s_0 = s_i + s_t = s_i
    beq(i)=s_i;
end
for i=semaine+3:semaine+3 %r_1 = 0
    beq(i)=0;
end


beqvrai=beq.';

options=optimoptions(@linprog,'Algorithm','dual-simplex');
[x,fval,exiflag, output, lambda]=linprog(transpose(f),A,b,Aeq,beq.',[],[],[],options);




end




