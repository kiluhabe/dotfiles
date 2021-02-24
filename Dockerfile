FROM archlinux:latest

RUN \
        pacman-db-upgrade && \
        pacman -Syy && \
        pacman -S --noconfirm sudo make
RUN \
        groupadd -g 1000 test && \
        useradd -m -g test -G wheel -s /bin/bash test && \
        echo 'test:hogehoge' | chpasswd && \
        echo 'Defaults visiblepw'             >> /etc/sudoers && \
        echo 'test ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
