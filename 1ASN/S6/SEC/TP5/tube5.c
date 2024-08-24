#define _POSIX_C_SOURCE 200809L
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <stdbool.h>
#include <sys/select.h>

#define N 10

int main(int argc, char const *argv[]){
    int tube[2];
    int buff_w[N];
    for (int i = 0; i < N; i++){
        buff_w[i] = i+1;
    }
    pipe(tube);

    switch (fork()){
    case -1:
        perror("fork");
        exit(EXIT_FAILURE);
        break;
    case 0: // fils
        close(tube[1]);
        int buff_r[10 * N], to_prt;

        while((read(tube[0],&buff_r,N * 10 *sizeof(int))) > 0){
            NULL;
        }
        
        close(tube[0]);
        break;
    
    default:
        close(tube[0]);
        while(true){
            int write_return;
            if ((write_return = write(tube[1],buff_w,N*sizeof(int)))<0){
                perror("write tube[1]");
                close(tube[1]);
                exit(EXIT_FAILURE);
            } else {
                sleep(1);
                printf("write returned : %d", write_return);
            }
            
        }
        close(tube[1]);
        break;
    }
    return 0;
}
