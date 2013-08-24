#NOTE: .pydistutils.cfg seems to be not compatible with brew install python
#areas I needed to clean before installation
#clean up ~/Library/Python
#clean up .local
brew install python --framework
easy_install pip
pip install virtualenv
pip install virtualenvwrapper
mkdir $HOME/.virtualenvs
#### example .bash_profile
#homebrew
export PATH=/usr/local/bin:/usr/local/sbin:${PATH}
# homebrew python 2.7
export PATH="/usr/local/share/python:${PATH}"
#virtualenv wrapper
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/share/python/virtualenvwrapper.sh
