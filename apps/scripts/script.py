# The gas costs won't go into calculation

# Methodology of a making a position
#  - Deposit X ETH
#  - Take flashloan of 2X ETH
#  - Make position of 3X ETH on AAVE
#  - Borrow Y  USDC from AAVE.       - Y = Min USDC amount which when swapped to ETH gives minimum 2X ETH
#  - Swap Y to get min 2X ETH
#  - Return 2X ETH to flashloan
#  - Mint 3X token ETH3XUP

# Suppose the leverage you want is 3x.
# After some price movement, the leverage moved to 2.6x
# then you will write a function rebalance on the contract, which can be called by anyone.
# which will take the current position in aave and adjust it in such a way that the leverage is back to 2x.
# this function can only be called when the triggers are met, such as below 1.6x or above 2.3x
# what’s the ideal intervals should i replicate to make the positions in?
# you should decide anytime as the ideal time to start, and then you make the a function to get the current leverage, and at every 1-2 hour interval you can check if it goes out of range, then you call the rebalance function. and then leverage goes back to 2x. you will also need a baseline, which is indexcoop or any other products 2x leverage curve and then compare the net PnL with both. You can do this simply by adding both the curves in the same chart. You can get the historical price from coingecko - though the api is shit it is fine for backtesting.
# you need to mock the fees and other external factors that will affect your model, this will give you an accurate idea of whether the idea works or not


# Leverage = ( Amount deposited  in AAVE == Always 3X WETH )
# Important Points :
# 1) Instead of borrowing exactly 2X * ETH.PRICE, I borrow 2X *  ETH.PRICE * Y   '
#    so that I get a minimum of 2X WETH from Uniswap after swapping
#    This does not affect the leverage one gets, its always equal to 3X
#    It only affects my AAVE HEALTH RATIO
# 2) Rebalancing = Adjusting AAVE Position


# Tasks = Write a function to get current leverage


def getHistoricalPrice(time):
    return 0

def getPercentChange(initPrice, currentPrice):
    delta = ( currentPrice - initPrice ) / initPrice
    return delta

class Position:
    def __init__(self,init_time,init_price,curr_leverage,AAVE_deposit,AAVE_borrow,):
        self.initTime = init_time
        self.initPrice = init_price
        self.initial_leverage = curr_leverage
        self.AAVE_deposit = AAVE_deposit
        self.AAVE_borrow = AAVE_borrow

    def mintNew_ETH3X(x,time) :
        self.AAVE_deposit += 3*x*getHistoricalPrice(time)
        self.AAVE_borrow += 2*x*getHistoricalPrice(time)

    def getLeverage(time):
        currentPrice = getHistoricalPrice(time)
        delta = getPercentChange(self.initPrice,currentPrice)
        result_num = ( self.AAVE_deposit - self.AAVE_borrow ) *  ( 1 + delta)
        result_denom = result_num - self.AAVE_borrow
        result = result_num / result_denom
        return result
    


