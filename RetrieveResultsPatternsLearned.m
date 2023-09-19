function RetrieveResultsPatternsLearned(rulename)

%need to sort seeds and n_pat. Dictionary order of filenames should suffice
boxcar = 4;
if rulename == 'bid'
    rulename = 'Bid';
elseif rulename == 'uni'
    rulename = 'Uni';
end


foldername = ['Results',rulename];
searchterm = [foldername,'/',rulename,'_bx',num2str(boxcar),'*.mat'];
folderdir = dir(searchterm);
fname_list = {folderdir.name}';

%find how large we want our pat_learned_data array to be by determining the
%seed_space and the n_pat_space
npat_bag = zeros(size(fname_list));
seed_bag = npat_bag;
for i = 1:length(fname_list)
    fname = fname_list{i};
    sim_identifier = InterpretResultFName(fname);
    npat_bag(i) = sim_identifier.n_patterns;
    seed_bag(i) = sim_identifier.seed;
end

npat_space = sort(unique(npat_bag));
seed_space = sort(unique(seed_bag));


%get n_trials (ASSUMING they're all the same)
testfile = load([foldername,'/',fname_list{1}]);
n_trials = testfile.parameters.number_of_trials;
%preallocate our results array
pat_learned_data= NaN(n_trials,length(seed_space),length(npat_space));
pat_learned_vect = NaN(n_trials,1);
result_data = zeros(size(pat_learned_data));

for i = 1:length(fname_list)
    fname = fname_list{i};
    sim_identifier = InterpretResultFName(fname);
    f = load([foldername,'/',fname]);
    
    seed            = sim_identifier.seed;
    npat            = sim_identifier.n_patterns;
    
    seed_idx        = seed_space == seed;
    npat_idx        = npat_space == npat;
    
    svect = f.data.success_vect;
    
    
    
    

    for t = 1:n_trials
        result_code = svect(t);
        result_pat_learned = ResultCodeToPatternsLearned(result_code,npat);
        pat_learned_vect(t) = result_pat_learned;
    end
    pat_learned_data(:,seed_idx,npat_idx) = pat_learned_vect;
    result_data(:,seed_idx,npat_idx) = svect;
    
    
end

save(['OutputsSLURM/',rulename,'pat_learned_data.mat'],...
    'result_data','pat_learned_data','seed_space','npat_space')




%for loop, read files in folder and get data struct, seed and n_pat





