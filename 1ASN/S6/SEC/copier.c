#define _POSIX_C_SOURCE 200809L
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/file.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <signal.h>


#define BUFSIZE 1024


int main(int argc, char const * argv[]){

    if (argc != 3){
        printf("Usage : %s source destination\n\tsource : chemin du fichier source\n\tdestination : chemin de la copie\n",argv[0]);
        exit(EXIT_FAILURE);
    }

    char tampon[BUFSIZE];
    int fd, tube[2], nb_lu;

    if (pipe(tube)==-1){
        perror("pipe");
        exit(EXIT_FAILURE);
    }
    switch (fork()){
    case -1:
        perror("fork");
        exit(EXIT_FAILURE);
        break;
    case 0: //fils lit tube
        close(tube[1]);
        if((fd = open(argv[2], O_WRONLY|O_CREAT, 0644)) == -1){
            perror("open destination");
            exit(EXIT_FAILURE);
        }
        while ((nb_lu = read(tube[0],tampon, sizeof(char)*BUFSIZE)) > 0){
            write(fd,tampon,nb_lu);
        }
        close(fd);close(tube[0]);
        break;
    default: //pere ecrit tube
        close(tube[0]);
        if((fd = open(argv[1],O_RDONLY)) == -1){
            perror("open source");
            exit(EXIT_FAILURE);
        }
        while ((nb_lu = read(fd,tampon, sizeof(char)*BUFSIZE)) >0){
            write(tube[1],tampon,nb_lu);
        }
        close(fd);close(tube[1]);
        break;
    }
    

}
