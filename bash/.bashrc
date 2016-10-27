#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

setup_droid_dev_env() {
    # Search and export {ANDROID,NDK}_HOME variables
    export ANDROID_HOME=`find /opt -maxdepth 1 -type d -name '*android-sdk*'`
    export NDK_HOME=`find /opt -maxdepth 1 -type d -name '*android-ndk*'`
    # Pick first android build tools directory and add it to path with the platform tools directory
    local ANDROID_BUILD_TOOLS_BIN=`find $ANDROID_HOME/build-tools -maxdepth 1 -mindepth 1 -type d | sort -r | head -n 1`
    export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_BUILD_TOOLS_BIN
    # Pick first ndk toolchain and add it to path
    local NDK_TOOLCHAIN_PATH=`find $NDK_HOME/toolchains -maxdepth 1 -type d -name 'arm-linux-*' | sort -r | head -n 1`
    export PATH=$PATH:$NDK_TOOLCHAIN_PATH/prebuilt/linux-x86_64/bin
}

export HISTSIZE=3000
export EDITOR=vim
export PATH=$PATH:$HOME/.cabal/bin
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Setup needed environment variables for Android development
setup_droid_dev_env

# Disable STAHP combo
stty -ixon
