% fonction entrainement_foret (pour l'exercice 2)

function foret = entrainement_foret(X,Y,nb_arbres,proportion_individus)

        foret = cell(1,nb_arbres);
        for i = 1:nb_arbres
            n = size(X,1);
            p = randperm(n,n*proportion_individus);
            Xi = X(p,:);
            Yi = Y(p);
            nvr = int32(sqrt(size(X,2)));
            foret{i} = fitctree(Xi,Yi,'NumVariablesToSample',nvr);
        end
        
end
