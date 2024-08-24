% fonction classification_foret (pour l'exercice 2)

function Y_pred = classification_foret(foret, X)
    
    pred = zeros(length(foret),length(X));
    for i = 1:length(foret)
        pred(i,:) = predict(foret{i},X);
    end
    Y_pred = mode(pred)';


end
