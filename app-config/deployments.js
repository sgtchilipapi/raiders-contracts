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
            address: "0x131D3C977704A246A5402D528dAA7d53801b5737",
            abi: ''
        },
        minter: {
            address: "0x5bFa1D0cbE3DA9F3a55dA10389E9AeAFeAc9B159",
            abi: ''
        },
        vrf: {
            address: "0xc14071676a8B94D384984C384b08eA245EEc4B52",
            abi: ''
        },
        uriConstructor: {
            address: "0x6698aA88669e2d8c57EC6dBb9881512C8A2F347C"
        }
    },
    equipments: {
        nftContract: {
            address: "0xAb06384e60B0b0ebBD603e023f32C39499BccB82",
            abi: ''
        },
        minter: {
            address: "0xB12428d865074F40B010BA98Be5Ce8ea23ad9761",
            abi: ''
        },
        vrf: {
            address: "0x9060564323AFBeec81D89b89D2EF004f57c6a410",
            abi: ''
        },
        manager: {
            address: "0xaA14ffbBfa5B53b72556b3AC4480A0cEc54376A5",
            abi: ''
        }
    },
    dungeons: {
        dungeon: {
            address: "0x40F6140b1fCDeBC822594782C3f0Dd7829de778C",
        },
        vrf: {
            address: "0x3c3D096a290bdb5E41c24c8c2CB1AAe685A1cB04"
        },
        keeper: {
            address: "0xC090548F08F18CEC6097EFc55FF60E25eF6dFFD4"
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