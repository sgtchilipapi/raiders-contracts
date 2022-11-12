const testnet_deployments = {
    tokens: {
        wmatic: {
            address: "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889"
        },
        clank: {
            address: "0x27f26ca1bCa51A232226013e59eBE51daADd267e",
            abi: ""
        },
        boom: {
            address: "0xbfd0E811189f609532A7eb8888B226c7d22365a2",
            abi: ""
        },
        thump: {
            address: "0xC3997c1DC8Ee58Be0Adf62259D0f891E642c43bf",
            abi: ""
        },
        clink: {
            address: "0x5f3887d4Faf942AfbD9EAAAD369E4c923E7ee30b",
            abi: ""
        },
        snap: {
            address: "0x914fC2727BC0260D0B744981920eBf7cc240be41",
            abi: ""
        },
        yellowspark: {
            address: "0x23Dc2720104066f7996521ef45DACD707205382a",
            abi: ""
        },
        whitespark: {
            address: "0xefFCF0D89F7C527aB72e852401382Be940215A89",
            abi: ""
        },
        redspark: {
            address: "0x26d5Bd493DE05c366491c2D5c3a2eD2C4F311cDa",
            abi: ""
        },
        bluespark: {
            address: "0xf3C3a29A02745DdF49e9dbF0797c8a81bbFD9C2d",
            abi: ""
        },
        enerlink: {
            address: "0x36CDf641a165bBa044946C5759B235bd88544B09",
            abi: ""
        },
        clankmatic: {
            address: "0xA7A941341295E900D57A1ea36D271F18b11cfeA6"
        },
        clankboom: {
            address: "0x633b433DC825BaEBe3Db8483648208AA96A240f5"
        },
        clankthump: {
            address: "0xFDF6F1b765e8c26c9cf5979bE1FA7E2Aee79709D"
        },
        clankclink: {
            address: "0xC40c3fc7125902dAb302044319428dED83736616"
        },
        clanksnap: {
            address: "0x175498C283cCA7ef0bca525a9B5aa831B67c1c68"
        }
        
    },
    defi: {
        minichefv2: {
            address: "0x22ce9F8fd8694A097B9A712448f0773Fd67A8d19",
            abi: ""
        },
        factory: {
            address: "0xc35DADB65012eC5796536bD9864eD8773aBc74C4",
            abi: ""
        }
    },
    characters: {
        nftContract: {
            address: "0xC771b4b58A0D41C7cf561CCE3AAb3E00FDC08ac6",
            abi: ''
        },
        minter: {
            address: "0x808a8411A1A4BC7143ee334B2c2636e8dC384Fe6",
            abi: ''
        },
        vrf: {
            address: "0x725A21550c3ed08FB6fc986be5C73c272bE48F00",
            abi: ''
        },
        uriConstructor: {
            address: "0x39bC860EbF263f1F66d254c42fdDE6BDbED3586D"
        }
    },
    equipments: {
        nftContract: {
            address: "0x98B58fAe387bf7689eE5BA0562f745cF7Fcc7805",
            abi: ''
        },
        minter: {
            address: "0xa1Ce7b800321e4B1f0Dba28330bD0B5c99589DD8",
            abi: ''
        },
        vrf: {
            address: "0x80Be0C1DD0Bc5E895Bf86A8Dc014a070DD33Ecfc",
            abi: ''
        },
        manager: {
            address: "0x5f40BAe80AeCdA066C0f1b8E8740040F7Bd14000",
            abi: ''
        }
    },
    dungeons: {
        dungeon: {
            address: "0xD78CF6709892C0b453abf4bC385D15aF78352b06",
        },
        vrf: {
            address: "0x26c0C5E99AaCC6110faC9A21c661d18f2DFe4969"
        },
        keeper: {
            address: "0x8aFdF48702F7F7Db6bd5BaCfE380Ef5B1EE1c57a"
            ///Register new upkeep in https://automation.chain.link
        }
    }
}

const subgraph_deployments = {
    core: {
        characters: 'https://api.thegraph.com/subgraphs/name/sgtchilipapi/rc-characters',
        equipments: 'https://api.thegraph.com/subgraphs/name/sgtchilipapi/rc-equipments'
    }
}

module.exports = {
    contracts: testnet_deployments,
    subgraphs: subgraph_deployments
}