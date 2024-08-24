#define _POSIX_C_SOURCE 200809L
#include <sys/types.h>
#include <sys/file.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define TAILLE 1024

int main(int argc, char const *argv[]){ // cmd cat
    char tampon[TAILLE];
    int lus;
    if (argc==1){
        while ((lus = read(STDIN_FILENO,tampon,TAILLE) )> 0){
            write(STDOUT_FILENO,tampon,lus);    
        }
    } else {
        for (int i = 1; i < argc; i++){
            int fd = open(argv[i],O_RDONLY);
            while ((lus = read(fd,tampon,TAILLE) )> 0){
                write(STDOUT_FILENO,tampon,lus); 
            }
            close(fd);
        }
    }
    return 0;
}

