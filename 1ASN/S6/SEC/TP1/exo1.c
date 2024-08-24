#define _POSIX_C_SOURCE 200809L
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

int main(int argc, char *argv[]) {
    int tempsPere, tempsFils;
    pid_t pid_fork;
    int variable= 0;
    int status;

    tempsPere= 40;
    tempsFils= 20;

    pid_fork= fork();
    // bonne pratique : tester systématiquement le retour des primitives
    if (pid_fork == -1) {
        printf("Erreur fork\n");
        exit(1);
        /* par convention, renvoyer une valeur > 0 en cas d'erreur,
         * différente pour chaque cause d'erreur, ici 1 = erreur fork
         */
    }
    if (pid_fork == 0) {		/* fils */
        variable = 10;
        printf("fils: processus %d, de père %d et code du fork %d\n", 
                    getpid(), getppid(), pid_fork);
        printf("fils: variable = %d\n", variable);
        sleep(tempsFils);
        printf("fin du fils, variable = %d\n", variable);
        exit(EXIT_SUCCESS); 
        /* 	bonne pratique : 
        	terminer les processus par un exit explicite */
    }
    else {		/* père */
        variable = 100;
        printf("père: processus %d, de père %d et code du fork %d\n", 
                    getpid(), getppid(), pid_fork);
        printf("pere: variable = %d\n", variable);
        pid_t pid_wait;
        if((pid_wait = wait(&status)) != -1){
            if (WIFEXITED(status)){
                printf ( " Le processus fils % d s ’ est terminé avec le code %i\n", pid_wait , WEXITSTATUS ( status ) ) ;
            } else if ( WIFSIGNALED ( status ) ){
                printf ( " Le processus fils % d s ’ est terminé par le signal %i\n", pid_wait , WTERMSIG ( status ) ) ;
            }
        }
        printf("fin du père, variable = %d\n",variable);        
    }
    return EXIT_SUCCESS; /* -> exit(EXIT_SUCCESS); pour le père */
}