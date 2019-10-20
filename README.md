# Build tmux debian package
    make
    
# Install tmux debian package
    make install
    
# Copy tmux.conf to /etc/tmux.conf
    make copy-conf

# Bash completion
See `bash_completion_tmux.sh` for details.
    
# Uninstall tmux
    make uninstall
    
# Cleanup build environment
    make clean
