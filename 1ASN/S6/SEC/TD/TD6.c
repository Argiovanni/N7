#define _POSIX_C_SOURCE 200809L
# include <unistd.h>
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <ctype.h>
# include <fcntl.h>
# include <stdbool.h>
# include <sys/select.h>
# include <sys/mman.h>
# include <sys/wait.h>


int main(int argc, char const *argv[]){
    
    int fd;
    long taille_page = sysconf(_SC_PAGESIZE);
    if((fd = open("td6.txt",O_WRONLY|O_CREAT,0644)) == -1){
        perror("open");
        exit(EXIT_FAILURE);
    }

    char tab[2*taille_page];
    for (int i = 0; i < 2*taille_page; i++){
        char e = 'a';
        write(fd,&e,1);
    }
    close(fd);

    if ((fd = open("td6.txt", O_RDWR)) == -1){
        perror("open");
        exit(EXIT_FAILURE);
    }
    
    char *base = mmap(NULL,2*taille_page,PROT_READ|PROT_WRITE, MAP_SHARED,fd,0);

    if (base == MAP_FAILED){
        perror("mmap");
        exit(EXIT_FAILURE);
    }
    switch (fork()){
    case -1:
        perror("fork");
        exit(EXIT_FAILURE);
        break;
    case 0:
        sleep(2);
        for (int i = 0; i < 10; i++){
            printf("%c",base[i]);
        }
        for (int i = 0; i < 10; i++){
            printf("%c",base[taille_page+1]);
        }
        for (int i = 0; i < taille_page; i++){
            base[i] = 'c';
        }
        
        exit(EXIT_SUCCESS);
        break;
        
    default:
        for (int i = taille_page; i < 2*taille_page; i++){
            base[i] = 'b';
        }
        wait(NULL);
        for (int i = 0; i < 10; i++){
            printf("%c",base[i]);
        }
        break;
    }
    return 0;
}

