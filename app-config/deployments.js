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
    equipments: {
        nftContract: {
            address: "0xbd81474EAf303aaD7b68C1a81Ad80D10e7722297",
            abi: ''
        },
        minter: {
            address: "0x27ad3E9a23095b9d68142411fa46ccCc1c559650",
            abi: ''
        },
        vrf: {
            address: "0xe0CE2F5521a45B185AD5619b8b2aFD55e40E71c2",
            abi: ''
        },
        manager: {
            address: "0xAbf887734Ad9b5CAC7B5e66c6940F66b4b160119",
            abi: ''
        }
    },
    characters: {
        nftContract: {
            address: "0x933d54A8e613b1ACb8D16CF47aF5d921f8EF8b37",
            abi: ''
        },
        minter: {
            address: "0x090BB382Fc6eeC090F13F521B928d1A0e969A515",
            abi: ''
        },
        vrf: {
            address: "0x3a6808C30537e6d1f9881c4b63BF7489c29c9fBC",
            abi: ''
        },
        uriConstructor: {
            address: "0x06A81b46eD4aE70B22B9579532de1C6db9AF77E5"
        }
    },
    dungeons: {
        dungeon: {
            address: "0x28f56aE97E3aeEFbe4404EcD5a59A5Ca3bD73731",
        },
        vrf: {
            address: "0x44f0AB2fDc1AB4313DAECE494c44e8be6F19C911"
        },
        keeper: {
            address: "0xe9b50Bc9F3D185d890d605dEEaCd4a4E8f7d78C6"
            ///Register new upkeep in https://automation.chain.link
        }
    }
}

module.exports = {
    contracts: testnet_deployments
}