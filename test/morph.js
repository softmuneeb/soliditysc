const { toWei, fromWei, toChecksumAddress } = require('web3-utils');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

const Nft = artifacts.require('Morph');

contract('Nft', async ([owner, client, parentCompany]) => {
  it('deploy smart contract', async () => {
    //
    //
    let nft = await Nft.new({ from: owner });
    console.log(owner === (await nft.owner()));

    //
    //
    const whitelist = [
      client,
      '0xc18E78C0F67A09ee43007579018b2Db091116B4C',
      '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4',
      '0xBCb03471E33C68BCdD2bA1D846E4737fedb768Fa',
      '0x590AD8E5Fd87f05B064FCaE86703039d1F0e4350',
      '0x989b691745F7B0139a429d2B36364668a01A39Cf',
    ].map((a) => toChecksumAddress(a));
    const tree = new MerkleTree(whitelist, keccak256, {
      hashLeaves: true,
      sortPairs: true,
    });
    await nft.setWhitelistActiveTime(0);
    await nft.setWhitelist(tree.getHexRoot(), { from: owner });
    await nft.purchaseMorphsWhitelist(1, tree.getHexProof(keccak256(client)), {
      value: toWei('0', 'ether'),
      from: client,
    });
    console.log(fromWei(await web3.eth.getBalance(owner)));
    await nft.withdraw({ from: owner });
    console.log(fromWei(await web3.eth.getBalance(owner)));

    //
    //
    await nft.setSaleActiveTime(0);
    await nft.purchaseMorphs(1, { value: toWei('0.5', 'ether'), from: client });
    console.log(fromWei(await web3.eth.getBalance(owner)));
    await nft.withdraw({ from: owner });
    console.log(fromWei(await web3.eth.getBalance(owner)));
  });
});
