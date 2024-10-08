% Fonction estim_param_Dyx_MV_2droites (exercice_2.m) 

function [a_Dyx_1,b_Dyx_1,a_Dyx_2,b_Dyx_2] = ... 
         estim_param_Dyx_MV_2droites(x_donnees_bruitees,y_donnees_bruitees,sigma, ...
                                     tirages_G_1,tirages_psi_1,tirages_G_2,tirages_psi_2)    
    ndata = length(x_donnees_bruitees);

    psi1 = repmat(tirages_psi_1,ndata,1);
    res1 = (y_donnees_bruitees - tirages_G_1(2,:)) ...
            - (x_donnees_bruitees - tirages_G_1(1,:)).*tan(psi1);

    psi2 = repmat(tirages_psi_2,ndata,1);
    res2 = (y_donnees_bruitees - tirages_G_2(2,:)) ...
            - (x_donnees_bruitees - tirages_G_2(1,:)).*tan(psi2);

    [~,index] = max(sum(log(exp((-res1.^2/(2*sigma^2))) ...
                + exp((-res2.^2/(2*sigma^2))))));
    
    psi_d1 = tirages_psi_1(index);
    psi_d2 = tirages_psi_2(index);
    G1 = tirages_G_1(:,index);
    G2 = tirages_G_2(:,index);

    a_Dyx_1 = tan(psi_d1);
    b_Dyx_1 = G1(2) - a_Dyx_1*G1(1);
    a_Dyx_2 = tan(psi_d2);
    b_Dyx_2 = G2(2) - a_Dyx_2*G2(1);

end