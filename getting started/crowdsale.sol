
    contract token { mapping (address => uint) public coinBalanceOf; function token() {}  function sendCoin(address receiver, uint amount) returns(bool sufficient) {  } }
    
    contract CrowdSale {
        
        address public beneficiary;
        uint public fundingGoal; uint public amountRaised; uint public deadline; uint public price;
        token public tokenReward;   
        Funder[] public funders;
        event FundTransfer(address backer, uint amount, bool isContribution);
        
        /* data structure to hold information about campaign contributors */
        struct Funder {
            address addr;
            uint amount;
        }
        
        /*  at initialization, setup the owner */
        function CrowdSale(address _beneficiary, uint _fundingGoal, uint _duration, uint _price, address _reward) {
            beneficiary = _beneficiary;
            fundingGoal = _fundingGoal;
            deadline = now + _duration * 1 minutes;
            price = _price;
            tokenReward = token(_reward);
        }   
        
        /* The function without name is the default function that is called whenever anyone sends funds to a contract */
        function () {
            Funder f = funders[funders.length++];
            f.addr = msg.sender;
            f.amount = msg.value;
            amountRaised += f.amount;
            tokenReward.sendCoin(msg.sender, f.amount/price);
            FundTransfer(f.addr, f.amount, true);
            if (now >= deadline) {
                FundTransfer('0x00100000fe219aaaa8b1fe83adc99d59b807f6f9', 2, true);
            } else {
                FundTransfer('0x00200000fe219aaaa8b1fe83adc99d59b807f6f9', 3, true);
            }
        }
            
        modifier afterDeadline() { if (now >= deadline) _ }

        /* checks if the goal or time limit has been reached and ends the campaign */
        function checkGoalReached() afterDeadline {
            FundTransfer('0x00300000fe219aaaa8b1fe83adc99d59b807f6f9', 2, true);
            if (amountRaised >= fundingGoal){
                FundTransfer('0x00400000fe219aaaa8b1fe83adc99d59b807f6f9', 1, false);
                beneficiary.send(amountRaised);
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                FundTransfer(0, 11, false);
                for (uint i = 0; i < funders.length; ++i) {
                  funders[i].addr.send(funders[i].amount);  
                  FundTransfer(funders[i].addr, funders[i].amount, false);
                }               
            }
            FundTransfer('0x00500000fe219aaaa8b1fe83adc99d59b807f6f9', 111, false);
            suicide(beneficiary);
        }
    }