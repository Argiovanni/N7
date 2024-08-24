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
    switch (fork()){
    case -1:
        perror("fork");
        exit(EXIT_FAILURE);
        break;
    case 0: // fils
        int buff;
        close(tube[1]);
        read(tube[0],&buff,sizeof(int));
        printf("%d",buff);
        close(tube[0]);
        break;
    default: // père
        int buff = 6;
        pipe(tube);
        close(tube[0]);
        write(tube[1],&buff,sizeof(int));
        close(tube[1]);
        break;
    }
    return 0;
}
