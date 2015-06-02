// WeiLend System
// Start, lend, payout and return interest yield to funders
// @creator of the original WeiFund code:
// Nick Dodson <thenickdodson@gmail.com>
// @forked to implement the WeiLend by:
// M. Terzi <ma.terzi@tiscali.it> ===> http://github.com/terzim
// If goal is not reached and campaign is expired, contributers can get their donation refunded individually
// If goal is reached by alloted time, contributions can still be made
// After a grace period, the beneficiary returns funds to the funders in installments at a given interest rate

contract WeiLend {
// builds a variable (struct) called User which has two sub-variables, an integer number called numLoans and a mapping of 
    // loans.
    
    struct User
    {
        uint numLoans;
        mapping(uint => uint) loans;
    }
    
    // builds a variable (struct) called Funder which is identified by an address (his public "signature"), and an amount which he has lent
    // which will define his/her entitlement to the installments repayments. 
    
    struct Funder 
    {
        address addr;
        uint amount;
    }
    
     // builds a variable (struct) called Loan. This is the most complex variable of the set. The most important here are the sub-variables:
     // timelimit [the time for which the Loan is open to funding], fundingGoal [the amount that the guy who gets the
     // loan wants to collect], and the key contractual features of the loan which are the interest_rate, the        
     // gracePeriod and the tenor. 
     
     // importantly, this variable contains a map of the funders and a pointer to the funders. 
     
    struct Loan 
    {
        bytes32 operationName;
        address beneficiary;
        uint timelimit;
        uint fundingGoal;
        uint amount;
        uint balance;
        uint category;
        uint status;
        uint numFunders;
        uint interestRateM; // monthly         
        uint gracePeriod;
        uint tenorM; // monthly
        uint installment; // monthly
        mapping (uint => Funder) funders;
        mapping (address => uint) toFunder;
    }
  
    uint public numLoans;
    mapping (uint => Loan) public loans;
    mapping (address => User) public users;
    

    //events are returned after functions are successfully called
    event onNewLoan(address indexed from, uint indexed lid);
    event onContribute(address indexed from, uint indexed lid, uint _value);
    event onPayout(address indexed from, uint indexed lid, uint _value);
    event onRefund(address indexed from, uint indexed lid, uint _value);
    event onpayInstallment(address indexed from, uint indexed lid, uint _value);

 function newLoan(bytes32 _operationName, address _beneficiary, uint _goal, uint _timelimit_m, uint _category, uint _interest_rate, uint _grace_period_m, uint _tenor_a)
    {
    
        // if the goal (one of the parameters of the function assigned by the person 
        // who runs the function is greater than zero [not sure this shoudl stay here though]
        // and the timelimit is greater than now (that is, the campaign has not expired] do....  
        
        if(_goal > 0 ){
            
            // initialize a new variable called lid, which is a counter for the numLoans (defined earlier as a public integer variable)
            uint lid = numLoans++; // campaignID is return variable
            // creates a loan called l which will corrispond the [position lid in the mapping of all loans]
            Loan l = loans[lid];  // assigns reference
            l.operationName = _operationName; // vanity
            // again assign to the loan l the beneficiary defined by the argument of the function
            l.beneficiary = _beneficiary;
            // again assign to the loan l the fundingGoal defined by the argument of the function
            l.fundingGoal = _goal;
            // again assign to the loan l the timelimit defined by the argument of the function
            l.timelimit = block.timestamp + (_timelimit_m * 43200);
            // again assign to the loan l the category defined by the argument of the function
            l.category = _category;
            // again assign to the loan l the interest rate defined by the argument of the function
            l.interestRateM = _interest_rate / 12;
            // again assign to the loan l the grace period defined by the argument of the function
            l.gracePeriod = _grace_period_m * 43200;
            // again assign to the loan l the tenor defined by the argument of the function (note, tenor meant to be after grace period)
            l.tenorM = _tenor_a * 12;
            // now creates a user called u, which is the sender of the transaction
            User u = users[msg.sender];
            // creates a variable called u_lid, which adds a one to the number of loans the user has made.
            uint u_lid = u.numLoans++;
            u.loans[u_lid] = lid;
            
            // calls the event onNewLoan
            onNewLoan(msg.sender, lid);
        }
    }
 
 function contribute(uint _lid)
    {
        Loan l = loans[_lid]; // Cannot be expired.
        
        // if the raising is not yet terminated
        if(l.timelimit >= block.timestamp) {
            uint fid = l.numFunders++;
            Funder f = l.funders[fid];
            f.addr = msg.sender;
            f.amount = msg.value;
            //increases the loan amount by the contribution
            l.amount += f.amount;
            //sends a funder id to the funder
            l.toFunder[msg.sender] = fid;
            onContribute(msg.sender, _lid, l.amount);
        }
    }

 function refund(uint _lid)
    {
        Loan l = loans[_lid];
        if (block.timestamp > l.timelimit 
        && l.amount < l.fundingGoal && l.amount > 0){
            Funder f = l.funders[l.toFunder[msg.sender]];
            if(f.amount > 0){
                f.addr.send(f.amount);
                l.amount -= f.amount;
                onRefund(msg.sender, _lid, f.amount);
                f.amount = 0;
            }
        }
    }

 function payout(uint _lid)
    {
        Loan l = loans[_lid];
        if (l.amount >= l.fundingGoal){
            
            l.beneficiary.send(l.amount);
            onPayout(msg.sender, _lid, l.amount);
            
            l.status = 1;
            l.timelimit = l.timelimit + l.gracePeriod;
            //calculates the monthly installment amount. Constant installment loan
            l.installment = l.amount * ((l.interestRateM*((1+l.interestRateM)**(l.tenorM)))/(((1+l.interestRateM)**(l.tenorM))-1));
            l.balance = l.amount;
        }
    }

 function payInstallment(uint _lid)
    {
        Loan l = loans[_lid];
        //returns if the borrower is paying a wrong installment amount (error handling)
        if (msg.value != l.installment){
            msg.sender.send(msg.value);
            return;
        }

        //returns if the grace period is not over
        if (block.timestamp < l.timelimit) return;
        //returns if the loan balance is below zero (error handling)
        if (l.balance < 0) return;

        uint i = 0;
        uint n = l.numFunders;
        
        //maybe the while is not needed here. Could use the toFunder functionality?
        //in essence this loops returns to each funder his/her quota of the total installment 
        while(i<n){
            uint entitlement = l.installment*l.funders[i].amount/l.amount;
            l.funders[i].addr.send(entitlement);
            i++; //added counter. Need to check with Ken if needed
        }
  
        //updates the balance of the loan. The installment remains constant throughout the duration of the loan but the balance
        //decreases of the principal amount paid along with the installment. 
        l.balance -= (l.installment -(l.balance*l.interestRateM)); 
        onpayInstallment(msg.sender, _lid, l.balance);

    }
}
