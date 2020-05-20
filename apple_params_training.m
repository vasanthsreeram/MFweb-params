function [user] = apple_params_training(user)

    
    %% Initialisation
    
    n_items = user.params.n_training_trials;    

    mean1 = 8;
    mean2 = 3;
    SD = 0.8;
    inf_bound = 2;
    sup_bound = 10;

    %% Compute means

    % Tree 1
    means(1,:) = [mean1*ones(1,n_items)];
    % Tree 2
    means(2,:) = [mean2*ones(1,n_items)];
    
    % All
    training_means = means';

    %% Compute sequences: draw 9 apples (maximum apples possible from one tree -> 3 initial + 6 picked)
    num_apples_pertree = 4;
    for t = 1:n_items
        for tree=1:2
            r = training_means(t,tree) + SD.*randn(1,num_apples_pertree);
        for i=1:size(r,2)
            if r(1,i)<inf_bound 
                r(1,i) = inf_bound;
            elseif r(1,i)>sup_bound
                r(1,i) = sup_bound;
            end
        end
        item(1,t).sequences(tree,:) = round(r(1,:));
        end
    end


    %% Generate samples 
    
    user.training = [];
    user.training.item = [];
    
    % sequence with the indexes of apples that will be chosen for each tree
    for trial = 1:n_items
        for tree_=1:2
            rand_=randperm(4);
            item(trial).chosen_idx(tree_,:) = rand_;
        end   

        disp_apples = num_apples_pertree-1;
        tmp = randperm(2);
        disp_tree = tmp(1);

        % Initial samples
        for i=1:disp_apples
            user.training.item(trial).initial_apples.size(i) = item(1,t).sequences(disp_tree,item(trial).chosen_idx(disp_tree,i));
        end
        
        user.training.item(trial).initial_apples.tree= disp_tree;

        %randomize order 
        user.training.item(trial).initial_apples.size = user.training.item(trial).initial_apples.size(randperm(disp_apples));

        % Future samples, tree 1 and 2
        user.training.item(trial).future_apples.tree(:,:) = nan(2,1);
        user.training.item(trial).future_apples.tree(1,1) = item(1,trial).sequences(1,item(trial).chosen_idx(1,4:num_apples_pertree));
        user.training.item(trial).future_apples.tree(2,1) = item(1,trial).sequences(2,item(trial).chosen_idx(2,4:num_apples_pertree));

    end

end
