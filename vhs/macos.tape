Output macos.gif

#Set Framerate 15

Set FontSize 20
Set Width 1200
Set Height 1000
Set WindowBar Colorful
Set BorderRadius 1

# Hide setup
Hide
Set TypingSpeed 0ms
# macOS
Type "export PS1='hpci000000@MacOS ~ % '" Enter

Type "source ./hook-brew.sh" Enter
Type "clear" Enter
Show

Set TypingSpeed 50ms

Type "brew tap hpci-auth/tap" Enter
Sleep 8s

Type "brew install hpcissh" Enter
Sleep 15s

Type "hpcissh-version" Enter
Sleep 5s

Type "brew tap indigo-dc/oidc-agent" Enter
Sleep 8s

Type "brew install oidc-agent" Enter
Sleep 20s
