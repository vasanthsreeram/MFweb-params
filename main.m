clear all; close all; clc

for userID=1:10
    
    %% Generate Data
    
    % General stuff
    user = general_params(userID);

    % Training
    [user] = apple_params_training(user);
    
    % Task
    [user] = apple_params(user);
    
    %% Training: Same format as SQL
    
    % PresentedSamples
    n_training_trials = size(user.training.item,2);
    n_shown_apples = size(user.training.item(1).initial_apples.size,2);
    
    PresentedSamples = [];
    
    for trialNo = 1:n_training_trials
        
        app_sizes = user.training.item(trialNo).initial_apples.size;
        
        for sampleNo = 1:n_shown_apples
            
            PresentedSamples(end+1,1:4) = [userID,trialNo,sampleNo,app_sizes(sampleNo)];  
            
        end
    end
    
    % Choice
    n_training_trials = size(user.training.item,2);
    n_choices = size(user.training.item(1).future_apples.tree,1);
    
    Choice = [];
    
    for trialNo = 1:n_training_trials
        
        app_sizes = user.training.item(trialNo).future_apples.tree;
        correct_tree = user.training.item(trialNo).initial_apples.tree;
        
        if correct_tree == 1
            correct_options = [1;0];
        elseif correct_tree == 2
            correct_options = [0;1];
        end
        
        for choiceNo = 1:n_choices
            
            Choice(end+1,1:4) = [trialNo,choiceNo,app_sizes(choiceNo),correct_options(choiceNo)];  
            
        end
    end
    
    %% Task: Same format as SQL
    
    % Trial
    Trial = [];
    
    trial_per_block = 100;
    n_task_items = size(user.task.item,2);
    
    trialNo = 0;
    
    for blockNo = 1:4
    
        for trialinBlockNo = 1:trial_per_block
            
            trialNo = trialNo+1;

            horizon = user.task.block(blockNo).hor(trialinBlockNo);
            itemNo = user.task.block(blockNo).itemID(trialinBlockNo);
            sampleNb = size(user.task.item(itemNo).initial_apples.tree,2);

            Trial(end+1,1:6) = [userID, itemNo, horizon, blockNo, trialNo, sampleNb];  

        end
        
    end
    
    % InitialSamples
    
    InitialSamples = [];
    
    for itemNo = 1:n_task_items
                
        n_shown_apples = size(user.task.item(itemNo).initial_apples.size,2);
        app_sizes = user.task.item(itemNo).initial_apples.size;
        app_trees = user.task.item(itemNo).initial_apples.tree;
        app_unused_tree = user.task.item(itemNo).unused_tree;
        
        for sampleNo = 1:n_shown_apples
            
            InitialSamples(end+1,1:5) = [itemNo, app_unused_tree, sampleNo, app_trees(sampleNo), app_sizes(sampleNo)];  
            
        end
    end
    
    % FutureSamples
    n_task_items = size(user.task.item,2);
    
    FutureSamples = [];
    
    for itemNo = 1:n_task_items
        
        samples=user.task.item(itemNo).future_apples.tree;
        
        for tree = 1:4 % num trees
            
            for sample_n = 1:6 % num trees
            
                FutureSamples(end+1,1:4) = [itemNo, tree, sample_n, samples(tree,sample_n)];  
                
            end
            
        end
    end
       
    
    
    %% Save
    folder_name = strcat('/Users/magdadubois/MF/task_data/data/user_',int2str(userID), '/');
    
    if ~exist(folder_name,'dir')
        mkdir(folder_name)
        save(strcat(folder_name,'user.mat'),'user')
        save(strcat(folder_name,'FutureSamples.mat'),'FutureSamples')
        save(strcat(folder_name,'InitialSamples.mat'),'InitialSamples')
        save(strcat(folder_name,'PresentedSamples.mat'),'PresentedSamples')
        save(strcat(folder_name,'Choice.mat'),'Choice')
        save(strcat(folder_name,'Trial.mat'),'Trial')
    else
        disp('This UserID already exists')
    end
    
end

