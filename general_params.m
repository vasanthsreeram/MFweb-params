function user = general_params(ID)

%% user details
user = [];
user.ID                         = ID;

%% general parameters
user.params.wd                   = pwd;
user.params.matlab               = version;
user.params.date                 = int64(dot(clock,[10^10,10^8,10^6,10^4,10^2,1]));  % YYYYMMDDHHMMSS date

%% task parameters
user.params.n_blocks                = 4;    
user.params.n_trialPB               = 100;
user.params.n_training_trials       = 10;


