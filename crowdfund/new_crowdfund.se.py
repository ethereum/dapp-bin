data recipient
data minimum
data maximum
data contributed
data deadline
data funders[2**40]
data loopIndex
data tokens[]
data tokenPhase[]
data dividends[]
data currentDividendCounter

ETHER = 10**18

# To be called at initialization time
def setup(minimum:uint256, maximum:uint256, timelimit:uint256, recipient:address):
    if self.recipient:
        ~invalid()
    self.minimum = minimum
    self.maximum = maximum
    self.deadline = block.timestamp + timelimit
    self.recipient = recipient

# Participate in the crowdfunding campaign
def participate():
    if msg.value != 1 * ETHER:
        ~invalid()
    if block.timestamp >= self.deadline:
        ~invalid()
    if self.contributed >= self.maximum:
        ~invalid()
    nf = self.contributed
    self.contributed += 1
    self.funders[nf] = msg.sender

# To be called after the deadline. If less than the minimum number participated,
# refund all buyers. Otherwise, send a reward token to each participant.
def finalize():
    if block.timestamp <= self.deadline:
        ~invalid()
    # Are we below the minimum number of contributors?
    TOO_LOW = (self.contributed < self.minimum)
    # Start the refunding or rewarding process from where we left off last time
    i = self.loopIndex
    end = self.contributed
    # Keep going until either the end or until there is not enough gas left
    while i < end and msg.gas > 50000:
        if TOO_LOW:
            # If below the minimum, refund
            send(self.funders[i], 1 * ETHER)
        else:
            # Otherwise, send a reward token
            self.tokens[self.funders[i]] += 1
        i += 1
    self.loopIndex = i
    # Send the crowdfunded funds to the beneficiary
    if i == end and not TOO_LOW:
        send(self.recipient, self.contributed)

# Pay a dividend, equally spread among all accounts. For efficiency purposes, the
# dividend is not calculated immediately; rather, a record is saved of what size
# per token the dividend should be, and the next time a user sends their tokens
# (or calls updateToken) the dividend is paid
def payDividend():
    dividendAmount = msg.value / self.contributed
    self.currentDividendCounter += 1
    self.dividends[self.currentDividendCounter] = self.dividends[self.currentDividendCounter - 1] + dividendAmount

# Pay all owed dividends to the given account
def updateToken(acct):
    currentTokenPhase = self.tokenPhase[acct]
    newTokenPhase = self.currentDividendCounter
    send(acct, self.dividends[newTokenPhase] - self.dividends[currentTokenPhase])
    self.tokenPhase[acct] = newTokenPhase

def transfer(to:address, value:uint256):
    # Process dividends for the sender
    if self.tokenPhase[msg.sender] != self.currentDividendCounter:
        self.updateToken(msg.sender)
    # Process dividends for the recipient
    if self.tokenPhase[to] != self.currentDividendCounter:
        self.updateToken(to)
    # Can't send a negative amount of money!
    if value < 0:
        ~invalid()
    # Can't send more than you have!
    if self.tokens[msg.sender] < value:
        ~invalid()
    # Transfer the desired amount
    self.tokens[msg.sender] -= value
    self.tokens[to] += value
