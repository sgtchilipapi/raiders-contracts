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

const QueryCharacter = `
  query($idNum: Int) {
    characters(where: {idNum: $idNum}) {
      id
      idNum
      minter {
        id
      }
      owner {
        id
      }
      character_name
      character_class
      str
      vit
      dex
      mood
      talent
      exp
    }
  }
`

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

export async function getCharacter(character_id) {
    const client = new ApolloClient({
        uri: characters_sg_deployment,
        cache: new InMemoryCache(),
    })

    let character
    await client
        .query({
            query: gql(QueryCharacter),
            variables: {
                idNum: character_id
            },
        })
        .then((data) => {
            character = data.data.characters[0]
        })
        .catch((err) => {
            console.log('Error fetching data: ', err)
        })
    return (character)
}