self: super:
{
   st = super.st.overrideAttrs (old: rec {
     name = "st";
     src = super.fetchgit {
       url = "git://git.suckless.org/st";
       rev = "3be4cf1";
       sha256 = "0i3m7wv0bbagl0gm7mif9sw4mpf6m36i2pr3r21cz31vfjqckwsa";
     };
   });
}
