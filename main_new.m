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
    
    n_training_trials = size(user.training.item,2);
    n_shown_apples = size(user.training.item(1).initial_apples.size,2);
    
    Training = [];
    
    for trialNo = 1:n_training_trials
        
        app_sizes = user.training.item(trialNo).initial_apples.size;
        future_app_sizes = user.training.item(trialNo).future_apples.tree;
        correct_tree = user.training.item(trialNo).initial_apples.tree;
        
        if correct_tree == 1
            correct_options = [1,0];
        elseif correct_tree == 2
            correct_options = [0,1];
        end
        
        Training(end+1,1:9) = [userID,trialNo,app_sizes, future_app_sizes', correct_options]; %TODO 2 choix peuvent pas avoir meme taille 
            
    end
    
    
    %% Task: Same format as SQL
    
    % Task
    Task = [];
    
    trial_per_block = 100;
    n_task_items = size(user.task.item,2);
    
    trialNo = 0;
    
            
    for blockNo = 1:4

        for trialinBlockNo = 1:trial_per_block

            trialNo = trialNo+1;
            horizon = user.task.block(blockNo).hor(trialinBlockNo);
            itemNo = user.task.block(blockNo).itemID(trialinBlockNo);
            initialsampleNb = size(find(user.task.item(itemNo).initial_apples.tree),2); % find takes only non zero elements                              
            initialsamples = user.task.item(itemNo).initial_apples;       
            futuresamples=user.task.item(itemNo).future_apples.tree;
            unused_tree = user.task.item(itemNo).unused_tree;
            
            display_order = randperm(4);
            display_order(display_order==unused_tree)=[];
            
            tree_positions = zeros(1,4);
            for i=1:4
                if i~=unused_tree
                    tree_positions(i) = find(display_order==i);
                end
            end
            
            if horizon == 2
                horizon = 6;
            end

            Task(end+1,1:48) = [userID, trialNo, blockNo, horizon, itemNo, initialsampleNb, unused_tree, display_order, tree_positions, initialsamples.tree, initialsamples.size, futuresamples(1,:), futuresamples(2,:), futuresamples(3,:), futuresamples(4,:)]; 

        end

    end
        
    
    %% Save
    folder_name = strcat('/Users/magdadubois/MF/task_data/data/user_',int2str(userID), '/');
    
    if ~exist(folder_name,'dir')
        mkdir(folder_name)
        save(strcat(folder_name,'Training.mat'),'Training')
        save(strcat(folder_name,'Task.mat'),'Task')
    else
        disp('This UserID already exists')
    end
    
end

