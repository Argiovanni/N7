#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/file.h>

int main(int argc, char const *argv[]){ // cmd who | grep nom_utilisateur
    if (argc != 2){
        printf("Usage : %s nom_utilisateur\n",argv[0]);
        exit(EXIT_FAILURE);
    }
    int tube[2];
    if(pipe(tube) == -1){
        perror("pipe");
        exit(EXIT_FAILURE);
    }
    switch (fork()){
    case -1:
        perror("fork");
        exit(EXIT_FAILURE);
        break;
    case 0: //fils lit
        // grep argv[1]
        if(close(tube[1]) ==-1){
            perror("close tube[1]");
            exit(EXIT_FAILURE);
        }
        dup2(tube[0],STDIN_FILENO);
        execlp("grep","grep",argv[1],NULL);
        close(tube[0]);
        break;
    
    default: //pere ecrit
        // who
        close(tube[0]);
        dup2(tube[1],STDOUT_FILENO);
        close(tube[1]);
        execlp("who","who",NULL);
        wait(NULL);
        break;
    }
    
    return 0;
}
