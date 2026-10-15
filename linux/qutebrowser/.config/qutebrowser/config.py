import catppuccin

config.load_autoconfig()
catppuccin.setup(c, 'mocha', True)

# Arreglo para Google Sign In
config.set('content.headers.user_agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36')


# Pestañas
c.tabs.padding = {
    'top': 5,
    'bottom': 5,
    'left': 8,
    'right': 8,
}
c.fonts.tabs.selected = '11pt Maple Mono NF'
c.fonts.tabs.unselected = '10pt Maple Mono NF'

# Intento de arreglo de Gemini/Claude
config.bind('<Escape>', 'mode-leave ;; jseval -q -w main window.__quteFix?.blur()', mode='insert')
config.bind('<Escape>', 'clear-keychain ;; search ;; fullscreen --leave ;; jseval -q -w main window.__quteFix?.blur()', mode='normal')
config.bind('G',  'jseval -q -w main window.__quteFix?.bottom() || window.scrollTo(0, 1e9)')
config.bind('gg', 'jseval -q -w main window.__quteFix?.top() || window.scrollTo(0, 0)')


# Keymaps
config.bind( 'J', 'tab-prev', mode='normal')
config.bind( 'K', 'tab-next', mode='normal')
config.bind( 'b', 'cmd-set-text -s :open', mode='normal')
config.bind( 'B', 'cmd-set-text -s :open -t', mode='normal')

config.bind(',ss', 'set-cmd-text -s :session-save --force ')
config.bind(',sl', 'set-cmd-text -s :session-load -c ')
config.bind('<Ctrl-r>', 'config-source ;; message-info "Configuración recargada"')
