with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

-- Piloter un drone au moyen d'un menu textuel.
procedure Drone is

    LIMITE_PORTEE : constant Integer := 5; -- altitude à partir de laquelle
    -- le drone n'est plus à porter (et donc perdu)
    Altitude : Integer; -- l'altitude du drone
    En_Route : Boolean; -- Est-ce que le drone a été démarré ?
    Est_Perdu : Boolean; -- Est-ce que le drone est perdu ?
    Choix: Character; -- le choix de l'utilisateur
    Quitter: Boolean; -- Est-ce que l'utilisateur veut quitter ?

begin
    -- Initialiser le drone
    En_Route := False;
    Est_Perdu := False;
    Altitude := 0;
    Quitter := False;
    loop
        -- Afficher l'altitude du drone
        New_Line;
        Put ("Altitude : ");
        Put (Altitude, 1);
        New_Line;
        -- Afficher le menu
        New_Line;
        Put_Line ("Que faire ?");
        Put_Line (" d -- Démarrer");
        Put_Line (" m -- Monter");
        Put_Line (" s -- Descendre");
        Put_Line (" q -- Quitter");
        -- Demander le choix de l'utilisateur
        Put ("Votre choix : ");
        Get (Choix);
        Skip_Line;
        -- Traiter le choix de l'utilisateur
        case Choix is
            when 'd' | 'D' => -- Démarrer
                -- Mettre le drone en route
                En_Route := True;
            when 'm' | 'M' => -- Monter
                -- Faire monter le drone
                if En_Route then
                    Altitude := Altitude + 1;
                else
                    Put_Line ("Le drone n'est pas démarré.");
                end if;
                Est_Perdu := Altitude >= LIMITE_PORTEE;
            when 's' | 'S' => -- Descendre
                -- Faire descendre le drone
                if En_Route then
                    if Altitude > 0 then
                        Altitude := Altitude - 1;
                    else
                        Put_Line ("Le drone est déjà posé.");
                    end if;
                else
                    Put_Line ("Le drone n'est pas démarré.");
                end if;
            when 'q' | 'Q' | '0' => -- Quitter
                Quitter := True;
            when others => -- Ordre inconnu
                Put_Line ("Je n'ai pas compris !");
        end case;

        exit when Quitter or else Est_Perdu;
    end loop;

    -- Afficher les raisons de l'arrêt
    New_Line;
    if Est_Perdu then
        Put_Line ("Le drone est hors de portée... et donc perdu !");
    elsif not En_Route then
        Put_Line ("Vous n'avez pas réussi à le mettre en route ?");
    else
        Put_Line ("Au revoir...");
    end if;
    
end Drone;