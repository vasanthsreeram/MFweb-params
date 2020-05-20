function [user] = apple_params(user)

%%
n_cond = 2;
items_per_cond = 100;    % repeat each twice (to assess randomness) -> will be doubled

%% Initialisation

% values
meanA_mean = [5 7];
meanA_var = 0.7 ;
meanB_var = [1 2]; % Tree B with respect to tree A => Tree A mean +- 1/2
meanC_var = [1 2]; % Tree C with respect to tree A or B => (Tree A or B) mean +- 1/2
meanD_var = [-1 -1]; % Tree D with respect to tree A => min(treeA, treeB, treeC) -1 or -2
SD = 0.8;
inf_bound = 2;
sup_bound = 10;

%% Compute means
num_items = items_per_cond; 

% Tree A
means = [round(randn(num_items/2,1)*2*meanA_var-meanA_var+meanA_mean(1))' round(randn(num_items/2,1)*2*meanA_var-meanA_var+meanA_mean(2))'];
means = means(randperm(length(means)));
means(means<inf_bound+2)=inf_bound+2; 
means(means>sup_bound-1)=sup_bound-1; 

% Tree B 
tmp = [meanB_var(1)*ones(1,num_items/4) -meanB_var(1)*ones(1,num_items/4) meanB_var(2)*ones(1,num_items/4) -meanB_var(2)*ones(1,num_items/4)];
tmp_means2 = means(1,:) + tmp; 
tmp_means2(tmp_means2<inf_bound+1)=inf_bound+1; 
tmp_means2(tmp_means2>sup_bound)=sup_bound; 
means(2,:) = tmp_means2; 

% Tree C
tmp = [meanC_var(1)*ones(1,num_items/4) -meanC_var(1)*ones(1,num_items/4) meanC_var(2)*ones(1,num_items/4) -meanC_var(2)*ones(1,num_items/4)];
tmp = tmp(randperm(length(tmp)));
tmp_means3 = [means(1,1:length(means(1,:))/2) means(2,1:length(means(2,:))/2)] + tmp ;
tmp_means3(tmp_means3<inf_bound+1)=inf_bound+1; 
tmp_means3(tmp_means3>sup_bound)=sup_bound; 
means(3,:) = tmp_means3; 

% Tree D
tmp = [meanD_var(1)*ones(1,num_items/2) meanD_var(2)*ones(1,num_items/2)];
for i=1:items_per_cond
    tmp_means4(i) = min(means(1,i), min(means(2,i), means(3,i))) + tmp(i); 
end
tmp_means4(tmp_means4<inf_bound)=inf_bound; 
means(4,:) = tmp_means4; 

% All
task_means = means';

%% Only 3 trees shown out of 4 every time
unused_tree = [1*ones(1,items_per_cond/4) 2*ones(1,items_per_cond/4) 3*ones(1,items_per_cond/4) 4*ones(1,items_per_cond/4)];
unused_tree = unused_tree(randperm(length(unused_tree)));

%% Compute sequences: draw 9 apples (maximum apples possible from one tree -> 3 initial + 6 picked)
hor = [9 4];
for t = 1:items_per_cond
    for tree=1:4
        r=[];
        r = task_means(t,tree) + SD.*randn(1,hor(1));
        if tree==1 || tree == 2 || tree == 3 %Whole loop changed
            for i=1:size(r,2)
                if r(1,i)<inf_bound+1 
                    r(1,i) = inf_bound+1;
                elseif r(1,i)>sup_bound
                    r(1,i) = sup_bound;
                end
            end
        elseif tree == 4    
            for i=1:size(r,2)
                if r(1,i)<inf_bound 
                    r(1,i) = inf_bound;
                elseif r(1,i)>sup_bound
                    r(1,i) = sup_bound;
                end
            end
        end
        item(1,t).sequences(tree,:) = round(r(1,:));
    end
end

%% Generate samples 


