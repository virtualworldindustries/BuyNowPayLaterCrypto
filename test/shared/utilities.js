const { Contract } = require('ethers')
const { Web3Provider } = require('ethers')
const {
  BigNumber,
  bigNumberify,
  getAddress,
  solidityPack,
  utils
} = require('ethers')

const PERMIT_TYPEHASH = utils.keccak256(
  utils.toUtf8Bytes('Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)')
)

function expandTo18Decimals(n){
  return BigNumber.from(n).mul(BigNumber.from(10).pow(18))
}

function getDomainSeparator(name, tokenAddress) {
  return utils.keccak256(
    utils.defaultAbiCoder.encode(
      ['bytes32', 'bytes32', 'uint256', 'address'],
      [
        utils.keccak256(utils.toUtf8Bytes('EIP712Domain(string name,uint256 chainId,address verifyingContract)')),
        utils.keccak256(utils.toUtf8Bytes(name)),
        1,
        tokenAddress
      ]
    )
  )
}

function getCreate2Address(
  factoryAddress,
  [tokenA, tokenB],
  bytecode
) {
  const [token0, token1] = tokenA < tokenB ? [tokenA, tokenB] : [tokenB, tokenA]
  const create2Inputs = [
    '0xff',
    factoryAddress,
    utils.keccak256(solidityPack(['address', 'address'], [token0, token1])),
    utils.keccak256(bytecode)
  ]
  const sanitizedInputs = `0x${create2Inputs.map(i => i.slice(2)).join('')}`
  return getAddress(`0x${utils.keccak256(sanitizedInputs).slice(-40)}`)
}

async function getApprovalDigest(
  token,
  approve,
  nonce,
  deadline
) {
  const name = await token.name()
  const DOMAIN_SEPARATOR = getDomainSeparator(name, token.address)
  return utils.keccak256(
    utils.solidityPack(
      ['bytes1', 'bytes1', 'bytes32', 'bytes32'],
      [
        '0x19',
        '0x01',
        DOMAIN_SEPARATOR,
        utils.keccak256(
          utils.defaultAbiCoder.encode(
            ['bytes32', 'address', 'address', 'uint256', 'uint256', 'uint256'],
            [PERMIT_TYPEHASH, approve.owner, approve.spender, approve.value, nonce, deadline]
          )
        )
      ]
    )
  )
}

//async function mineBlock(provider, timestamp){
//   await new Promise(async (resolve, reject) => {
//     ;(provider._web3Provider.sendAsync)(
//       { jsonrpc: '2.0', method: 'evm_mine', params: [timestamp] },
//       (error, result): void => {
//         if (error) {
//           reject(error)
//         } else {
//           resolve(result)
//         }
//       }
//     )
//   })
// }

function encodePrice(reserve0, reserve1) {
  return [reserve1.mul(bigNumberify(2).pow(112)).div(reserve0), reserve0.mul(bigNumberify(2).pow(112)).div(reserve1)]
}

module.exports = {
   expandTo18Decimals,
   getDomainSeparator,
   getCreate2Address,
   getApprovalDigest,
   encodePrice
}
