function syncsshconf
  set script_dir "$HOME/.config/fish/functions/shell_scripts/ssh_config_script"
  if test ! -e "$script_dir/main.sh"
    echo "please run this command."
    echo "git clone https://github.com/kiluhabe/ssh_config_script.git $script_dir"
  end

  sh $script_dir/main.sh $argv
end