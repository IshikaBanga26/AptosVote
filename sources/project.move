module MyModule::GroupVoting {
    use aptos_framework::signer;
    use std::vector;
    
    /// Struct representing a voting poll for a group
    struct VotingPoll has store, key {
        proposal_title: vector<u8>,    // Title/description of the proposal
        yes_votes: u64,                // Count of yes votes
        no_votes: u64,                 // Count of no votes  
        voters: vector<address>,       // List of addresses that have voted
        is_active: bool,               // Whether voting is still active
    }
    
    /// Function to create a new voting poll
    public fun create_poll(creator: &signer, proposal_title: vector<u8>) {
        let poll = VotingPoll {
            proposal_title,
            yes_votes: 0,
            no_votes: 0,
            voters: vector::empty<address>(),
            is_active: true,
        };
        move_to(creator, poll);
    }
    
    /// Function to cast a vote on an existing poll
    public fun cast_vote(voter: &signer, poll_owner: address, vote_yes: bool) acquires VotingPoll {
        let poll = borrow_global_mut<VotingPoll>(poll_owner);
        let voter_address = signer::address_of(voter);
        
        // Check if poll is active and voter hasn't voted yet
        assert!(poll.is_active, 1);
        assert!(!vector::contains(&poll.voters, &voter_address), 2);
        
        // Record the vote
        if (vote_yes) {
            poll.yes_votes = poll.yes_votes + 1;
        } else {
            poll.no_votes = poll.no_votes + 1;
        };
        
        // Add voter to the list of voters
        vector::push_back(&mut poll.voters, voter_address);
    }
}