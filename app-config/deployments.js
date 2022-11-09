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
            address: "0x0F1fFfD038752e9f1A8FBDBc976CdB4ef7434C33",
            abi: ''
        },
        minter: {
            address: "0xA75ab2C87eD694bE760Eb05857bDbB141A272385",
            abi: ''
        },
        vrf: {
            address: "0x7A671D5Fb45108582996bDC079AfDDDC7D08d439",
            abi: ''
        },
        uriConstructor: {
            address: "0xb60d4a04122903Def494AFC6BF7F14AACa192052"
        }
    },
    equipments: {
        nftContract: {
            address: "0x7901A9408D5fD819355cd5Fb48973BdF003573de",
            abi: ''
        },
        minter: {
            address: "0x5B173fF6aF29c4C53C05Ca67EF326C58AE99de71",
            abi: ''
        },
        vrf: {
            address: "0x020DBfdCD5Dfd0d868072D1F7FC1dD6d12738226",
            abi: ''
        },
        manager: {
            address: "0x381d46ddc2503Ab3c6f07940dc4C60e4Faa8fc70",
            abi: ''
        }
    },
    dungeons: {
        dungeon: {
            address: "0xdce5db5D520c9F717920eAf142E7096132d9f74D",
        },
        vrf: {
            address: "0x120E0f86412913a7D9123D82E6A1eDF5FA40a6F6"
        },
        keeper: {
            address: "0xb482f6e2A4979aEB4F53FE19E0aaB51A0214391E"
            ///Register new upkeep in https://automation.chain.link
        }
    }
}

const subgraph_deployments = {
    core: {
        characters: 'https://api.thegraph.com/subgraphs/name/sgtchilipapi/rc-characters'
    }
}

module.exports = {
    contracts: testnet_deployments,
    subgraphs: subgraph_deployments
}