for trial = 1:items_per_cond
    
    user.task.item(trial).initial_apples.size = [];
    user.task.item(trial).initial_apples.tree = [];
    
    user.task.item(trial).unused_tree = unused_tree(trial);
    
    for tree_=1:4
    rand_=randperm(9);
        for cond_=1:2
            item(cond_,trial).chosen_idx(tree_,:) = rand_;
        end
    end
    
    if user.task.item(trial).unused_tree == 3
        ix = randperm(5);
    elseif (user.task.item(trial).unused_tree == 4 || user.task.item(trial).unused_tree == 2)
        ix = randperm(4);
    elseif (user.task.item(trial).unused_tree == 1)
        ix = randperm(2);
    end
    
    % Initial samples
    
    % Tree A (3)
    if user.task.item(trial).unused_tree ~= 1
        for i = 1:3
            user.task.item(trial).initial_apples.size(end+1) = item(1,trial).sequences(1,item(1,trial).chosen_idx(1,i));
            user.task.item(trial).initial_apples.tree(end+1) = 1;
        end
    end
    
    % Tree B (1)
    if user.task.item(trial).unused_tree ~= 2
        user.task.item(trial).initial_apples.size(end+1) = item(1,trial).sequences(2,item(1,trial).chosen_idx(2,1));
        user.task.item(trial).initial_apples.tree(end+1) = 2;
    end
    
    % Tree D (1)
    if user.task.item(trial).unused_tree ~= 4
        user.task.item(1,trial).initial_apples.size(end+1) = item(1,trial).sequences(4,item(1,trial).chosen_idx(4,1));
        user.task.item(1,trial).initial_apples.tree(end+1) = 4;
    end
    
    % Make sure that D is the smallest
    if ~isempty(find(user.task.item(1,trial).initial_apples.tree==4,1)) %trials where there is a D tree
        ind_tree_D = find(user.task.item(1,trial).initial_apples.tree == 4,1);
        minimas = find(user.task.item(1,trial).initial_apples.size == min(user.task.item(1,trial).initial_apples.size));
        tree_minimas = user.task.item(1,trial).initial_apples.tree(minimas);
            while size(minimas,2)~=1 || (size(minimas,2)==1 && tree_minimas~=4)
                user.task.item(1,trial).initial_apples.size(ind_tree_D) = user.task.item(1,trial).initial_apples.size(ind_tree_D)-1;
                minimas = find(user.task.item(1,trial).initial_apples.size == min(user.task.item(1,trial).initial_apples.size));
                tree_minimas = user.task.item(1,trial).initial_apples.tree(minimas);
            end
            
        if user.task.item(1,trial).initial_apples.size(ind_tree_D)<2 %make sure that it is not smaller than 2
            user.task.item(1,trial).initial_apples.size(ind_tree_D) = 2;
        end
    end

    %randomize order of A, B, D  
    user.task.item(1,trial).initial_apples.size = user.task.item(1,trial).initial_apples.size(ix);
    user.task.item(1,trial).initial_apples.tree = user.task.item(1,trial).initial_apples.tree(ix);  
    
    %add zeros 
    nb_to_add = 5 - size(user.task.item(1,trial).initial_apples.size,2);
    user.task.item(1,trial).initial_apples.size = [user.task.item(1,trial).initial_apples.size zeros(1,nb_to_add)];
    user.task.item(1,trial).initial_apples.tree = [user.task.item(1,trial).initial_apples.tree zeros(1,nb_to_add)];
    
    if size(user.task.item(1,trial).initial_apples.size,2) ~= 5
        disp('Problem, not 5 initial samples')
    end

    % Future samples
    user.task.item(1,trial).future_apples.tree(:,:) = nan(4,6);
    % Tree A
    user.task.item(1,trial).future_apples.tree(1,:) = item(1,trial).sequences(1,item(1,1).chosen_idx(1,4:hor(1)));
    % Tree B
    user.task.item(1,trial).future_apples.tree(2,:) = item(1,trial).sequences(2,item(1,1).chosen_idx(2,4:hor(1)));
    % Tree C
    user.task.item(1,trial).future_apples.tree(3,:) = item(1,trial).sequences(3,item(1,1).chosen_idx(3,4:hor(1)));
    % Tree D
    user.task.item(1,trial).future_apples.tree(4,:) = item(1,trial).sequences(4,item(1,1).chosen_idx(4,4:hor(1)));
    
    % Tree that is not used has all its values replaced by zeros
    for tree_=1:4
        if user.task.item(trial).unused_tree == tree_
          user.task.item(1,trial).future_apples.tree(tree_,:) = zeros(1,6);
        end
    end
end

%% shuffle items for each condition
for c = 1:n_cond
    item_idxs{c,1} = randperm(items_per_cond);
    item_idxs{c,2} = randperm(items_per_cond);
end

%% set up trial order (balance conditions in each block)
N_cond_per_block = user.params.n_trialPB / n_cond;
conds = repmat(1:n_cond,1,N_cond_per_block);

%% fill in condition and item for each block
for b = 1:user.params.n_blocks
    user.task.block(b).hor = conds(randperm(length(conds)));    % condition
    for c = 1:n_cond
        idx = find(user.task.block(b).hor(:)==c);
        if b < 3    % first half of experiment
            user.task.block(b).itemID(idx) = item_idxs{c,1}(1:length(idx));    % item number assignment
            item_idxs{c,1}(1:length(idx)) = []; % prevent multiple usages
        else        % second half of exp
            user.task.block(b).itemID(idx) = item_idxs{c,2}(1:length(idx));    % item number assignment
            item_idxs{c,2}(1:length(idx)) = []; % prevent multiple usages
        end
    end
end



