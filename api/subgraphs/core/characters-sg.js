import { ApolloClient, InMemoryCache, gql } from '@apollo/client'
const deployments = require('../../../app-config/deployments')
const characters_sg_deployment = deployments.subgraphs.core.characters

//Queries
const QueryCharactersOwned = `
  query($walletAddress: String) {
    owner(id: $walletAddress) {
        characters(first: 500 orderBy: idNum orderDirection: asc) {
          id
          idNum
          character_name
          character_class
          mood
          exp
        }
      }
  }
`

// const QueryCharacter = `
//   query($raiderID: String) {
//     raiderNFT(id: $raiderID){
//         id
//         idNum
//         owner{
//         id
//         }
//         faction{
//         id
//         }
//         rClass{
//         id
//         }
//         rName
//         exp
//         tokenURI
//         combination
//         edition{
//         id
//         }
//     }
//   }
// `

export async function getCharactersOwned(address) {
    const client = new ApolloClient({
        uri: characters_sg_deployment,
        cache: new InMemoryCache(),
    })

    const wallet = address.toLowerCase()
    let mappedItems
    await client
        .query({
            query: gql(QueryCharactersOwned),
            variables: {
                walletAddress: wallet
            },
        })
        .then((data) => {
            mappedItems = data.data.owner.characters.map(character => (
                {
                    character_id: character.id,
                    character_idnum: character.idNum,
                    character_name: character.character_name,
                    character_class: character.character_class,
                    character_mood: character.mood,
                    character_exp: character.exp
                }
            ))

        })
        .catch((err) => {
            console.log('Error fetching data: ', err)
            mappedItems = []
        })
    return (mappedItems)
}

// export async function getCharacter(id) {
//     const client = new ApolloClient({
//         uri: nftSubgraph,
//         cache: new InMemoryCache(),
//     })

//     let raiderDetails
//     await client
//         .query({
//             query: gql(QueryRaider),
//             variables: {
//                 raiderID: id
//             },
//         })
//         .then((data) => {
//             raiderDetails = data.data.raiderNFT
//         })
//         .catch((err) => {
//             console.log('Error fetching raider details: ', err)
//             raiderDetails = ""
//         })
//     return (raiderDetails)
// }