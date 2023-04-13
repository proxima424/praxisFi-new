## Summary

Praxis lets traders have onchain perpetual futures over Aave. Praxis will hold leveraged long positions on behalf of users over Aave.</br> Users shall receive corresponding ERC20 tokens representing the perpetual contracts created with a unique minting, redeeming and pricing mechanism for the ERC20 tokens given to represent a position.</br> This mechanism and the utilization rates of Aave shall let us calculate the value of the position by always taking the funding mechanism into consideration (more on this in the later part).</br> This will make the leveraged positions tradeable which is not the case for most of the counterparts. Ussers are able to create leveraged perpetual positions with Instadapp and earn yield over them. </br>These positions are not tradeable and transferrable as they are not represented by ERC-20 tokens who have a definite value which justifies the price of the position. With Praxis, users can create tradeable leveraged psoitions on deep liquidity of pools like Aave and Compound.

As a POC, Praxis has implemented long perpetual positions over Aave WETH pool, with 3x leverage and issue corresponding WETHUP3x tokens to represent the position. </br>

*Contract deployed on PolygonTestnet: 0xa7873dFD4610B22f9C88129d01ABc993653CACD6*</br>

## 1.Problem Statement

### 1.1 ****************************************************Perps are good, but on CEX are not done!****************************************************

The majority volume of CEX comes from trading of derivatives. Derivatives are loved by traders as it gives them the opportunity to grab more profits on their funds with leverage. Perpetual futures are famous among traders due to the non-time boundness of the contract. These are traded on CEXs based on the supply and demand for the perp (Order book process).

The current FTX saga has shed light on trading issues with CEXs. CEXs cannot be trusted due to non-self custody and discrepancy in their ledger. Onchain Perps had started emerging due to this.

### 1.2 Onchain Perps and Liquidity

Onchain perps are necessary to counter perps built over CEX. Onchain perps are built over liquidity pools as limit orderbooks on chains is tough. These pools make sure the entire trading of onchain perps.

******************************Thin liquidity:****************************** Protocols had started issuing perpetual protocols by often building their own liquidity pools for providing liquidity to their perpetual. Thin liquidity in these pools have seen many hacks across these protocols.

So what do we exactly need?

We need users to be able to trader perps onchain in a deep, trustable, transparent liquidity pool. Aave’s liquidity over polygon network and the ethereum network ticks all the boxes.

Building derivatives on golden standard pools like save are bound to happen.

We are going to lead it.

## 2. Solution

### 2.1 Onchain Perps on Aave

Aave pools become the perfect playground for building perps onchain.

Praxis will create a long position on WETH with 3x leverage over Aave. Corresponding WETHUP3x tokens are issued to the user.

The meaning of the statement- ‘Praxis will create a long position over Aave’ means that all the positions are created from the single smart contract address of Praxis instead of creating individual positions for people (This will help us create a mechanism to determine values of perpetual contracts, we shall get back on it later)

This brings us to few important questions

- **********************************************How is leverage created?**********************************************
- **How are these positions created or closed?**
- **************What is the mechanism for issuing and minting  of tokens?**************

### 2.2 Opening a Position

As the current Praxis version lets create perpetual futures at long position on WETH with 3x leverage, let’s understand the opening position from creating a long perpetual future on WETH at 3x leverage.

What exactly is happening under the hood is creation of leverage position over Aave.
eg: A person had X WETH, WETH/USDC = P, 3x leveraged long position on WETH needs to be created.

The person shall take a flashloan of 2X WETH and deposit it along with his own X WETH in the WETH pool of Aave. Thus, the total deposit by the person in Aave is now 3X WETH.

This person now shall borrow USDC equivalent to 2X WETH to return the flashloan. The 3X WETH deposited in WETH pool of Aave shall act as the collateral for taking the borrowing of USDC to return the flashloans.

``Borrowed from USDC pool of Aave = 2X*P USDC``
Use it to return the flashloan by converting
2X*P USDC in WETH through Uniswap.

This has created a leveraged position of 3X WETH deposit on Aave and borrowing of 2X WETH with X WETH deposited from user. The WETH deposited in Aave shall change values 3 times the change expected if leverage was not taken

