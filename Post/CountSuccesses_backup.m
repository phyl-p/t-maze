




%{
%%%%BACKUP
function CountSuccesses(scorethreshold)
if ~exist('scorethreshold','var')
    scorethreshold = 3;
end
%get tables
%success_table_bid = CountSuccessesInFolder('ResultsBid');
%success_table_uni = CountSuccessesInFolder('ResultsUni');

bid_meta_directory_arguments = {'OutputsSLURM/folder_metas.mat','bid_meta'};
uni_meta_directory_arguments = {'OutputsSLURM/folder_metas.mat','uni_meta'};

%{
success_table_bid = CountSuccessesInFolder(scorethreshold,bid_meta_directory_arguments{:});
success_table_uni = CountSuccessesInFolder(scorethreshold,uni_meta_directory_arguments{:});


%find min and max # of patterns to set xlims of final plots
merged_s_table = [success_table_bid;success_table_uni];
min_npat = min(merged_s_table{:,'n_patterns'});
max_npat = max(merged_s_table{:,'n_patterns'});


%for bidirectional rule
subplot(1,2,1)
CountSuccessesInFolder(scorethreshold,bid_meta_directory_arguments{:});
xlim([min_npat,max_npat])
xlabel('number of patterns')
ylim([0,1])
ylabel('rate of success')
title('bidirectional success rate')



%for unidirectional rule
subplot(1,2,2)
CountSuccessesInFolder(scorethreshold,uni_meta_directory_arguments{:});
xlim([min_npat,max_npat])
xlabel('number of patterns')
ylim([0,1])
title('unidirectional success rate')
%}


figure;

CountSuccessesInFolder(scorethreshold,bid_meta_directory_arguments{:});
hold on
CountSuccessesInFolder(scorethreshold,uni_meta_directory_arguments{:});
xlabel('number of patterns')
ylabel('rate of success')
title({['Relative frequency of simulations that had ',...
                num2str(scorethreshold),' successful trials in a row'],...
        'bidirectional in blue, uni in red, 100 random seeds used'})

%plot(success_table_bid.success_rate-success_table_uni.success_rate)
%}