if [ -d /etc/x11/xinit/xinitrc.d ]; then
  for f in /etc/x11/xinit/xinitrc.d/*? ; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

if [ -e $(which light 2>/dev/null) ]; then
    light -S 10
fi

if [ -e $(which kr 2>/dev/null) ]; then
    kr restart
fi

exec i3
