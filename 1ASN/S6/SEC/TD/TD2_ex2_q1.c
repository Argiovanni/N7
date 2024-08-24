#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char const *argv[])
{
    pid_t pid = fork();
    switch (pid)
    {
    case -1:
        perror("fork");
        exit(1);
        break;
    case 0:
        execl("/bin/ls",'ls','-l',NULL);
        execlp("ls","ls",'-l',NULL);
        perror("execlp ls");
        exit(EXIT_FAILURE);
        break;
    default:
        int status;
        pid_t pid_wait;
        pid_wait = (&status);
        if (WIFEXITED(status)){
            printf(" code retour de [%d] : %d",pid_wait,status);
        }   
        break;
    }
    return EXIT_SUCCESS;
}
