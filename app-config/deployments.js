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
            address: "0x72C2f48FCc08A863e71258E665A395e2a5D407bc",
            abi: ''
        },
        minter: {
            address: "0xEEb4b17B14b3fcf7B192516cBd17246C0716584A",
            abi: ''
        },
        vrf: {
            address: "0xe836AB507744883E05109bAec4182FeB2A97CBbd",
            abi: ''
        },
        uriConstructor: {
            address: "0xD4c5E563FEfFb3C5bDc1613dF7BAB5D23ae1c023"
        }
    },
    equipments: {
        nftContract: {
            address: "0x4e57cBBc51e50c5010F0dD895219c0c44d754e5d",
            abi: ''
        },
        minter: {
            address: "0xd3116af355e483677a04426b87b72a8191F763a0",
            abi: ''
        },
        vrf: {
            address: "0x77E35250f7575F4dBDb5A5a6BE3a3b0a42052F0F",
            abi: ''
        },
        manager: {
            address: "0x165F0995bB83dB02831F6a0a1fe69e76C9cD6a94",
            abi: ''
        }
    },
    dungeons: {
        dungeon: {
            address: "0x6506Ab692218890c4106034C00B1a1abf47A5711",
        },
        vrf: {
            address: "0x464eb4eF04bD916b9527d86a48aAf25296AbaE64"
        },
        keeper: {
            address: "0x4BE45F104e09a3131Ff834d29bBe89De7721F8e2"
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