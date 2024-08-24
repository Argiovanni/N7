#define _POSIX_C_SOURCE 200809L
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <stdbool.h>
#include <sys/select.h>

int main(int argc, char const *argv[]){
    int tube[2];
    int buff_w[10];
    for (int i = 0; i < 10; i++){
        buff_w[i] = i+1;
    }
    buff_w[7] = -8;
    
    pipe(tube);
    switch (fork()){
    case -1:
        perror("fork");
        exit(EXIT_FAILURE);
        break;
    case 0: // fils
        close(tube[1]);
        int buff_r, to_prt;

        while((to_prt = read(tube[0],&buff_r,sizeof(int))) > 0){
            printf("read as returned : %d\n",to_prt);
        }
        close(tube[0]);
        printf("sortie de boucle\n");
        break;
    
    default:
        close(tube[0]);
        for (int i = 0; i < 10; i++){
            if (write(tube[1],buff_w[i],sizeof(int))<0){
                perror("write tube[1]");
                close(tube[1]);
                exit(EXIT_FAILURE);
            }
        }
        close(tube[1]);
        pause();
        break;
    }
    return 0;
}
