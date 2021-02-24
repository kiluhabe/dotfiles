FROM archlinux:latest

RUN \
        pacman -Syy && \
        pacman -S --noconfirm sudo make yes
RUN \
        groupadd -g 1000 test && \
        useradd -m -g test -G wheel -s /bin/bash test && \
        echo 'test:hogehoge' | chpasswd && \
        echo 'Defaults visiblepw'             >> /etc/sudoers && \
        echo 'test ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
