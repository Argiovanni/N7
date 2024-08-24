#define _POSIX_C_SOURCE 200809L
#include <sys/types.h>
#include <sys/file.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>


#define TAILLE 1024


int main(int argc, char const *argv[]){ // cmd cp src dest

    if (argc != 3){
        fprintf(STDERR_FILENO,"Usage : %s source destination\n\tsource : chemin du fichier source\n\tdestination : chemin de la copie\n",argv[0]);
        exit(EXIT_FAILURE);
    }
    int dest;
    if(dest = open(argv[2],O_WRONLY|O_CREAT,0644)){
        perror("overture destination");
        exit(EXIT_FAILURE);
    }
    if(dup2(dest,STDIN_FILENO) == -1){
        perror("dup2");
        exit(EXIT_FAILURE);
    }
    if (close(dest)==-1){
        perror("close dest");
        exit(EXIT_FAILURE);
    }
    
    execlp("cat","cat",argv[1],NULL);
    perror("execlp cat source");
    exit(EXIT_FAILURE);

    return 0;
}

 