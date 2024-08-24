#define _POSIX_C_SOURCE 200809L
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/file.h>
#include <stdlib.h>
#include <stdio.h>
#include "readcmd.h"
#include <stdbool.h>
#include <string.h>
#include <signal.h>


#define LECTURE 0
#define ECRITURE 1

bool backgrounded = false;

void traitementSIGCHILD(int sg){
    int wstatus;
    pid_t pid_retour = waitpid(-1, &wstatus, 0 | WCONTINUED | WNOHANG | WUNTRACED);
    if (WIFSTOPPED(wstatus)){
        printf("processus [%d] est stoppé\n",pid_retour);
    } else if (WIFCONTINUED(wstatus)){
        printf("processus [%d] est continué\n",pid_retour);
    } else if (WIFSIGNALED(wstatus)){
        printf("processus [%d] a envoyé un signal : %d\n",pid_retour, wstatus);
    } else if (WIFEXITED(wstatus)){
        printf("processus [%d] terminé avec le code %d\n",pid_retour,wstatus);
    }
    fprintf(stderr,"\n> "); // permet parfois d'avoir un affichage plus 'jolie'
}


int main(void) {
    bool fini= false;
    pid_t pid_fork;                                
    struct sigaction action;

    printf("> ");

    while (!fini) {
        //ignore les signaux d'intéruptions
        signal(SIGINT, SIG_IGN);
        signal(SIGTSTP, SIG_IGN);

        struct cmdline *commande= readcmd();

        if (commande == NULL) {
            // commande == NULL -> erreur readcmd()
            perror("erreur lecture commande \n");
            exit(EXIT_FAILURE);
    
        } else {

            if (commande->err) {
                // commande->err != NULL -> commande->seq == NULL
                printf("erreur saisie de la commande : %s\n", commande->err);
        
            } else {
                int indexseq = 0, fd;
                int nb_fork = 0;
                char **cmd;
                int nb_seq = 0;
                while (commande->seq[nb_seq+1] != NULL){
                    nb_seq ++;
                }
                
                int tube[nb_seq][2]; // tableau de tube

                //on créer les tubes
                for (int i = 0; i < nb_seq; i++){
                    if(pipe(tube[i]) ==-1){
                        perror("pipe");
                        exit(EXIT_FAILURE);
                    }
                }
                

                while ((cmd= commande->seq[indexseq])) {
                    if (cmd[0]) {
                        if (strcmp(cmd[0], "exit") == 0) {
                            fini= true;
                            printf("Au revoir ...\n");
                            return EXIT_SUCCESS;
                        }
                        else {

                            pid_fork = fork();
                            nb_fork ++;
                            switch (pid_fork){
                            case -1:
                                perror("error fork");
                                exit(EXIT_FAILURE);
                                break;
                            case 0: 
                                // fils

                                // "réactive" les signaux d'intérruptions
                                signal(SIGINT, SIG_DFL);
                                signal(SIGTSTP, SIG_DFL);
                                if (commande->backgrounded != 0){
                                    setpgrp();
                                }

                                // redirection
                                if (commande->in != NULL){
                                    fd = open(commande->in, O_RDONLY);
                                    dup2(fd, 0);
                                    close(fd);
                                }
                                if (commande->out != NULL){
                                    fd = open(commande->out, O_WRONLY|O_APPEND|O_CREAT, 0644);
                                    dup2(fd, 1);
                                    close(fd);
                                }


                                /* on créé la pipeline */
                                // on ferme les tube inutile (i.e. indexseq et indexseq-1)
                                for (int j = 0; j < nb_seq; j++){
                                    if (j != indexseq && j != indexseq-1){
                                        close(tube[j][LECTURE]);
                                        close(tube[j][ECRITURE]);
                                    }
                                }
                                // redirection des flux
                                if (commande->seq[indexseq+1] != NULL){ // il y a une cmd a pipe
                                    dup2(tube[indexseq][ECRITURE],STDOUT_FILENO); // on map la sortie du fils sur l'entrée du tube
                                    close(tube[indexseq][ECRITURE]);
                                    close(tube[indexseq][LECTURE]);
                                }
                                
                                if (indexseq != 0){ // pas la première cmd
                                    dup2(tube[indexseq-1][LECTURE],STDIN_FILENO); // on map l'entrée du fils sur la sortie du tube d'avant
                                    close(tube[indexseq-1][ECRITURE]);
                                    close(tube[indexseq-1][LECTURE]);
                                }

                                // execution
                                execvp(cmd[0],cmd);
                                perror("execvp");
                                exit(EXIT_FAILURE);
                                break;
                            default:
                                // père
                                action.sa_handler = traitementSIGCHILD;
                                sigemptyset(&action.sa_mask);
                                action.sa_flags = SA_RESTART;
                                sigaction(SIGCHLD,&action, NULL);
                                break;
                            }   
                        }
                        indexseq++;
                    }
                } // fin while
                // ferme tous les tubes
                for (int k = 0; k < nb_seq; k++){
                    close(tube[k][ECRITURE]);
                    close(tube[k][LECTURE]);
                }
                // attend la fin de tous les processus fils si la cmd n'est pas en bg
                if (commande->backgrounded == 0){
                    backgrounded = false;
                    for (int nbchild = 0; nbchild < nb_seq; nbchild++){
                        pause();
                    }
                } else {
                    backgrounded = true;
                }
                fprintf(stderr,"\n> "); // permet parfois d'avoir un affichage plus 'jolie'
            }   
        }   
    }
    return EXIT_SUCCESS;
}
