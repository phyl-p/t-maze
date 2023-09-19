function SessionFiguresAndImages(n_nrns,bx)
addpath('./Initialise')
addpath('./GenerateInputPatterns')
addpath('./Helpers')
addpath('./Model')
addpath('./PresetKs')
addpath('./Post')


[npat_space,success_mat_bid,success_mat_uni]=CountSuccesses(n_nrns,bx);






for scorethreshold=[1:2:5,10]
    success_vect_bid = sum(success_mat_bid>scorethreshold,2);
    success_vect_uni = sum(success_mat_uni>scorethreshold,2);
    
    
    figure;
    plot(npat_space,success_vect_bid)
    hold on
    plot(npat_space,success_vect_uni)
    xlabel('number of patterns')
    ylabel('rate of success')
    n_rng_seeds=size(success_mat_bid,2);
    title({['Relative frequency of simulations that had ',...
                    num2str(scorethreshold),' successful trials in a row'],...
            ['bidirectional in blue, uni in red, ' , num2str(n_rng_seeds), ' random seeds used']})
    
    
    fname=[num2str(n_nrns),'nrn',num2str(bx),'boxcars',num2str(scorethreshold),'success_inarow'];
    foldername=['Figures/',num2str(n_nrns),'bx',num2str(bx)];
    savefig([foldername,'/',fname,'.fig']);
    saveas(gcf,[foldername,'/',fname,'.jpg']);
end



foldername=['OutputsSLURM/',num2str(n_nrns),'bx',num2str(bx)];

f_bid=load([foldername,'/Bidpat_learned_data.mat']);
f_uni=load([foldername,'/Unipat_learned_data.mat']);


overlay_mat=TrialSuccessesOverlay(f_bid);

sum_success=sum(overlay_mat,1);
best_performance=find(sum_success==max(sum_success));

overlay_vect=overlay_mat(:,best_performance(1));

figure; bar(overlay_vect)





function [npat_space,success_mat_bid,success_mat_uni]=CountSuccesses(n_nrns,bx)
if ~exist('scorethreshold','var')
    scorethreshold = 3;
end
%get tables
%success_table_bid = CountSuccessesInFolder('ResultsBid');
%success_table_uni = CountSuccessesInFolder('ResultsUni');

foldername=['OutputsSLURM/',num2str(n_nrns),'bx',num2str(bx)];

f_bid=load([foldername,'/Bidpat_learned_data.mat']);
f_uni=load([foldername,'/Unipat_learned_data.mat']);

[npat_space,success_mat_bid]=MaxConsStrictSuccessData(f_bid);

[    ~     ,success_mat_uni]=MaxConsStrictSuccessData(f_uni);




function [npat_space,success_mat]=MaxConsStrictSuccessData(f)

pld=f.pat_learned_data;
npat_space=f.npat_space;

%we want the rows of success mat to index n_patterns and the columns to
%index the rng seeds.
success_mat=zeros(size(pld,3),size(pld,2));

for i = 1:length(npat_space)
    npat=npat_space(i);
    maxconsecutivesuccesses_vect=Mat2MaxConsNonZeros(pld(:,:,i)>=npat);
    success_mat(i,:)=maxconsecutivesuccesses_vect;
end




function mat=TrialSuccessesOverlay(f)
pld_strict=StrictSuccesses(f);
npat_space=f.npat_space;

len_trial=size(pld_strict,1);


mat=zeros(len_trial,length(npat_space));

for k = 1:length(npat_space)
    for t=1:len_trial
        mat(t,k)=sum(pld_strict(t,:,k),'all');
    end
end











