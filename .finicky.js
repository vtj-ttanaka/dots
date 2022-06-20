module.exports = {
    defaultBrowser: "Safari",
    options: {
        hideIcon: false,
        checkForUpdate: true,
    },
    handlers: [
        {
            match: [
                /^https?:\/\/meet\.google\.com\/.*$/,
                /^https?:\/\/calendar\.google\.com\/.*$/,
                /^https?:\/\/.*\.?aws\.amazon\.com\/.*$/,
                /^https?:\/\/.*\.?datadoghq\.com\/.*$/,
                /^https?:\/\/(www\.)?youtube\.com(\/.*)$/,
                /^https?:\/\/.*\.signin\.aws\.amazon\.com\/.*$/,
            ],
            browser: "Firefox",
        },
        {
            match: /^https?:\/\/zoom\.us\/.*$/,
            browser: "/Applications/zoom.us.app",
        },
    ],
}
