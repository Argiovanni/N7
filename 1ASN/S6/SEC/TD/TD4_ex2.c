#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/file.h>

int main(int argc, char const *argv[]){
    if (argc != 2){
        printf("Usage : %s n\n\tn : entier\n",argv[0]);
        exit(EXIT_FAILURE);
    }
    int n = atoi(argv[1]);
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
        if(close(tube[1]) ==-1){
            perror("close tube[1]");
            exit(EXIT_FAILURE);
        }
        int sum = 0;
        int val;
        while (read(tube[0], &val, sizeof(int)) > 0){
            sum += val;
        }
        printf("somme = %d\n", sum);
        close(tube[0]);
        break;
    
    default: //pere ecrit
        close(tube[0]);
        for (int i = 1; i <= n; i++){
            if(write(tube[1], &i, sizeof(int))<0){
                perror("write tube[1]");
                close(tube[1]);
                exit(EXIT_FAILURE);
            }
        }
        close(tube[1]);
        wait(NULL);
        break;
    }
    
    return 0;
}
