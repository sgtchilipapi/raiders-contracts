import { ApolloClient, InMemoryCache, gql } from '@apollo/client'
const deployments = require('../../../app-config/deployments')
const equipments_sg_deployment = deployments.subgraphs.core.equipments

//Queries
const QueryEquipmentOwned = `
  query($walletAddress: String) {
    owner(id: $walletAddress) {
        equipments(first: 500 orderBy: idNum orderDirection: asc) {
            id
            idNum
            equipment_type
            rarity
            dominant_stat
            extremity
            atk
            def
            eva
            hp
            pen
            crit
            luk
            res
        }
      }
  }
`

export async function getEquipmentsOwned(address) {
    const client = new ApolloClient({
        uri: equipments_sg_deployment,
        cache: new InMemoryCache(),
    })

    const wallet = address.toLowerCase()
    let equipments_arr = []
    await client
        .query({
            query: gql(QueryEquipmentOwned),
            variables: {
                walletAddress: wallet
            },
        })
        .then((data) => {
            equipments_arr = data.data.owner.equipments
        })
        .catch((err) => {
            console.log('Error fetching data: ', err)
            equipments_arr = []
        })
    return (equipments_arr)
}