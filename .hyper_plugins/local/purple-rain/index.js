const black        = '#000000';
const red          = '#ff260d';
const green        = '#9ae204';
const yellow       = '#ffc400';
const blue         = '#00a1f9';
const magenta      = '#805bb5';
const cyan         = '#00ddef';
const white        = '#feffff';
const lightBlack   = '#555555';
const lightRed     = '#ff4250';
const lightGreen   = '#b8e36d';
const lightYellow  = '#ffd852';
const lightBlue    = '#00a5ff';
const lightMagenta = '#ab7aef';
const lightCyan    = '#74fcf3';
const lightWhite   = '#feffff';
const cursor       = '#ff261d';
const cursorText   = '#ff261d';
const foreground   = '#fffaf5';
const background   = '#20084a';
const selection    = '#287590';

exports.decorateBrowserOptions = defaults => Object.assign({}, defaults, {
  titleBarStyle: '',
  transparent: true,
  frame: false,
});

exports.decorateConfig = config => Object.assign({}, config, {
    cursorColor: cursor,
    cursorAccentColor: cursorText,
    foregroundColor: foreground,
    backgroundColor: background,
    selectionColor: selection,
    borderColor: 'rgba(255,255,255,0.05)',
    css: `
        ${config.css || ''}
        .tab_tab:before {
            border-left: 1px solid;
        }
        .tab_active {
            background: rgba(255,255,255,0.05);
        }
        .tab_active:before {
            border-color: ${yellow};
        }
    `,
    colors: {
	black,
	red,
	green,
	yellow,
	blue,
	magenta,
	cyan,
	white,
	lightBlack,
	lightRed,
	lightGreen,
	lightYellow,
	lightBlue,
	lightMagenta,
	lightCyan,
	lightWhite
    }
});
