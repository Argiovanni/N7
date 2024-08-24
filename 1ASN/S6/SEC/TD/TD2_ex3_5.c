#define _POSIX_C_SOURCE 200809L
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>

int cpt_alarm = 0;
int cpt_signal = 0;

void traitementALRM(int sg){
    cpt_alarm ++;
    printf("sigalarm reçu\n");
    alarm(3);
}

void traitementAUTRE(int sg){
    cpt_signal ++;
    printf("signal %d reçu\n",sg);
}

int main(int argc, char const *argv[])
{
    struct sigaction action;
    action.sa_handler = traitementAUTRE;
    sigemptyset(&action.sa_mask);
    action.sa_flags = 0;
    for (int i = 1; i < _NSIG; i++)
    {
        sigaction(i,&action,NULL);
    }
    action.sa_handler = traitementALRM;
    sigemptyset(&action.sa_mask);
    action.sa_flags=0;
    sigaction(SIGALRM,&action,NULL);
    alarm(3);
    while (cpt_alarm < 9 && cpt_signal <5)
    {
        pause();
    }
    
    return EXIT_SUCCESS;
}
