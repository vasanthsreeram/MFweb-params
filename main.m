clear all; close all; clc

% Print the current working directory
disp(['Current working directory: ', pwd]);

Nb = 100;
tpb = 3;
months = 3;
% Check and create the /data directory if it doesn't exist


%% Task

for taskNo=1:Nb
    
    folder_name = strcat('../data/generative/tasks/task_',int2str(taskNo), '/');
        
    % General stuff
    task_user = general_params(taskNo);
    task_user = apple_params(task_user);
        
    Task = [];
    
    trial_per_block = tpb;
    n_task_items = size(task_user.task.item,2);
    
    trialNo = 0;
            
    for blockNo = 1:months

        for trialinBlockNo = 1:trial_per_block

            trialNo = trialNo+1;
            horizon = task_user.task.block(blockNo).hor(trialinBlockNo);
            itemNo = task_user.task.block(blockNo).itemID(trialinBlockNo);
            initialsampleNb = size(find(task_user.task.item(itemNo).initial_apples.tree),2); % find takes only non zero elements                              
            initialsamples = task_user.task.item(itemNo).initial_apples;       
            futuresamples=task_user.task.item(itemNo).future_apples.tree;
            unused_tree = task_user.task.item(itemNo).unused_tree;
            
            display_order = randperm(4);
            display_order(display_order==unused_tree)=[];
            
            tree_positions = zeros(1,4);
            position_counter = 1; % Start position counter for used trees
            for i = 1:length(display_order)
                if display_order(i) ~= unused_tree
                    tree_positions(display_order(i)) = position_counter;
                    position_counter = position_counter + 1;
                end
            end
            
            if horizon == 2
                horizon = 6;
            end

            Task(end+1,1:48) = [taskNo, trialNo, blockNo, horizon, itemNo, initialsampleNb, unused_tree, display_order, tree_positions, initialsamples.tree, initialsamples.size, futuresamples(1,:), futuresamples(2,:), futuresamples(3,:), futuresamples(4,:)]; 

        end

    end
           
    % Save  
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
    disp(['Created directory: ', folder_name]);
end
    mkdir(folder_name,'dir')
    disp('This taskNo already exists')
    save(strcat(folder_name,'Task.mat'),'Task')
    save(strcat(folder_name,'taskNo.mat'),'taskNo')
    disp(['Saved files in: ', folder_name]);
    
end


%% Training

for trainingNo=1:Nb
    
    folder_name = strcat('../data/generative/trainings/training_',int2str(trainingNo), '/');
    
    % General stuff
    training_user = general_params(trainingNo);

    % Training
    [training_user] = apple_params_training(training_user);  
    
    n_training_trials = size(training_user.training.item,2);
    n_shown_apples = size(training_user.training.item(1).initial_apples.size,2);
    
    Training = [];
    
    for trialNo = 1:n_training_trials
        
        app_sizes = training_user.training.item(trialNo).initial_apples.size;
        future_app_sizes = training_user.training.item(trialNo).future_apples.tree;
        correct_tree = training_user.training.item(trialNo).initial_apples.tree;
        
        if correct_tree == 1
            correct_options = [1,0];
        elseif correct_tree == 2
            correct_options = [0,1];
        end
        
        Training(end+1,1:9) = [trainingNo,trialNo,app_sizes, future_app_sizes', correct_options]; %TODO 2 choix peuvent pas avoir meme taille 
            
    end
    
    % Save  
if ~exist(folder_name, 'dir')
    mkdir(folder_name)
    disp(['Created directory: ', folder_name]);
end

% Save the files whether the directory was just created or already existed
save(fullfile(folder_name, 'Training.mat'), 'Training');
save(fullfile(folder_name, 'trainingNo.mat'), 'trainingNo');
disp(['Saved files in: ', folder_name]);
end

