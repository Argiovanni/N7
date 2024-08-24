#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

void copy_file(const char *source, const char *destination) {
    int src_fd, dest_fd;
    struct stat sb;
    char *src, *dest;

    // Ouvrir le fichier source
    src_fd = open(source, O_RDONLY);
    if (src_fd == -1) {
        perror("open source file");
        exit(EXIT_FAILURE);
    }

    // Obtenir la taille du fichier source
    if (fstat(src_fd, &sb) == -1) {
        perror("fstat");
        close(src_fd);
        exit(EXIT_FAILURE);
    }

    // Mapper le fichier source en mémoire
    src = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, src_fd, 0);
    if (src == MAP_FAILED) {
        perror("mmap source");
        close(src_fd);
        exit(EXIT_FAILURE);
    }

    // Ouvrir ou créer le fichier de destination
    dest_fd = open(destination, O_RDWR | O_CREAT | O_TRUNC, sb.st_mode);
    if (dest_fd == -1) {
        perror("open destination file");
        munmap(src, sb.st_size);
        close(src_fd);
        exit(EXIT_FAILURE);
    }

    // Ajuster la taille du fichier de destination
    if (ftruncate(dest_fd, sb.st_size) == -1) {
        perror("ftruncate");
        munmap(src, sb.st_size);
        close(src_fd);
        close(dest_fd);
        exit(EXIT_FAILURE);
    }

    // Mapper le fichier de destination en mémoire
    dest = mmap(NULL, sb.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, dest_fd, 0);
    if (dest == MAP_FAILED) {
        perror("mmap destination");
        munmap(src, sb.st_size);
        close(src_fd);
        close(dest_fd);
        exit(EXIT_FAILURE);
    }

    // Copier le contenu du fichier source vers le fichier de destination
    memcpy(dest, src, sb.st_size);

    // Nettoyer les mappings et fermer les fichiers
    if (munmap(src, sb.st_size) == -1) {
        perror("munmap source");
    }
    if (munmap(dest, sb.st_size) == -1) {
        perror("munmap destination");
    }
    close(src_fd);
    close(dest_fd);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <source> <destination>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    copy_file(argv[1], argv[2]);
    return 0;
}
