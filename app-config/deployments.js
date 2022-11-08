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
            address: "0xD458b05052A64A01Ec4cbe251F1EEc4FD144737E",
            abi: ''
        },
        minter: {
            address: "0x75B68DE2b7024fE3877E9f5fe46EA704c36Dfb5a",
            abi: ''
        },
        vrf: {
            address: "0x16927Bb1C7d8972AAb642731b6F447A02f39afBf",
            abi: ''
        },
        uriConstructor: {
            address: "0x1D5f8A622DCF5f0fC6B70e8978DDDa31DEfBfFF8"
        }
    },
    equipments: {
        nftContract: {
            address: "0xCb6db41952238ec5f81e878D1dA4BC1B1c285283",
            abi: ''
        },
        minter: {
            address: "0x32a4f480167b269773313678Aa6a14dE15238074",
            abi: ''
        },
        vrf: {
            address: "0xDF4F4324b0df51abB5EEa6D09956CfcB16F6c958",
            abi: ''
        },
        manager: {
            address: "0x45e34C818c231b8B5d6099b849aeEaD1A318e7c1",
            abi: ''
        }
    },
    dungeons: {
        dungeon: {
            address: "0xe8E9ED98B4808092f9C5a52c81DDF3687666B849",
        },
        vrf: {
            address: "0x903b393d273408BC480e0718A3463b448B25dc8B"
        },
        keeper: {
            address: "0xE3f1FE9FE8f626c7C94a2620a3Dc10f8780c11Ed"
            ///Register new upkeep in https://automation.chain.link
        }
    }
}

module.exports = {
    contracts: testnet_deployments
}