HOW THE DUCK IS PRAXIS DIFFERENT THAN INSTADAPP??? (Hang in tight with this very important  question, we shall explain this in some time)

Users will also receive WETHUP3x tokens to represent the position (more on this in Minting, Redeeming & Pricing session)

### 2.3 Closing a Position

Closing a position with Aave is equivalent to burning or redeeming the WETHUP3x tokens issued to represent the position. When the position is closed, it means that the deposit of WETH equivalent to that position is withdrawn and the borrowing of USDC equivalent to that position is repaid through the WETH equivalent deposit withdrawn. The difference between the two is transferred to the user who had held that position. This shall represent the value of the position at the time it was closed. To calculate the equivalent deposit of WETH or equivalent borrowing of USDC for a position, we will be multiplying the total deposit or total borrow by our smart contract by the ratio of WETHUP3x tokens representing that specific position vs. the total WETHUP3x by us till now.

Let’s look at it with an example:

A person had opened a long perpetual future position on WETH for X WETH at 3x leverage. The WETH deposited for this position were 3X while there was already Z WETH deposited through Praxis’ smart contract before this position. Similarly, opening this position shall create a borrowing equivalent to `2X*P USDC (considering ETH/USDC = P during the opening of this position)`. There shall already be borrowing of K USDC through Praxis’ smart contract before this position. Also consider J ETHUP3x tokens to be minted before this position and H tokens to be issued for this position.

The deposit and borrowing is known to increase in Aave due to interest rate and borrowing rate applied on them through Aave. Thus, if the deposits are kept idle after the initiation of the position, then after time t, total deposit through our smart contract shall be `3X + Z + i` and `total borrowing through our smart contract be 2X*P + K + r` (where r and i are the borrowing rate an interest rate respectively)

The `deposit equivalent to this position is H/J * (3X + Z + i)` while the borrowing equivalent to this position is H/J * (2X*P + K + r). Thus after closing the position, the funds a user shall receive after repaying the borrowing is H/J * (3X + Z + i - 2X*P - K - r)

AGAIN THE SAME QUESTION, HOW IS PRAXIS DIFFERENT THAN INSTADAPP??? Such leveraged positions are opened and closed for year or more now.

Praxis is different than Instadapp. Instadapp lets you earn extra yield through this mechanism on your idle funds, we are enabling onchain perp futures which can be traded by users.  Will prove our point once you understand our minting, redeeming and pricing mechanism of WETHUP3x tokens.

### 2.4 **************************************************************Minting, Redeeming & Pricing of WETHUP3x tokens**************************************************************

The entire mechanism revolves around 3 statements or formulas

WETHUP3x price before an event = WETHUP3x price after an event (the event here means either opening or closing a position)

for rest of the times, WETHUP3x price = Value of the contract/total number of WETHUP3x tokens

Note- these total number of tokens are the ones issued subtracted by the ones redeemed.

Initially to start from 0 (for the smart contract of Praxis and not of the user), the number of WETHUP3x tokens issued are equivalent to the number of WETH deposited by the user himself (the value is initially started from 1 WETHUP3x = 1 WETH)

**************Minting**************

Tokens are minted after the opening of the position. For Minting event, collect the values of deposit, borrowing, Total WETHUP of the smart contract, WETH/USDC  price at a state before the position is opened. The amount of WETH to be deposited by user during opening of the position shall help us calculate the increase in deposit and borrowing in the smart contract. We could also get contract value after the opening position as Total deposit of WETH (in USDC) - Total borrowing of USDC. As WETHUP3x price is equal before and after opening the position, we can calculate the number of tokens to be minted for this particular position.

******************Redeeming******************

User can close a position and redeem the WETHUP3x tokens representing that position. For Redeeming event, collect the values of deposit, borrowing, Total WETHUP3xx of the smart contract, WETH/USDC  price at a state before the position is closed. The WETHUP3x tokens for that position are burnt and the position is closed as discussed in our previous section.

