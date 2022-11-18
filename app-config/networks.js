const mainnet = {
    http:"https://wild-still-sky.matic.quiknode.pro/b1af5cd242b1dff46e044a1aaad6ab103262f6db/",
    wss:"wss://wild-still-sky.matic.quiknode.pro/b1af5cd242b1dff46e044a1aaad6ab103262f6db/"
}

const testnet = {
    http:"https://magical-warmhearted-bush.matic-testnet.quiknode.pro/61d738e468e43d59ee3708f88adc574265db2f0e/",
    wss:"wss://magical-warmhearted-bush.matic-testnet.quiknode.pro/61d738e468e43d59ee3708f88adc574265db2f0e/"
}

module.exports = {
    endpoint: {
        http: mainnet.http,
        wss: mainnet.wss
    },
}