| Sr. No.                 | Tx                    | WETH (deposit in Aave)          | USDC (borrow from Aave) | Total WETHUP3x          | Issued      | Contract Value | WETHUP3x Price in USDC | WETH/USDC | Comments |
|-------------------------|-----------------------|---------------------------------|-------------------------|-------------------------|-------------|----------------|------------------------|-----------|----------|
|                         |                       | 0                               | 0                       |                         |             |                |                        |           |          |
| 1                       | Mint (1 WETH)         | 3                               | 2000                    | 1                       | 1           | 1000           | 1000                   | 1000      |          |
| (state just before Tx2) |                       | 3.15                            | 2200                    | 1                       | 0           |                |                        |           |          |
| 2                       | Mint (1 WETH)         | 6.15                            | 4200                    | 2.052631579             | 1.052631579 | 1950           | 950                    | 1000      |          |
|                         |                       |                                 |                         |                         |             |                |                        |           |          |
|                         |                       |                                 |                         |                         |             |                |                        |           |          |
| (state before Tx3)      |                       | 6.35                            | 4350                    | 2.052631579             | 0           | 2063.5         | 1005.295               | 1010      |          |
| 3                       | Mint (2 WETH)         | 12.35                           | 8390                    | 4.01699                 | 2.0093      | 4083.5         | 1005.295               | 1010      |          |
|                         |                       | 12.71                           | 8476                    | 4.01699                 | 0           | 3344.3         | 823.315                | 930       |          |
| 4                       | Redeem (1.5 WETHUP3x) | 12.71 - (0.369*12.71) = 8.02001 | 8476-3129.9 = 5346.1    | 4.01699 - 1.5 = 2.56199 | -1.5        | 824.557        | 823.315                | 930       |          |
|                         |                       |                                 |                         |                         |             |                |                        |           |          |
|                         |                       |                                 |                         |                         |             |                |                        |           |          |
|                         |                       |                                 |                         |                         |             |                |                        |           |          |

This is how the parameters in smart contract look like when users open or close positions

******************************************Transferring/Trading******************************************

The perpetual contracts are represented by WETHUP3x tokens. As WETHUP3x tokens are transferrable, these tokens are transferrable too. There won’t be any change in the state of the contract but here only the mapping of the contract to the user shall change.

Defining value for the perpetual contract is necessary to make that perps contract tradeable. In order to make them tradeable, it is imp to associate price to the contract in ERC20 tokens. Instadapp and other don’t do that.

In our case, WETHUP3x price = Contract value / total WETHUP3x (these values are for the smart contract that holds the position)

****************************************************************Funding mechanism taken care of!****************************************************************

While calculating perpetual contract’s price, taking funding mechanism into consideration to justify the price is necessary. We have seen funding mechanism and rebalancing in centralized exchanges.

The beauty of Aave pools is the Utilization rate which determines the interest and borrowing rate for the Aave pools. They are designed in a way to encourage/discourage the opposite behaviour of depositing/borrowing to the pool. As these rates accumulate on the deposits and borrowing from our smart contract, Funding rates are taken care of!

Thus, the WETHUP3x price calculated and the perpetual price calculating with it by multiplying the number of WETHUP3x tokens for that position, we are able to present the value for the perpetual position by considering the discounting cost/premium cost of the perpetual contract.

As the WETHUP3x tokens have a defined value and the perps have a price represented in ERC20 tokens, they can be traded by users.

## 3. Next Steps

The next steps for us shall be to create a market mechanism for WETHUP3x tokens where the price remains pegged to the one we receive with the formula. The perpetual position or even the WETHUP3x though shall always be traded at some different price in other markets.

We will also try to execute and create perpetual futures for going short on WETH.

Going beyond WETH. We shall also look to create perpetual contracts over other relevant  tokens.

As we are executing the leveraging with flashloans instead of looping, we could have more fluid non-integral leverages.

## 4. Bounties

### **************************4.1 Deploying over Polygon (For Best DeFi project)**************************

Here are the links to the smart contract addresses deployed on Polygon: 0xa7873dFD4610B22f9C88129d01ABc993653CACD6

We believe building such on-chain perpetual futures over polygon network and deeper liquidity pool shall bring trust among the users and attract users to trade perpetuals.

### 4.2 **Applying for Polygon Best UX tracks**

As we had in the beginning tried taking direct competition with centralized exchanges whose user experience is very smooth, we have taken special care while designing our user experience for Praxis finance.

Having familiar designs is crucial for users to not have a difficult learning curve. We have taken care of this by trying to imbibe all the parameters and elements which are generally expected by a user while trading perps on the centralized exchanges.

Often Dapps give new users a feeling of uncertainty. The uncertainty is often due to the overall experience of depositing their funds in a blackhole. We have used the concept of Optimsitic patterns where while the transactions are taking place, the screen would have a loading animation to help users feel certain.

While opening a new perpetual position, any trader shall like to get the expected outputs for the funds he is adding. When trader adds the amount of WETH to be deposited to start a perpetual position, we calculate and let our trader know the expected value of the perpetual position once created and the ETHUP3x tokens minted equivalent to it.

For the position which was already created by the user, we attach Proof of Position redirecting towards the polyscan for this transaction. The user also gets information of the amount he has deposited the value of his perp when opened and also the current value, which shall help him take better and swifter decisions. We have also attached a chart of WETH vs USDC to let user understand when he should be taking some decision instead of shifting tabs unnecessarily.

We are also showing the accumulation of important parameters on the dashboard to help trader have a bird’s eye view

We have built the wallet with Rainbow kit and integrated wagmi hooks for connecting the wallet. A user  would not be restricted to metamask for connecting wallet and can go beyond it too.

### 4.3 **************************Integration with Push protocol**************************

Any trader shall like to receive regular updates on his positions. Push protocol’s notifications are the best way to let traders have it.

### 4.4 ******************Integration with ENS******************

We have integrated with ENS to help users have a better experience. Looking at the ENS domain instead of the wallet address always feels good. Especially when most users consider their ENS names to be cool.

Whenever a user connects their wallet with our platform, we shall fetch his ens name and show the user to be logged in with his ens name instead of wallet address.






# Turborepo starter

This is an official npm starter turborepo.

## What's inside?

This turborepo uses [npm](https://www.npmjs.com/) as a package manager. It includes the following packages/apps:

### Apps and Packages

- `docs`: a [Next.js](https://nextjs.org/) app
- `web`: another [Next.js](https://nextjs.org/) app
- `ui`: a stub React component library shared by both `web` and `docs` applications
- `eslint-config-custom`: `eslint` configurations (includes `eslint-config-next` and `eslint-config-prettier`)
- `tsconfig`: `tsconfig.json`s used throughout the monorepo

Each package/app is 100% [TypeScript](https://www.typescriptlang.org/).

### Utilities

This turborepo has some additional tools already setup for you:

- [TypeScript](https://www.typescriptlang.org/) for static type checking
- [ESLint](https://eslint.org/) for code linting
- [Prettier](https://prettier.io) for code formatting

### Build

To build all apps and packages, run the following command:

```
cd my-turborepo
npm run build
```

### Develop

To develop all apps and packages, run the following command:

```
cd my-turborepo
npm run dev
```

### Remote Caching

Turborepo can use a technique known as [Remote Caching](https://turbo.build/repo/docs/core-concepts/remote-caching) to share cache artifacts across machines, enabling you to share build caches with your team and CI/CD pipelines.

By default, Turborepo will cache locally. To enable Remote Caching you will need an account with Vercel. If you don't have an account you can [create one](https://vercel.com/signup), then enter the following commands:

```
cd my-turborepo
npx turbo login
```

This will authenticate the Turborepo CLI with your [Vercel account](https://vercel.com/docs/concepts/personal-accounts/overview).

Next, you can link your Turborepo to your Remote Cache by running the following command from the root of your turborepo:

```
npx turbo link
```

## Useful Links

Learn more about the power of Turborepo:

- [Tasks](https://turbo.build/repo/docs/core-concepts/monorepos/running-tasks)
- [Caching](https://turbo.build/repo/docs/core-concepts/caching)
- [Remote Caching](https://turbo.build/repo/docs/core-concepts/remote-caching)
- [Filtering](https://turbo.build/repo/docs/core-concepts/monorepos/filtering)
- [Configuration Options](https://turbo.build/repo/docs/reference/configuration)
- [CLI Usage](https://turbo.build/repo/docs/reference/command-line-reference)
